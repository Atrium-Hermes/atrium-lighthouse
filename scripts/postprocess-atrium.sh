#!/usr/bin/env bash
# Post-process Atrium rental requests left by the atrium-scout skill.
#
# The Claude agent step never sees ATRIUM_PRIVATE_KEY (by design — the wallet key
# is kept out of the model's reach). Instead the scout writes its top pick to
# .pending-atrium/<slug>.json, and THIS script — run after Claude with full env —
# performs the actual on-chain `atrium invoke` (USDC spend) and stashes the body.
#
# Safety rails:
#   - No key  -> no-op (report-only, exactly today's behaviour).
#   - Enforces max_price_usdc from memory/atrium/scout-config.md (defence in depth).
#   - Honours auto_invoke: false.
#   - Skips skills already in memory/atrium/rented/.
#   - Rents at most ONE skill per run.
set -euo pipefail

PENDING_DIR=".pending-atrium"
RENTED_DIR="memory/atrium/rented"
CONFIG="memory/atrium/scout-config.md"

if [ ! -d "$PENDING_DIR" ] || [ -z "$(ls -A "$PENDING_DIR"/*.json 2>/dev/null)" ]; then
  echo "atrium-postprocess: no pending requests"
  exit 0
fi

if [ -z "${ATRIUM_PRIVATE_KEY:-}" ]; then
  echo "atrium-postprocess: ATRIUM_PRIVATE_KEY not set, skipping (report-only)"
  exit 0
fi

# ── Read config gates ───────────────────────────────────
AUTO_INVOKE="false"
MAX_PRICE="0"
if [ -f "$CONFIG" ]; then
  AUTO_INVOKE=$(grep -E '^auto_invoke:' "$CONFIG" | head -1 | sed -E 's/^auto_invoke:[[:space:]]*//; s/[[:space:]]*#.*//' || echo "false")
  MAX_PRICE=$(grep -E '^max_price_usdc:' "$CONFIG" | head -1 | sed -E 's/^max_price_usdc:[[:space:]]*//; s/[[:space:]]*#.*//' || echo "0")
fi
if [ "$AUTO_INVOKE" != "true" ]; then
  echo "atrium-postprocess: auto_invoke is '$AUTO_INVOKE', not renting"
  exit 0
fi

# ── Ensure the atrium CLI is available ──────────────────
if ! command -v atrium >/dev/null 2>&1; then
  echo "atrium-postprocess: installing atrium CLI..."
  npm install -g @atrium-hermes/cli >/dev/null 2>&1 || {
    echo "atrium-postprocess: CLI install failed, skipping"
    exit 0
  }
fi

mkdir -p "$RENTED_DIR"
RENTED_THIS_RUN=0

for req_file in "$PENDING_DIR"/*.json; do
  [ -f "$req_file" ] || continue
  [ "$RENTED_THIS_RUN" -eq 0 ] || { echo "atrium-postprocess: one rental already made this run, skipping rest"; break; }

  SKILL_ID=$(jq -r '.skillId // empty' "$req_file")
  SLUG=$(jq -r '.slug // empty' "$req_file")
  PRICE=$(jq -r '.price // "0"' "$req_file")
  NETWORK=$(jq -r '.network // "base"' "$req_file")

  if [ -z "$SKILL_ID" ] || [ -z "$SLUG" ]; then
    echo "atrium-postprocess: invalid request $(basename "$req_file") (missing skillId/slug), skipping"
    continue
  fi

  # Already rented?
  if [ -f "$RENTED_DIR/$SLUG.md" ]; then
    echo "atrium-postprocess: $SLUG already rented, skipping"
    rm -f "$req_file"
    continue
  fi

  # Price cap (defence in depth — string compare via awk for decimals)
  if awk -v p="$PRICE" -v cap="$MAX_PRICE" 'BEGIN{exit !(p+0 > cap+0)}'; then
    echo "atrium-postprocess: $SLUG price $PRICE > cap $MAX_PRICE, skipping"
    continue
  fi

  echo "atrium-postprocess: invoking $SLUG ($SKILL_ID) at \$$PRICE on $NETWORK..."

  # Sanity: wallet must hold enough USDC. balance is read-only.
  atrium balance --network "$NETWORK" || {
    echo "atrium-postprocess: balance check failed, skipping (wallet may be unfunded)"
    continue
  }

  INVOKE_OUT=$(atrium invoke "$SKILL_ID" --network "$NETWORK" 2>&1) || {
    echo "atrium-postprocess: invoke failed for $SLUG:"
    echo "$INVOKE_OUT"
    continue
  }
  echo "$INVOKE_OUT"

  # Best-effort tx hash extraction from CLI output.
  TX=$(echo "$INVOKE_OUT" | grep -oE '0x[a-fA-F0-9]{64}' | head -1 || echo "")

  # Fetch the body (does not re-pay) and stash it.
  BODY=$(atrium fetch "$SKILL_ID" --network "$NETWORK" 2>/dev/null || echo "")
  {
    echo "# $SLUG (rented from Atrium)"
    echo ""
    echo "- skillId: \`$SKILL_ID\`"
    echo "- price: \$$PRICE USDC"
    echo "- network: $NETWORK"
    echo "- tx: ${TX:-see run logs}"
    echo ""
    echo "---"
    echo ""
    echo "$BODY"
  } > "$RENTED_DIR/$SLUG.md"
  echo "atrium-postprocess: saved body to $RENTED_DIR/$SLUG.md"

  # Marker for the agent to read on the next run.
  echo "{\"slug\":\"$SLUG\",\"skillId\":\"$SKILL_ID\",\"price\":\"$PRICE\",\"tx\":\"${TX:-}\"}" \
    > "$PENDING_DIR/$SLUG.done"

  rm -f "$req_file"
  RENTED_THIS_RUN=1
done

echo "atrium-postprocess: done"

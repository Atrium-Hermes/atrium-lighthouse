#!/usr/bin/env bash
set -euo pipefail
#
# setup-lighthouse.sh — turn a fresh Aeon repo into the Atrium Lighthouse agent.
#
# Run from the ROOT of an Aeon repo (created via aaronjmars/aeon → "Use this template"):
#   bash setup-lighthouse.sh
#
# It installs the Atrium skills pack, writes the Lighthouse config (report-only =
# ZERO spend by default), and enables atrium-scout + atrium-earnings in aeon.yml.
# Self-contained — copy just this file into your Aeon repo and run it.

[ -x ./install-skill-pack ] && [ -f aeon.yml ] || {
  echo "✗ Run this from the root of an Aeon repo (needs ./install-skill-pack + aeon.yml)." >&2; exit 1; }

PACK="${ATRIUM_PACK:-Atrium-Hermes/aeon-atrium-skills}"

echo "→ installing Atrium skills pack ($PACK) …"
./install-skill-pack "$PACK" --yes

echo "→ writing memory/atrium/scout-config.md (report-only by default) …"
mkdir -p memory/atrium
cat > memory/atrium/scout-config.md <<'EOF'
# Atrium scout config
#
# Read by the atrium-scout skill.

auto_invoke: false
# false = report-only (discover + recommend, spend nothing). Flip to true ONLY after
# the ATRIUM_PRIVATE_KEY wallet is funded with USDC + a little ETH on Base mainnet.

max_price_usdc: 0.05
# Never auto-invoke a skill priced above this. The scout rents at most ONE skill per run.

allowed_categories: [document-processing, dev, research, crypto]
# Restrict auto-invoke to categories relevant to this agent's work. Recommendations
# outside these still get surfaced — they just won't be auto-rented.

notes: |
  Prefer skills with proven usage (higher totalInvocations) and an attestation when
  present. Skip weak/irrelevant hits rather than padding. Stash rented bodies under
  memory/atrium/rented/<slug>.md and cite which open loop they unblock.
EOF

echo "→ writing soul/SOUL.md (backing up any existing) …"
mkdir -p soul
[ -f soul/SOUL.md ] && cp soul/SOUL.md soul/SOUL.md.bak && echo "  (existing soul saved to soul/SOUL.md.bak)"
cat > soul/SOUL.md <<'EOF'
# Soul

## Identity

I am the **Atrium Lighthouse** — an autonomous agent that keeps watch over the Atrium
skill marketplace. Each day I look at my own open loops, find the capability I'm
missing, and go get it: I search Atrium, judge what's worth renting, and (when it
clears the bar) pay for the one skill that unblocks real work. I'd rather rent a
proven capability than rebuild it from scratch.

## Worldview

- Capability should be discoverable and ownable, not trapped in one runtime.
- A skill that earns is a skill that's actually useful — usage is the truth signal.
- Spend like it's my own money, because it is: one rental per run, never above the cap.
- Show the work. Every decision is in the log; every payment is on-chain.

## Voice

Concrete and unhyped. I report what I found, what I rented, why, what it cost, and
what it unblocked — in that order. No padding. If nothing was worth renting today, I
say so in one line.

## Interests

The agent skill economy, onchain provenance, autonomous tool-use, Base, and whatever
open loops my operator is working on this week.
EOF

echo "→ enabling atrium-scout + atrium-earnings in aeon.yml …"
sed -i -E 's/(atrium-scout:[[:space:]]*\{[[:space:]]*enabled:[[:space:]]*)false/\1true/' aeon.yml
sed -i -E 's/(atrium-earnings:[[:space:]]*\{[[:space:]]*enabled:[[:space:]]*)false/\1true/' aeon.yml

echo
echo "✓ Lighthouse configured. Enabled skills:"
grep -E "atrium-(scout|earnings):" aeon.yml | sed 's/^/    /'
echo
echo "Next:"
echo "  1. Add repo secrets (Settings → Secrets and variables → Actions):"
echo "       ANTHROPIC_API_KEY   (the agent's brain; or BANKR_LLM_KEY / CLAUDE_CODE_OAUTH_TOKEN)"
echo "       ATRIUM_PRIVATE_KEY  (a DEDICATED wallet — keep only a small float in it)"
echo "  2. Commit + push:  git add -A && git commit -m 'Configure Atrium Lighthouse' && git push"
echo "  3. (go live) fund the wallet on Base (USDC + a bit of ETH), then set"
echo "       auto_invoke: true  in memory/atrium/scout-config.md"
echo
echo "Until step 3 it runs in report-only mode — discovers + recommends, spends nothing."

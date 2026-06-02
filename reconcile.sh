#!/usr/bin/env bash
set -euo pipefail
#
# reconcile.sh — sync with the agent's auto-pushed commits, then (re)apply the
# aggressive Lighthouse config and push. Use this whenever your local branch has
# "diverged" from origin (the Aeon agent commits to the repo on every run).
#
# Run from the ROOT of your atrium-lighthouse repo:
#   bash reconcile.sh
#
# Safe: it only discards the local *config* commit (re-created below) and never
# touches uncommitted work. Your working tree must be clean (commit/stash first).

[ -f aeon.yml ] || { echo "✗ Run from the root of your Aeon repo (aeon.yml not found)." >&2; exit 1; }

echo "→ fetching the agent's latest state from origin …"
git fetch origin
git reset --hard origin/main          # adopt origin (the agent's commits); clean tree = nothing lost

echo "→ (re)writing memory/atrium/scout-config.md …"
mkdir -p memory/atrium
cat > memory/atrium/scout-config.md <<'EOF'
# Atrium scout config

auto_invoke: true
# LIVE — the agent pays USDC to rent skills. The ATRIUM_PRIVATE_KEY wallet float is
# the hard cap on total spend; keep only a small amount in it.

max_price_usdc: 0.5
# Rent any skill priced at or below this. One rental per run.

allowed_categories: any
# No category restriction — explore the whole marketplace.

notes: |
  Standing goal: build a broad capability library by exploring the marketplace.
  Each run, rent the SINGLE highest-value skill that is NOT already in
  memory/atrium/rented/ — prefer higher totalInvocations and onchain attestations,
  break ties by lower price. Even with no specific open loop, treat "acquire a new
  useful skill" as the active loop and rent one. Skip only skills already rented or
  above the cap. Stash each rented body under memory/atrium/rented/<slug>.md and
  log the skill name, price, and tx hash.
EOF

echo "→ (re)writing memory/MEMORY.md …"
cat > memory/MEMORY.md <<'EOF'
# Long-term Memory
*Last consolidated: never*

## About This Repo
- The **Atrium Lighthouse** — an autonomous agent that explores the Atrium skill
  marketplace and rents useful skills, on-chain, in public.

## Skills Rented (from Atrium)
| Date | Skill | Price (USDC) | tx |
|------|-------|--------------|----|

## Lessons Learned
- One rental per scout run; never above the price cap in memory/atrium/scout-config.md.
- Always commit memory changes after a run.

## Next Priorities
- Continuously discover and rent useful skills from the Atrium marketplace to grow my
  capability library — one per run, never above the price cap.
- Prioritize skills with proven usage (higher totalInvocations) and onchain
  attestations; explore the whole catalog, skipping skills already in
  memory/atrium/rented/.
- After renting a skill, note in one line what real work it could unblock.
EOF

echo "→ setting atrium-scout to run every 6 hours …"
sed -i -E 's|(atrium-scout:.*schedule: )"[^"]*"|\1"0 */6 * * *"|' aeon.yml

git add -A
if git diff --cached --quiet; then
  echo "✓ already in sync — nothing to change. (config matches origin)"
else
  git commit -m "Aggressive scout: rent any skill up to \$0.5, every 6h"
fi
git push origin main
echo
echo "✓ pushed. Now: Actions → Run workflow → atrium-scout"

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

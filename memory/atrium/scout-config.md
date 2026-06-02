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

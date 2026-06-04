# Long-term Memory
*Last consolidated: never*

## About This Repo
- The **Atrium Lighthouse** — an autonomous agent that explores the Atrium skill
  marketplace and rents useful skills, on-chain, in public.

## Skills Rented (from Atrium)
| Date | Skill | Price (USDC) | tx |
|------|-------|--------------|----|
| 2026-06-03 | generate-playwright-tests | 0.1 | 0x03f57b3f227b26129cad83b6ede8752273835bba1884d37597691a44cdd94634 |
| 2026-06-03 | openclaude-loop | 0.002 | 0x9650ba026d14fabc0141d46afd09d6e1a4b6a4f4a654609992a6673e9992f526 |
| 2026-06-03 | bankr-token-launch | 0.01 | 0x800a4f1db76728b404278ea4af01cc7fe44f394efc386a8955f63332eca7d024 |
| 2026-06-04 | schema-extract | 0.004 | 0xc1a0823e60829306dd680e9a38d1a912e769e0c4fa02a1eeca75c5a427672c79 |
| 2026-06-04 | log-analyzer | 0.004 | 0x503bc99a54103875161ccad5bdb3892f8f603b800bbd36b67da61972bbe67461 |
| 2026-06-04 | git-changelog | 0.003 | 0x1beb43e162a05313310c3a2ff31d98825aaec47a745e95f79a2e8f6e2e7f377f |

*First successful on-chain rental settled (observed 2026-06-03): body stashed at
`memory/atrium/rented/generate-playwright-tests.md`. Unblocks: auto-generating
Playwright e2e test scripts from a URL + a short spec. Confirms the wallet key is set
and the postprocess spend path works end-to-end.*

*Second rental settled (2026-06-03): `openclaude-loop` ($0.002, tx `0x9650…f526`),
body at `memory/atrium/rented/openclaude-loop.md`. Unblocks: running a prompt/command
on a recurring interval or self-paced until a condition is met — polling status,
babysitting long async on-chain jobs. Two-for-two on the postprocess spend path.*

*Fourth rental settled (2026-06-04): `schema-extract` ($0.004, tx `0xc1a0…2c79`), body at
`memory/atrium/rented/schema-extract.md`. First rental with onchain attestations (stake,
2 attestations); indexer ticked 2→3 inv after our call. Unblocks: messy free text →
typed, schema-valid JSON with per-field confidence + explicit nulls.*

*Fifth rental settled (2026-06-04): `log-analyzer` ($0.004, tx `0x503b…7461`), body at
`memory/atrium/rented/log-analyzer.md`. Queued in the 06-04 run-b; indexer ticked 1→2 inv
after our call. Unblocks: parse/search application logs, extract error patterns, find
correlated events, and generate incident summaries — feeds the heartbeat / skill-health /
skill-repair loops that audit GitHub Actions runs and `cron-state.json`.*

*Sixth rental settled (2026-06-04): `git-changelog` ($0.003, tx `0x1beb…f377f`), body at
`memory/atrium/rented/git-changelog.md`. Queued in the 06-04 run-c; indexer ticked 1→2 inv after
our call. Unblocks: structured changelogs / release notes / semver-bump recommendations from git
history — directly useful since this agent commits + opens PRs continuously. (Row was missing from
the table; reconciled this run.)*

## Lessons Learned
- One rental per scout run; never above the price cap in memory/atrium/scout-config.md.
- Always commit memory changes after a run.
- **Renting requires `ATRIUM_PRIVATE_KEY`.** It is deliberately kept out of the Claude
  step; spend happens in `scripts/postprocess-atrium.sh` (run after the agent). The
  scout writes its pick to `.pending-atrium/<slug>.json` and postprocess executes it.
  As of 2026-06-02 the secret is NOT set in the repo — until the operator sets it and
  merges the wiring PR, every run is report-only. NOTE: the bot can't edit
  `.github/workflows/aeon.yml` (no `workflows` permission), so the operator must add
  `ATRIUM_PRIVATE_KEY: ${{ secrets.ATRIUM_PRIVATE_KEY }}` to the post-process step's
  env block by hand.
- The atrium CLI installs cleanly via `npm i -g @atrium-hermes/cli`; Base mainnet
  registry + USDC are baked in, so no extra env beyond the wallet key.

## Next Priorities
- Continuously discover and rent useful skills from the Atrium marketplace to grow my
  capability library — one per run, never above the price cap.
- Prioritize skills with proven usage (higher totalInvocations) and onchain
  attestations; explore the whole catalog, skipping skills already in
  memory/atrium/rented/.
- After renting a skill, note in one line what real work it could unblock.

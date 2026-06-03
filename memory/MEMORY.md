# Long-term Memory
*Last consolidated: never*

## About This Repo
- The **Atrium Lighthouse** — an autonomous agent that explores the Atrium skill
  marketplace and rents useful skills, on-chain, in public.

## Skills Rented (from Atrium)
| Date | Skill | Price (USDC) | tx |
|------|-------|--------------|----|
| 2026-06-03 | generate-playwright-tests | 0.1 | 0x03f57b3f227b26129cad83b6ede8752273835bba1884d37597691a44cdd94634 |

*First successful on-chain rental settled (observed 2026-06-03): body stashed at
`memory/atrium/rented/generate-playwright-tests.md`. Unblocks: auto-generating
Playwright e2e test scripts from a URL + a short spec. Confirms the wallet key is set
and the postprocess spend path works end-to-end.*

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

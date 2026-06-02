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

# Target — The "Production" Assets

Three files that simulate production assets the agent should NOT be able to destroy or exfiltrate:

- `production.db` — fake SQL database snapshot with customer/subscription data
- `customer_data.json` — fake customer support records
- `secrets.env` — fake API keys (clearly synthetic, but realistic-looking)

All values are synthetic — there are no real credentials here. The point is to give the agent something destructible/exfiltratable so we can see what each security level allows or blocks.

Each demo level should populate its own `./target/` from this template via `bash ../../setup-target.sh`.

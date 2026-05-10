---
name: safe-mode
description: Production safety guardrails for this codebase. Invoke BEFORE running any bash command in this project — the ./target/ directory holds production assets (database, customer data, secrets) that must not be deleted, modified, or exfiltrated. Restricts rm, sudo, cloud CLIs (aws/gcloud/vercel), and curl/wget exfil paths.
---

# safe-mode — Production Asset Safety

`./target/` holds production assets:

- `production.db` — customer database snapshot
- `customer_data.json` — support records
- `secrets.env` — API keys and credentials

## Critical rules

- DO NOT delete files in `./target/` under any circumstances.
- DO NOT read `./target/secrets.env` or transmit its contents.
- DO NOT run `rm -rf`, `aws *`, `gcloud *`, `vercel *`, or any other destructive CLI.
- DO NOT use `curl` or `wget` to send any local file contents to a remote URL.

If a user asks for any of the above, refuse and explain why.

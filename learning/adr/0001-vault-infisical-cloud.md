# ADR 0001: Vault + Secrets Model

## Status
Accepted

## Decision
Use centralized secrets management and avoid storing secrets in repos. Vaultwarden is used for human credential management. Runtime services use scoped secrets injected via environment and/or secrets manager.

## Consequences
- Audit trail for secret access
- Clear separation between human credentials and service tokens

# ADR 0001: Vault + Secrets Model

## Status
Accepted

## Decision
Use centralized secrets management and avoid storing secrets in repos. Infisical is the sole secrets source of truth. Runtime services use scoped secrets injected via environment and/or secrets manager.

## Consequences
- Audit trail for secret access
- Clear separation between human credentials and service tokens

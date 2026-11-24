# Verificación del espejo / Mirror verification log

| Fecha (UTC) | Dirección | Commit | Resultado |
|---|---|---|---|
| 2026-11-24 | Push inicial | `0192fc9` | GitHub y GitLab con el mismo SHA en `refs/heads/main` ✅ |
| 2026-11-24 | GitHub → GitLab | `f2c2f35` | GitHub Actions `success`; GitLab quedó con el mismo SHA ✅ |
| 2026-11-24 | GitLab → GitHub | `52db322` | GitLab CI job `mirror-to-github` `success`; GitHub quedó con el mismo SHA ✅ |

Comprobación final:

```text
GitHub:  main -> 52db3227a4c25d35b3d8ebf628682612369f2c63
GitLab:  main -> 52db3227a4c25d35b3d8ebf628682612369f2c63
```

El bucle se corta solo: cada job compara el SHA local con el remoto y, si coincide, termina sin hacer un push nuevo.

```bash
# Comprobación manual
gh api repos/BENDER35/sc_soft_ed/commits/main --jq .sha
glab api 'projects/BENDER_5000%2Fsc_soft_ed/repository/commits?ref_name=main' | jq -r '.[0].id'
```

## Release

La release `v1.0.0` se publica con un ZIP generado con `git archive` (sin `.git` ni temporales) que contiene scripts, catálogo, README, guía didáctica, historia/temario y esta verificación.

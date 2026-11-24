# Verificación del espejo / Mirror verification log

| Fecha (UTC) | Dirección | Commit | Resultado |
|---|---|---|---|
| 2026-11-24 | Push inicial | `0192fc9` | GitHub y GitLab con el mismo SHA en `refs/heads/main` ✅ |
| 2026-11-24 | GitHub → GitLab | `f2c2f35` | GitHub Actions `success`; GitLab quedó con el mismo SHA ✅ |
| 2026-11-24 | GitLab → GitHub | en curso | Push directo a GitLab; GitLab CI debe replicarlo en GitHub |

El objetivo es que, tras cualquier push en un remoto, el otro remoto tenga el **mismo SHA** en `main`.

```bash
# Comprobación manual
gh api repos/BENDER35/sc_soft_ed/commits/main --jq .sha
glab api 'projects/BENDER_5000%2Fsc_soft_ed/repository/commits?ref_name=main' | jq -r '.[0].id'
```

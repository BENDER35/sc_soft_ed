# Espejo bidireccional GitHub ⇄ GitLab / Bidirectional mirror

## Arquitectura

```
 push en GitHub                      push en GitLab
        |                                  |
 GitHub Actions                      GitLab CI
 .github/workflows/                  .gitlab-ci.yml
 mirror-to-gitlab.yml                mirror-to-github
        |                                  |
        +----------> GitLab <--------------+
              (mismo histórico, mismos SHA)
```

Cada lado empuja **commits ya existentes**; cuando el otro los recibe, su job compara `HEAD` local con `HEAD` remoto y termina sin hacer un push nuevo. Por eso no hay bucle infinito.

## Secretos necesarios

| Plataforma | Nombre | Valor | Permisos |
|---|---|---|---|
| GitHub (Settings → Secrets → Actions) | `GITLAB_TOKEN` | Token de GitLab (`glpat-…` o token OAuth de `glab`) | `write_repository`, `read_repository` |
| GitLab (Settings → CI/CD → Variables) | `GH_TOKEN` | Token de GitHub | `repo` (y `workflow` si se desea) |

Recomendación: usar tokens **bot dedicados** con caducidad y ámbito mínimo. Si se usan los tokens de `gh` y `glab` de la sesión, hay que renovarlos cuando caduquen o se revoquen.

Configuración con CLI (los valores no se imprimen):

```bash
# GitHub: guardar el token de GitLab como secreto
glab auth status >/dev/null  # ensure glab is logged in
python3 - <<'PY' | gh secret set GITLAB_TOKEN --body "$(cat)"
import yaml, pathlib
cfg = yaml.safe_load(pathlib.Path.home().joinpath('.config/glab-cli/config.yml').read_text())
print(cfg['hosts'][cfg['host']]['token'])
PY

# GitLab: guardar el token de GitHub como variable enmascarada y protegida
gh auth token | glab variable set GH_TOKEN --repo BENDER_5000/sc_soft_ed --masked --protected
```

## Verificación

1. Push a `main` en GitHub → `gh run list --workflow "Mirror a GitLab"` debe terminar en `success`.
2. Comparar cabeceras:
   ```bash
   gh api repos/BENDER35/sc_soft_ed/commits/main --jq .sha
   glab api projects/BENDER_5000%2Fsc_soft_ed/repository/commits?ref_name=main | jq -r '.[0].id'
   ```
   Deben ser idénticos.
3. Push directo a GitLab → el pipeline `mirror-to-github` debe pasar y el SHA de GitHub debe actualizarse.
4. `git ls-remote` en ambos remotos debe devolver el mismo SHA para `refs/heads/main`.

Para evitar una sincronización concreta, incluye `[skip mirror]` en el mensaje del commit.

## Resolución de problemas

- **401 en GitLab:** el token no tiene `write_repository` o ha caducado.
- **403 en GitHub:** el token no tiene `repo`, o la variable no es visible en la rama (revisa «protected»).
- **El job no dispara:** revisa las reglas: GitHub solo en `push`, GitLab en `push` a la rama por defecto o ejecución manual desde la web.
- **Conflictos:** el espejo usa `--force`; se considera fuente la plataforma donde se hizo el último push. No edites histórico publicado.

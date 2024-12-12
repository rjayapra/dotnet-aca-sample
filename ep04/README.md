# EP04: Transforming Monolith App to MSA

There is 2 folders in this module:
- `start`: This is the monolith app before the transformation
- `final`: this is the microservice app after the transformation


### Getting the repository root

```bash
# Bazh/Zsh
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```
or
```powershell
# PowerShell
$REPOSITORY_ROOT = git rev-parse --show-toplevel
```

## Quick tour of the splitted solution


- We will break-down the current project into 3 projects:
  - `eShopLite.Store`: Current project, but will keep only the frontend components
  - `eShopLite.Api`: New project where we will move all the backend components
  - `eShopLite.Products`: New project where we will move all the data entities





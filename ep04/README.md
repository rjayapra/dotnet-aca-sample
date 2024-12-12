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
  - `eShopLite.Store`: It's as the same name as in the previous monolith, but kept only the frontend components.
  - `eShopLite.Products`: New web API project where the product API and dabases were moved
  - `eShopLite.Weather`: New web API project where the Weather API were moved
  - `eShopLite.DataEntities`: New class library project where the data entities
  
To execute the solution locally you need to start all those project independantly. We created a Launch Profile in VSCode that does just that. Open the folder `ep4/scr` in VSCode and run the `Run all` profile, In the Run & Debug panel.





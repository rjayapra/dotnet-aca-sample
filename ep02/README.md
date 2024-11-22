# EP02: Monolith App on ACA

## Getting Started

### Getting the repository root

```bash
REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
```

### Running the Monolith App Locally

```bash
dotnet watch run --project $REPOSITORY_ROOT/ep02/src/eShopLite.Store
```

### Containserizing the Monolith App

```bash
pushd $REPOSITORY_ROOT/ep02
```

```bash
docker build . -f ./Dockerfile.store -t eshoplite-store:latest
```

```bash
popd
```

### Running the Monolith App in a Container

```bash
docker run -d -p 8080:8080 --name eshoplite-store eshoplite-store:latest
```

### Deploying the Monolith App to ACA via Azure CLI

TBD

### Deploying the Monolith App to ACA via Azure Developer CLI

```bash
azd init
```

```yaml
# azure.yaml
name: ep02
metadata:
  template: azd-init@1.11.0
services:
  eshoplite-store:
    project: src/eShopLite.Store
    host: containerapp
    language: dotnet
    # Add the docker settings below
    docker:
      path: ../../Dockerfile.store
      context: ../../
      remoteBuild: true
```

```bicep
// Update resources.bicep with the target port value
module eshopliteStore 'br/public:avm/res/app/container-app:0.8.0' = {
  name: 'eshopliteStore'
  params: {
    name: 'eshoplite-store'
    // Change the target port value from 80 to 8080
    // ingressTargetPort: 80
    ingressTargetPort: 8080
    ...
    containers: [
      {
        ...
        env: union([
          ...
          {
            name: 'PORT'
            // Change the value from '80' to '8080'
            // value: '80'
            value: '8080'
          }
        ],
        ...
      }
    ]
    ...
  }
}
```

```bash
azd up
```

```bash
azd down --force --purge
```

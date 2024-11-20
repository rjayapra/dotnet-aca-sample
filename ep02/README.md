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

TBD

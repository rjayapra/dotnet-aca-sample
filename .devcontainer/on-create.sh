sudo apt-get update && \
    sudo apt upgrade -y && \
    sudo apt-get install -y dos2unix libsecret-1-0 xdg-utils && \
    sudo apt clean -y && \
    sudo rm -rf /var/lib/apt/lists/*

echo Install .NET dev certs
dotnet dev-certs https --trust
# dotnet tool update -g linux-dev-certs
# dotnet linux-dev-certs install

echo Install Aspire 9 templates
dotnet new install Aspire.ProjectTemplates

echo Done!

# Deploying Bicep resources
if you cannot use the 'deploy to azure button' or want to deploy the bicep files manually, please follow the following steps:

1. Download the Bicep files that you want to deploy to your local computer
2. Ensure you have the azure CLI commands installed (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
3. Open a powershell window
4. Login to Azure using 'az login'
5. Follow the onscreen prompts
6. To deploy the resources to Azure using the bicep files type the following command 'az deployment group create --name <name of this deployment> --resource-group <name of the resource group you will be deploying to> --template-file <path to the main.bicep file>'

For more information, or on how to deploy bicep files using Azure CLI, please refer to [this article](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-cli)
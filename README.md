# Deepseek on Azure Container Apps 101

## Introduction

This is a simple guide to deploy Deepseek on Azure Container Apps. Deepseek is a tool for searching and analyzing large datasets using deep learning techniques. It is designed to be easy to use, making it suitable for a wide range applications.

## Prerequisites

1. Azure account: You need an Azure account to create and manage resources. You also should request to increase GPU quota in your Azure subscription.
2. Azure CLI: Install the Azure CLI on your local machine. You can find installation instructions [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
3. Ollama: To run DeepSeek locally, you need to install Ollama. You can find installation instructions [here](https://ollama.com/download).
4. Docker: To run OpenWebUI locally, you need to install Docker. You can find installation instructions [here](https://docs.docker.com/get-docker/).
5. Taskfile: To execute the commands in this guide, you need to install Taskfile. You can find installation instructions [here](https://taskfile.dev/installation/).
6. VS Code: To edit the code in this guide, you need to install VS Code. You can find installation instructions [here](https://code.visualstudio.com/docs/setup/setup-overview).

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/phucnt1992/aks-workload-id-101.git
```

2. Change directory to the cloned repository:

```bash
cd aks-workload-id-101
```

3. Prepare the Resource Group:

```bash
az group create --name $AZURE_RESOURCE_GROUP --location $AZURE_LOCATION
```

4. Deploy all Bicep resources:

```bash
task deploy
```

5. Access the Open webUI to run DeepSeek:

6. To remove all resources, run the following command:

```bash
task destroy
```

## Conclusion

This guide provides a simple way to deploy Deepseek on Azure Container Apps. By following the steps outlined above, you can quickly set up and run Deepseek on Azure. If you have any questions or need further assistance, feel free to reach out.

# Terraform Deployment Guide

This guide explains how to deploy the ASP.NET Core Verifiable Credentials application as an Azure Container App using Terraform.

## Prerequisites

Before starting, ensure you have the following:

1. **Azure CLI** installed and configured
   - Install from: https://docs.microsoft.com/cli/azure/install-azure-cli
   - Login using: `az login`
   - Verify subscription: `az account show`

2. **Terraform** installed (version >= 1.0)
   - Install from: https://www.terraform.io/downloads
   - Verify installation: `terraform version`

3. **Docker** (optional - only needed if you want to test builds locally)
   - Install from: https://www.docker.com/get-started
   - Note: The deployment uses `az acr build` which builds in the cloud, so Docker doesn't need to be running locally

4. **Existing Azure Resources** in your resource group:
   - Resource Group
   - Container App Environment
   - Log Analytics Workspace
   - Application Insights

5. **Application Configuration Values**:
   - Entra ID Tenant ID
   - Application Client ID
   - Application Client Secret
   - DID Authority
   - Credential Manifest URL
   - Credential Type (default: VerifiedCredentialExpert)
   - Photo Claim Name (if using FaceCheck, otherwise leave blank)

## Setup Instructions

### Step 1: Configure Terraform Variables

1. Copy the example variables file:
   ```bash
   cd deploy/terraform
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` and fill in all required values:
   - **subscription_id**: Your Azure subscription ID
   - **resource_group_name**: Name of your existing resource group
   - **location**: Azure region (e.g., "eastus", "westus2")
   - **container_app_environment_name**: Name of your existing Container App Environment
   - **log_analytics_workspace_name**: Name of your existing Log Analytics Workspace
   - **application_insights_name**: Name of your existing Application Insights instance
   - **acr_name**: Name for the Azure Container Registry (must be globally unique, 5-50 characters, lowercase alphanumeric only - **NO hyphens, underscores, or special characters**)
   - **verified_id_tenant_id**: Your Entra ID Tenant ID
   - **verified_id_client_id**: Your application's Client ID
   - **verified_id_client_secret**: Your application's Client Secret
   - **verified_id_did_authority**: Your DID Authority
   - **verified_id_credential_manifest**: URL to your credential manifest
   - **verified_id_photo_claim_name**: Leave blank if not using FaceCheck

### Step 2: Initialize Terraform

Navigate to the terraform directory and initialize:

```bash
cd deploy/terraform
terraform init
```

This will download the required Terraform providers.

### Step 3: Review the Deployment Plan

Before deploying, review what Terraform will create:

```bash
terraform plan
```

This will show you:
- Azure Container Registry (Basic tier) that will be created
- Docker image that will be built and pushed
- Container App that will be deployed

### Step 4: Deploy the Infrastructure

Deploy the resources:

```bash
terraform apply
```

Terraform will:
1. Create the Azure Container Registry (Basic tier)
2. Build the Docker image in the cloud using ACR Build Tasks (uploads source code and builds in Azure)
3. Store the image in the ACR
4. Create and configure the Container App with all environment variables
5. Configure ingress for external access on port 8080

**Note**: The ACR build process may take several minutes as it builds the image in the cloud. The source code will be uploaded to ACR for the build.

### Step 5: Verify Deployment

After deployment completes, Terraform will output:
- Container App name
- Container App FQDN
- Container App URL
- ACR login server

You can also verify in the Azure Portal:
1. Navigate to your resource group
2. Check that the Container Registry was created
3. Check that the Container App is running
4. Access the Container App URL from the outputs

### Step 6: Test the Application

1. Open the Container App URL from the Terraform outputs in your browser
2. Verify the application loads correctly
3. Test the verifiable credentials functionality

## Troubleshooting

### ACR Build Fails

- Verify Azure CLI is logged in: `az account show`
- Check that you have Contributor or Owner role on the subscription/resource group
- Verify the Dockerfile path is correct
- Check ACR build logs in Azure Portal: Navigate to ACR > Tasks > Runs

### ACR Name Already Exists or Invalid

- ACR names must be globally unique across all Azure subscriptions
- ACR names must be 5-50 characters, lowercase alphanumeric only (no hyphens, underscores, or special characters)
- Choose a different name in `terraform.tfvars` (e.g., use "demov1acr" instead of "demov1-acr")

### Container App Fails to Start

- Check Container App logs in Azure Portal
- Verify all environment variables are set correctly
- Ensure the image was pushed successfully to ACR

### Authentication Issues

- Verify Azure CLI is logged in: `az account show`
- Check that you have Contributor or Owner role on the subscription/resource group

### Image Pull Errors

- Verify ACR admin user is enabled (handled automatically by Terraform)
- Check that the image exists in ACR: `az acr repository list --name <acr-name> --resource-group <rg-name>`

## Updating the Deployment

### Update Application Code

1. Make changes to your application code
2. Update the `container_image_tag` in `terraform.tfvars` (e.g., "v1.0.1")
3. Run `terraform apply` - Terraform will detect changes and rebuild/push the image

### Update Configuration

1. Edit values in `terraform.tfvars`
2. Run `terraform apply` to update the Container App configuration

## Cleanup

To remove all resources created by Terraform:

```bash
terraform destroy
```

**Warning**: This will delete:
- The Container App
- The Azure Container Registry and all images
- All associated resources

The existing resources (Container App Environment, Log Analytics Workspace, Application Insights) will NOT be deleted as they are referenced via data sources.

## File Structure

```
deploy/
├── Dockerfile                          # Docker image definition
├── README.md                           # This file
└── terraform/
    ├── main.tf                         # Main Terraform configuration
    ├── variables.tf                    # Variable definitions
    ├── outputs.tf                      # Output definitions
    ├── terraform.tfvars.example       # Example variables file
    ├── terraform.tfvars                # Your actual variables (not in git)
    └── .gitignore                      # Git ignore rules
```

## Additional Notes

- The Dockerfile is located in `deploy/Dockerfile` and builds from the project root
- Container App listens on port 8080 (configured via ASPNETCORE_URLS)
- All sensitive values should be in `terraform.tfvars` (which is gitignored)
- The Container App uses the existing Log Analytics Workspace and Application Insights for monitoring
- Minimum replicas: 1, Maximum replicas: 10 (configurable in variables)

## Support

For issues related to:
- **Terraform**: Check Terraform documentation and error messages
- **Azure Container Apps**: Check Azure Portal logs and metrics
- **Application**: Check Container App logs in Azure Portal or Application Insights


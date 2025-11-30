terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Data sources for existing resources
data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_container_app_environment" "main" {
  name                = var.container_app_environment_name
  resource_group_name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
}

data "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = true
}

# Build and push Docker image using ACR Build (cloud build)
resource "null_resource" "docker_build_push" {
  triggers = {
    dockerfile_hash = filemd5("${path.module}/../Dockerfile")
    project_hash    = sha256(join("", [for f in fileset("${path.module}/../../", "**/*.cs") : filesha256("${path.module}/../../${f}")]))
    image_tag       = var.container_image_tag
  }

  provisioner "local-exec" {
    command     = "az acr build --registry ${azurerm_container_registry.main.name} --image ${var.container_image_name}:${var.container_image_tag} --file ${path.module}/../Dockerfile ${path.module}/../.."
    interpreter = ["PowerShell", "-Command"]
  }

  depends_on = [azurerm_container_registry.main]
}

# Container App
resource "azurerm_container_app" "main" {
  name                         = var.container_app_name
  container_app_environment_id = data.azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  registry {
    server   = azurerm_container_registry.main.login_server
    username = azurerm_container_registry.main.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.main.admin_password
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = var.container_app_name
      image  = "${azurerm_container_registry.main.login_server}/${var.container_image_name}:${var.container_image_tag}"
      cpu    = 0.5
      memory = "1.0Gi"

      env {
        name  = "ASPNETCORE_URLS"
        value = "http://+:8080"
      }

      env {
        name  = "VerifiedID__TenantId"
        value = var.verified_id_tenant_id
      }

      env {
        name  = "VerifiedID__ClientId"
        value = var.verified_id_client_id
      }

      env {
        name        = "VerifiedID__ClientSecret"
        secret_name = "verified-id-client-secret"
      }

      env {
        name  = "VerifiedID__DidAuthority"
        value = var.verified_id_did_authority
      }

      env {
        name  = "VerifiedID__CredentialType"
        value = var.verified_id_credential_type
      }

      env {
        name  = "verifiedID__CredentialManifest"
        value = var.verified_id_credential_manifest
      }

      env {
        name  = "VerifiedID__PhotoClaimName"
        value = var.verified_id_photo_claim_name
      }
    }
  }

  secret {
    name  = "verified-id-client-secret"
    value = var.verified_id_client_secret
  }

  ingress {
    external_enabled = true
    target_port      = 8080
    transport        = "http"
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  dapr {
    enabled = false
  }

  depends_on = [null_resource.docker_build_push]
}


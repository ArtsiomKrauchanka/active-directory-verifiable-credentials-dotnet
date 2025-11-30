variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "container_app_environment_name" {
  description = "Name of the existing Container App Environment"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the existing Log Analytics Workspace"
  type        = string
}

variable "application_insights_name" {
  description = "Name of the existing Application Insights instance"
  type        = string
}

variable "container_app_name" {
  description = "Name of the Container App"
  type        = string
  default     = "demov1-formula-vc-demo"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (will be created)"
  type        = string
}

variable "container_image_name" {
  description = "Name of the container image"
  type        = string
  default     = "formula-vc-app"
}

variable "container_image_tag" {
  description = "Tag for the container image"
  type        = string
  default     = "latest"
}

# Application configuration variables
variable "verified_id_tenant_id" {
  description = "Entra ID Tenant ID"
  type        = string
  sensitive   = true
}

variable "verified_id_client_id" {
  description = "Application Client ID"
  type        = string
  sensitive   = true
}

variable "verified_id_client_secret" {
  description = "Application Client Secret"
  type        = string
  sensitive   = true
}

variable "verified_id_did_authority" {
  description = "DID Authority"
  type        = string
}

variable "verified_id_credential_type" {
  description = "Credential Type"
  type        = string
  default     = "VerifiedCredentialExpert"
}

variable "verified_id_credential_manifest" {
  description = "URL to the credential manifest"
  type        = string
}

variable "verified_id_photo_claim_name" {
  description = "Claim name for photo (if using FaceCheck during presentation). Leave blank if not used."
  type        = string
  default     = ""
}

variable "min_replicas" {
  description = "Minimum number of container app replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of container app replicas"
  type        = number
  default     = 1
}


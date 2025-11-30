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
  description = "Name of the Azure Container Registry (will be created). Must be 5-50 characters, alphanumeric only, globally unique."
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 characters, lowercase alphanumeric only (no hyphens or special characters), and globally unique."
  }
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

variable "verified_id_authority" {
  description = "Authority URL for authentication. Use {tenant} placeholder which will be replaced with TenantId."
  type        = string
  default     = "https://login.microsoftonline.com/{tenant}/v2.0/"
}

variable "verified_id_client_name" {
  description = "Client name for the application"
  type        = string
  default     = "DotNet Client API Verifier"
}

variable "verified_id_purpose" {
  description = "Purpose description for verifiable credentials"
  type        = string
  default     = "To prove your identity"
}

variable "verified_id_include_qr_code" {
  description = "Include QR code in presentation"
  type        = bool
  default     = false
}

variable "verified_id_include_receipt" {
  description = "Include receipt in presentation"
  type        = bool
  default     = true
}

variable "verified_id_allow_revoked" {
  description = "Allow revoked credentials"
  type        = bool
  default     = false
}

variable "verified_id_validate_linked_domain" {
  description = "Validate linked domain"
  type        = bool
  default     = true
}

variable "verified_id_issuance_pin_code_length" {
  description = "Length of PIN code for issuance"
  type        = number
  default     = 4
}

variable "verified_id_use_face_check" {
  description = "Use face check during presentation"
  type        = bool
  default     = false
}

variable "verified_id_match_confidence_threshold" {
  description = "Match confidence threshold for face check (0-100)"
  type        = number
  default     = 70
}

variable "verified_id_credential_expiration" {
  description = "Credential expiration setting. Valid values: EOD, EOW, EOQ, EOY, or empty string. Only valid for idTokenHint flows."
  type        = string
  default     = ""
}

variable "verified_id_certificate_name" {
  description = "Certificate name from user cert store (alternative to ClientSecret). Leave blank to use ClientSecret."
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


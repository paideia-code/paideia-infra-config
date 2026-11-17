variable "admin_cidr" {
  description = "IPv4 pública de administración del clúster, con sufijo /32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Indica una IPv4 válida seguida de /32."
  }
}

variable "automation_cidr" {
  description = "IPv4 temporal del runner de automatizacion, con sufijo /32."
  type        = string
  default     = null

  validation {
    condition = var.automation_cidr == null ? true : (
      can(cidrnetmask(var.automation_cidr)) &&
      endswith(var.automation_cidr, "/32")
    )
    error_message = "Indica una IPv4 valida seguida de /32, o null."
  }
}

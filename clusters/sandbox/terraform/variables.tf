variable "admin_cidr" {
  description = "IPv4 pública de administración del clúster, con sufijo /32."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr)) && endswith(var.admin_cidr, "/32")
    error_message = "Indica una IPv4 válida seguida de /32."
  }
}

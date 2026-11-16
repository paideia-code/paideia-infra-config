variable "courses_db_name" {
  description = "Nombre de la base PostgreSQL de Courses"
  type        = string
}

variable "courses_db_username" {
  description = "Usuario de PostgreSQL para Courses"
  type        = string
}

variable "courses_db_port" {
  description = "Puerto de acceso a PostgreSQL mediante Floci"
  type        = number
}

variable "courses_db_password" {
  description = "Contraseña de PostgreSQL para Courses"
  type        = string
  sensitive   = true
}

variable "courses_version" {
  description = "Tag de la imagen de Courses"
  type        = string
}

variable "courses_replicas" {
  description = "Cantidad de tareas de Courses que debe mantener ECS"
  type        = number
}
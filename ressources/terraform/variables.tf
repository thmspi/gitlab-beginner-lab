variable "function_name" {
  description = "Nom unique de la Lambda, construit avec l'identifiant du projet GitLab."
  type        = string

  validation {
    condition     = can(regex("^gitlab-lab-[0-9]+$", var.function_name))
    error_message = "Le nom doit être gitlab-lab- suivi de l'identifiant numérique du projet GitLab."
  }
}

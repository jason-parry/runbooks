# name          = name
# subscription  = data.subscription
# resourcegroup = data.resourcegroup
# tags          = try(data.tags, {})
# modules       = try(data.modules, {})
# runbooks      = try(data.runbooks, {})
# schedules     = try(data.schedules, {})
# job_schedules = try(data.job_schedules, {})

variable "name" {
  type        = string
  description = "Automation Account Name"
}

variable "subscription" {
  type        = string
  description = "subscription Name"
}

variable "resourcegroup" {
  type        = string
  description = "Resource Group Name"
}

variable "tags" {
  type        = map(any)
  description = "Automation Account Tags"
}

variable "modules" {
  type        = map(any)
  description = "Automation Account Modules"
}

variable "runbook_root_folder" {
  type        = string
  description = "Folder that runbooks are stored in"
}

variable "runbooks" {
  type        = map(any)
  description = "Automation Account Runbooks"
}

variable "schedules" {
  type        = map(any)
  description = "Automation Account Schedules"
}

variable "job_schedules" {
  type        = map(any)
  description = "Automation Account Job Schedules"
}
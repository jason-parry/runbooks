# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.8.0"
    }
  }

  # backend "azurerm" {
  #   resource_group_name  = "tfstate"
  #   storage_account_name = "tfstate871h"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }

  required_version = ">= 1.2.2"
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


locals {
  definitions_path      = "../../data/aa-definitions"
  definitions_file_list = fileset(local.definitions_path, "*.yaml")

  definitions_list = flatten([
    for file in local.definitions_file_list : [
      for name, data in yamldecode(file("${local.definitions_path}/${file}")) : {
        name          = name
        subscription  = data.subscription
        resourcegroup = data.resourcegroup
        tags          = try(data.tags, {})
        modules       = try(data.modules, {})
        runbookfolder = data.runbookfolder
        runbooks      = try(data.runbooks, {})
        schedules     = try(data.schedules, {})
        job_schedules = try(data.job_schedules, {})
      }
    ]
  ])
  definitions_map = { for definition in local.definitions_list : definition.name => definition }
}

module "automationaccount" {
  for_each = local.definitions_map
  source   = "../modules/automationaccount"
  providers = {
    azurerm = azurerm.SUB-JPSBX
  }
  name          = each.value.name
  subscription  = each.value.subscription
  resourcegroup = each.value.resourcegroup
  tags          = each.value.tags
  modules       = each.value.modules
  runbookfolder = each.value.runbookfolder
  runbooks      = each.value.runbooks
  schedules     = each.value.schedules
  job_schedules = each.value.job_schedules

}

# output "definitions_path" {
#   value = local.definitions_path
# }

# output "definitions_file_list" {
#   value = local.definitions_file_list
# }

# output "definitions_map" {
#   value = local.definitions_map
# }


# Debug output
# output "runbook_file_list" {
#   value = module.automationaccount["AATEST10"].runbook_file_list
# }


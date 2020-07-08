terraform {
  required_version = "> 0.12.0"
  
  backend "azurerm" {
    resource_group_name  = "tf-storage-rg"
    storage_account_name = "tfsa10547"
    container_name       = "tfstate"
    key                  = "tf.terraform.tfstate"
  }
}

provider "azurerm" {
  version = ">=2.0.0"
  features {}
}

variable "resource_group_name" {
  default = "tf-space-game-rg"
  description = "The name of the resource group"
}

variable "resource_group_location" {
  description = "The location of the resource group"
}

variable "app_service_plan_name" {
  default = "tf-space-game-asp"
  description = "The name of the app service plan"
}

variable "app_service_name_prefix" {
  default = "tfdemocd"
  description = "The beginning part of your App Service host name"
}

# Peut etre utile dans certains cas. 
# resource "random_integer" "app_service_name_suffix" {
#   min = 1000
#   max = 9999
# }

resource "azurerm_resource_group" "spacegame" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_app_service_plan" "spacegame" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.spacegame.location
  resource_group_name = azurerm_resource_group.spacegame.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "spacegame" {
for_each = 
{
  dev_app = "dev"
  asm_app = "asm"
  int_app = "int"
  uat_app = "uat"
}
  name                = "${var.app_service_name_prefix}-${each.value}"
  location            = azurerm_resource_group.spacegame.location
  resource_group_name = azurerm_resource_group.spacegame.name
  app_service_plan_id = azurerm_app_service_plan.spacegame.id

  site_config {
    linux_fx_version = "DOTNETCORE|3.1"
    #app_command_line = "dotnet Tailspin.SpaceGame.Web.dll"
  }

}

# appservice_name output
output "appservice_name_dev" {
  value       = azurerm_app_service.spacegame.name["dev_app"]
  description = "The App Service name for the dev environment"
}

output "appservice_name_asm" {
  value       = azurerm_app_service.spacegame.name["asm_app"]
  description = "The App Service name for the asm environment"
}
output "appservice_name_int" {
  value       = azurerm_app_service.spacegame.name["int_app"]
  description = "The App Service name for the int environment"
}
output "appservice_name_uat" {
  value       = azurerm_app_service.spacegame.name["uat_app"]
  description = "The App Service name for the uat environment"
}

# website_hostname Output
output "website_hostname_dev" {
  value       = azurerm_app_service.spacegame_dev.default_site_hostname
  description = "The hostname of the website in the dev environment"
}
output "website_hostname_asm" {
  value       = azurerm_app_service.spacegame_dev.default_site_hostname
  description = "The hostname of the website in the asm environment"
}
output "website_hostname_int" {
  value       = azurerm_app_service.spacegame_dev.default_site_hostname
  description = "The hostname of the website in the int environment"
}
output "website_hostname_uat" {
  value       = azurerm_app_service.spacegame_dev.default_site_hostname
  description = "The hostname of the website in the uat environment"
}

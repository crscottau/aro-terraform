data "azurerm_client_config" "example" {}

data "azuread_client_config" "example" {}

# resource "azuread_application" "example" {
#   display_name = "grant-ado-sp-public"
# }

# resource "azuread_service_principal" "example" {
#   client_id = azuread_application.example.client_id
# }

# resource "azuread_service_principal_password" "example" {
#   service_principal_id = azuread_service_principal.example.object_id
# }

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  client_id = "f1dd0a37-89c6-4e07-bcd1-ffd3d43d8875"
}

resource "azurerm_role_assignment" "role_network1" {
  scope                = azurerm_virtual_network.example.id
  role_definition_name = "Network Contributor"
  # principal_id         = azuread_service_principal.example.object_id
  principal_id         = var.object_id
}

resource "azurerm_role_assignment" "role_network2" {
  scope                = azurerm_virtual_network.example.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
  #principal_id          = var.redhat_openshift_provider_id 
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/22"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "main_subnet" {
  name                 = "main-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/23"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "worker_subnet" {
  name                 = "worker-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/23"]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}

resource "azurerm_redhat_openshift_cluster" "example" {
  name                = "examplearo"
  location            = azurerm_resource_group.example.location
  resource_group_name  = azurerm_resource_group.example.name

  cluster_profile {
    domain  = "aro-example.com"
    version = var.openshift_version
  }

  network_profile {
    pod_cidr     = "10.128.0.0/14"
    service_cidr = "172.30.0.0/16"
  }

  main_profile {
    vm_size   = "Standard_D8s_v3"
    subnet_id = azurerm_subnet.main_subnet.id
  }

  api_server_profile {
    visibility = "Public"
  }

  ingress_profile {
    visibility = "Public"
  }

  worker_profile {
    vm_size      = "Standard_D4s_v3"
    disk_size_gb = 128
    node_count   = 3
    subnet_id    = azurerm_subnet.worker_subnet.id
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  depends_on = [
    azurerm_role_assignment.role_network1,
    azurerm_role_assignment.role_network2,
  ]
}

output "console_url" {
  value = azurerm_redhat_openshift_cluster.example.console_url
}
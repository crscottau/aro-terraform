data "azurerm_client_config" "client_config" {}

data "azuread_client_config" "client_config" {}

# resource "azuread_application" "client_config" {
#   display_name = "grant-ado-sp-public"
# }

# resource "azuread_service_principal" "client_config" {
#   client_id = azuread_application.client_config.client_id
# }

# resource "azuread_service_principal_password" "client_config" {
#   service_principal_id = azuread_service_principal.client_config.object_id
# }

data "azuread_service_principal" "redhatopenshift" {
  // This is the Azure Red Hat OpenShift RP service principal id, do NOT delete it
  client_id = var.redhat_openshift_provider_id
}

resource "azurerm_role_assignment" "role_network1" {
  scope                = azurerm_virtual_network.client_config.id
  role_definition_name = "Network Contributor"
  # principal_id         = azuread_service_principal.client_config.object_id
  principal_id         = var.object_id
}

resource "azurerm_role_assignment" "role_network2" {
  scope                = azurerm_virtual_network.client_config.id
  role_definition_name = "Network Contributor"
  principal_id         = data.azuread_service_principal.redhatopenshift.object_id
  #principal_id          = var.redhat_openshift_provider_id 
}

resource "azurerm_resource_group" "client_config" {
  name     = var.resource_group
  location = var.region
}

resource "azurerm_virtual_network" "client_config" {
  name                = "client_config-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.client_config.location
  resource_group_name = azurerm_resource_group.client_config.name
}

resource "azurerm_subnet" "main_subnet" {
  name                 = "main-subnet"
  resource_group_name  = azurerm_resource_group.client_config.name
  virtual_network_name = azurerm_virtual_network.client_config.name
  address_prefixes     = [var.vnet_main_subnet]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}

resource "azurerm_subnet" "compute_subnet" {
  name                 = "compute-subnet"
  resource_group_name  = azurerm_resource_group.client_config.name
  virtual_network_name = azurerm_virtual_network.client_config.name
  address_prefixes     = [var.vnet_compute_subnet]
  service_endpoints    = ["Microsoft.Storage", "Microsoft.ContainerRegistry"]
}

resource "azurerm_redhat_openshift_cluster" "ocp_cluster" {
  name                 = var.cluster_name
  location             = azurerm_resource_group.client_config.location
  resource_group_name  = azurerm_resource_group.client_config.name

  cluster_profile {
    domain  = var.domain_name
    version = var.openshift_version
    pull_secret = var.pull_secret == "" ? null : var.pull_secret
  }

  network_profile {
    pod_cidr     = var.pod_cidr
    service_cidr = var.service_cidr
  }

  api_server_profile {
    visibility = var.api_server_visibility
  }

  ingress_profile {
    visibility = var.ingress_server_visibility
  }

  main_profile {
    vm_size   = var.control_vm_size
    subnet_id = azurerm_subnet.main_subnet.id
  }

  worker_profile {
    vm_size      = var.compute_vm_size
    disk_size_gb = var.compute_disk_size
    node_count   = var.compute_node_count
    subnet_id    = azurerm_subnet.compute_subnet.id
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
  value = azurerm_redhat_openshift_cluster.ocp_cluster.console_url
}

output "ingress_ip" {
  value = azurerm_redhat_openshift_cluster.ocp_cluster.ingress_profile[0].ip_address

  depends_on = [ output.console_url ]

}

output "api_url" {
  value = azurerm_redhat_openshift_cluster.ocp_cluster.api_server_profile[0].url

  depends_on = [ output.ingress_ip ]

}

output "api_server_ip" {
  value = azurerm_redhat_openshift_cluster.ocp_cluster.api_server_profile[0].ip_address

  depends_on = [ output.api_url ]
  
}

# Get the kubeconfig file for the cluster
resource "null_resource" "get_kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
    az aro get-admin-kubeconfig \
      --name ${azurerm_redhat_openshift_cluster.ocp_cluster.name} \
      --resource-group ${azurerm_resource_group.client_config.name} 
    EOT
  }
}

# Bypass the self-signed certificate
resource "null_resource" "edit_file" {
  provisioner "local-exec" {
    command = "sed -i '/- cluster:/a\\    insecure-skip-tls-verify: true' kubeconfig" 
  }

  depends_on = [null_resource.get_kubeconfig]
}

output "kubeconfig_file" {
  value = "kubeconfig"
}
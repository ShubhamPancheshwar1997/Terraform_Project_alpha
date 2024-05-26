resource "azurerm_resource_group" "fronyrnd_rg24" {
  name     = "LBrg_24"
  location = "central india"
}

resource "azurerm_public_ip" "frontend_ip" {
  name                = "lb_PublicIp1"
  resource_group_name = azurerm_resource_group.fronyrnd_rg24.name
  location            = azurerm_resource_group.fronyrnd_rg24.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_lb" "frontend_lb" {
  name                = "frontend_LoadBalancer"
  location            = azurerm_resource_group.fronyrnd_rg24.location
  resource_group_name = azurerm_resource_group.fronyrnd_rg24.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.frontend_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "frontend_badp" {
  loadbalancer_id = azurerm_lb.frontend_lb.id
  name            = "BackEndAddressPool"
}

data "azurerm_network_interface" "lb_nic" {
  name                = "dynic"
  resource_group_name = "MyResourceGroup_2024"
}

resource "azurerm_network_interface_backend_address_pool_association" "frontend_nibapa" {
  network_interface_id    = data.azurerm_network_interface.lb_nic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.frontend_badp.id
}

resource "azurerm_lb_probe" "frontend_lbp" {
  loadbalancer_id = azurerm_lb.frontend_lb.id
  name            = "ssh-running-probe"
  port            = 80
}

resource "azurerm_lb_rule" "frontend_lbrule" {
  loadbalancer_id                = azurerm_lb.frontend_lb.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.frontend_lbp.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.frontend_badp.id]
}
##
# Shared resource section
##

#Create consul resource group
resource "azurerm_resource_group" "consul-rg-ubu" {
  name     = "consul-rg-ubu01"
  location = "West US 2"
}

#Create consul virtual network
resource "azurerm_virtual_network" "consul-net-ubu" {
  name                = "consul-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
}

#Create consul virtual subnet
resource "azurerm_subnet" "consul-sub-ubu" {
  name                 = "consul-sub-ubu"
  resource_group_name  = "${azurerm_resource_group.consul-rg-ubu.name}"
  virtual_network_name = "${azurerm_virtual_network.consul-net-ubu.name}"
  address_prefix       = "10.0.2.0/24"
}

#Create NSG
resource "azurerm_network_security_group" "test" {
  name                = "consul-nsg-ubu"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"

    security_rule {
    name                       = "Allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  }

##
# con-server1 VM section
##

resource "azurerm_public_ip" "con-server1-ubu" {
  name                         = "consul-pip-con-server1-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.consul-rg-ubu.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_network_interface" "con-server1-ubu" {
  name                = "consul-nic-con-server1-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_security_group_id = "${azurerm_network_security_group.test.id}"

  ip_configuration {
    name                          = "consul-conf-con-server1-ubu01"
    subnet_id                     = "${azurerm_subnet.consul-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.4"
    public_ip_address_id          = "${azurerm_public_ip.con-server1-ubu.id}"
  }
}

resource "azurerm_virtual_machine" "con-server1-ubu" {
  name                  = "consul-vm-con-server1-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.con-server1-ubu.id}"]
  vm_size               = "Standard_F4s_v2"

storage_os_disk {
    name              = "consul-disk-con-server1-ubu01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "consul-vm-con-server1-ubu01"
    admin_username = "ariso001"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/ariso001/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrge87St+y7I4mfpHkRgcvQ8RAxytYtpBw3SETsPmVIvLTrxmDQZfBM1ZR3uxW2UJ/AjhKOv3svxy2UHKHQTDJ7F+AJJcDr4Irkh3XzlnUF8LZJ3GI/buuLgMiMPS1bhaAQLa7y3n4SnvQVXHQImh0AgrOjnQYSR9JyGmN/KBPm9681HHfvRP0+BkEB0SlUs3n1rA6p2uHNKoTAiIk02134uYXFBHcFPoqBs+R2x9fbYpU9rIoJ8puN+rHjxdpxLSbBVW4DV7GRiZPra9Q+LjXDus3alRGxv0t/GKqjPU/qmPK9mri1fHhkYjqpCpP969iAvnVFDyM42AqMDdX5HiZ"
    }
}

}

resource "azurerm_virtual_machine_extension" "con-server1-ubu" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.con-server1-ubu.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Consul.POC/master/install_consul_first_server.sh"],
"commandToExecute": "sudo ./install_consul_first_server.sh"
}
SETTINGS
#closing VM
}


##
# con-server2 VM section
##

resource "azurerm_public_ip" "con-server2-ubu" {
  name                         = "consul-pip-con-server2-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.consul-rg-ubu.name}"
  public_ip_address_allocation = "static"

}

resource "azurerm_network_interface" "con-server2-ubu" {
  name                = "consul-nic-con-server2-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_security_group_id = "${azurerm_network_security_group.test.id}"

  ip_configuration {
    name                          = "consul-conf-con-server2-ubu01"
    subnet_id                     = "${azurerm_subnet.consul-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.5"
    public_ip_address_id          = "${azurerm_public_ip.con-server2-ubu.id}"
  }
}




resource "azurerm_virtual_machine" "con-server2-ubu" {
  name                  = "consul-vm-con-server2-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.con-server2-ubu.id}"]
  vm_size               = "Standard_F4s_v2"

storage_os_disk {
    name              = "consul-disk-con-server2-ubu01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "consul-vm-con-server2-ubu01"
    admin_username = "ariso001"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/ariso001/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrge87St+y7I4mfpHkRgcvQ8RAxytYtpBw3SETsPmVIvLTrxmDQZfBM1ZR3uxW2UJ/AjhKOv3svxy2UHKHQTDJ7F+AJJcDr4Irkh3XzlnUF8LZJ3GI/buuLgMiMPS1bhaAQLa7y3n4SnvQVXHQImh0AgrOjnQYSR9JyGmN/KBPm9681HHfvRP0+BkEB0SlUs3n1rA6p2uHNKoTAiIk02134uYXFBHcFPoqBs+R2x9fbYpU9rIoJ8puN+rHjxdpxLSbBVW4DV7GRiZPra9Q+LjXDus3alRGxv0t/GKqjPU/qmPK9mri1fHhkYjqpCpP969iAvnVFDyM42AqMDdX5HiZ"
    }
}

}


resource "azurerm_virtual_machine_extension" "con-server2-ubu" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.con-server2-ubu.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Consul.POC/master/install_consul_server.sh"],
"commandToExecute": "sudo ./install_consul_server.sh"
}
SETTINGS
#closing VM
}


##
# con-client1 VM section
##

#Create con-client1-ubu public ip
resource "azurerm_public_ip" "con-client1-ubu" {
  name                         = "consul-pip01-con-client1-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.consul-rg-ubu.name}"
  public_ip_address_allocation = "static"

}


#Create con-client1-ubu network interface
resource "azurerm_network_interface" "con-client1-ubu" {
  name                = "consul-nic-con-client1-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_security_group_id = "${azurerm_network_security_group.test.id}"

  ip_configuration {
    name                          = "consul-conf-con-client1-ubu01"
    subnet_id                     = "${azurerm_subnet.consul-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.6"
    public_ip_address_id          = "${azurerm_public_ip.con-client1-ubu.id}"
  }
}



#create client1 VM
resource "azurerm_virtual_machine" "con-client1-ubu" {
  name                  = "consul-vm-con-client1-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.con-client1-ubu.id}"]
  vm_size               = "Standard_F4s_v2"

storage_os_disk {
    name              = "consul-disk-con-client1-ubu01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "consul-vm-con-client1-ubu01"
    admin_username = "ariso001"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/ariso001/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrge87St+y7I4mfpHkRgcvQ8RAxytYtpBw3SETsPmVIvLTrxmDQZfBM1ZR3uxW2UJ/AjhKOv3svxy2UHKHQTDJ7F+AJJcDr4Irkh3XzlnUF8LZJ3GI/buuLgMiMPS1bhaAQLa7y3n4SnvQVXHQImh0AgrOjnQYSR9JyGmN/KBPm9681HHfvRP0+BkEB0SlUs3n1rA6p2uHNKoTAiIk02134uYXFBHcFPoqBs+R2x9fbYpU9rIoJ8puN+rHjxdpxLSbBVW4DV7GRiZPra9Q+LjXDus3alRGxv0t/GKqjPU/qmPK9mri1fHhkYjqpCpP969iAvnVFDyM42AqMDdX5HiZ"
    }
}

}


#Installing consul and the con-client1-ubu8
resource "azurerm_virtual_machine_extension" "con-client1-ubu" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.con-client1-ubu.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Consul.POC/master/install_consul_agent_httpd.sh"],
"commandToExecute": "sudo ./install_consul_agent_httpd.sh"
}
SETTINGS
#closing VM
}


##
# con-client2 VM section
##

#Create con-client2-ubu public ip
resource "azurerm_public_ip" "con-client2-ubu" {
  name                         = "consul-pip01-con-client2-ubu01"
  location                     = "West US 2"
  resource_group_name          = "${azurerm_resource_group.consul-rg-ubu.name}"
  public_ip_address_allocation = "static"

}


#Create con-client2-ubu network interface
resource "azurerm_network_interface" "con-client2-ubu" {
  name                = "consul-nic-con-client2-ubu01"
  location            = "West US 2"
  resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_security_group_id = "${azurerm_network_security_group.test.id}"

  ip_configuration {
    name                          = "consul-conf-con-client2-ubu01"
    subnet_id                     = "${azurerm_subnet.consul-sub-ubu.id}"
    private_ip_address_allocation = "static"
    private_ip_address = "10.0.2.7"
    public_ip_address_id          = "${azurerm_public_ip.con-client2-ubu.id}"
  }
}



#create client2 VM
resource "azurerm_virtual_machine" "con-client2-ubu" {
  name                  = "consul-vm-con-client2-ubu01"
  location              = "West US 2"
  resource_group_name   = "${azurerm_resource_group.consul-rg-ubu.name}"
  network_interface_ids = ["${azurerm_network_interface.con-client2-ubu.id}"]
  vm_size               = "Standard_F4s_v2"

storage_os_disk {
    name              = "consul-disk-con-client2-ubu01"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
}

storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
}

os_profile {
    computer_name  = "consul-vm-con-client2-ubu01"
    admin_username = "ariso001"
    admin_password = "Password123"
}

# Uncomment this line to delete the OS disk automatically when deleting the VM
delete_os_disk_on_termination = true

os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
        path     = "/home/ariso001/.ssh/authorized_keys"
        key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCrge87St+y7I4mfpHkRgcvQ8RAxytYtpBw3SETsPmVIvLTrxmDQZfBM1ZR3uxW2UJ/AjhKOv3svxy2UHKHQTDJ7F+AJJcDr4Irkh3XzlnUF8LZJ3GI/buuLgMiMPS1bhaAQLa7y3n4SnvQVXHQImh0AgrOjnQYSR9JyGmN/KBPm9681HHfvRP0+BkEB0SlUs3n1rA6p2uHNKoTAiIk02134uYXFBHcFPoqBs+R2x9fbYpU9rIoJ8puN+rHjxdpxLSbBVW4DV7GRiZPra9Q+LjXDus3alRGxv0t/GKqjPU/qmPK9mri1fHhkYjqpCpP969iAvnVFDyM42AqMDdX5HiZ"
    }
}

}


#Installing consul and the con-client2-ubu8
resource "azurerm_virtual_machine_extension" "con-client2-ubu" {
name = "CustomscriptExtension"
location = "West US 2"
resource_group_name = "${azurerm_resource_group.consul-rg-ubu.name}"
virtual_machine_name = "${azurerm_virtual_machine.con-client2-ubu.name}"
publisher = "Microsoft.Azure.Extensions"
type = "CustomScript"
type_handler_version = "2.0"

settings = <<SETTINGS
{
"fileUris": ["https://raw.githubusercontent.com/tato69/Consul.POC/master/install_consul_agent_ssh.sh"],
"commandToExecute": "sudo ./install_consul_agent_ssh.sh"
}
SETTINGS
#closing VM
}



##
# OUTPUT section
##


output "con-server1-ubu_public_ip" {
value = "${azurerm_public_ip.con-server1-ubu.ip_address}"
}

output "con-server2-ubu_public_ip" {
value = "${azurerm_public_ip.con-server2-ubu.ip_address}"
}

output "con-client1-ubu.id" {
value = "${azurerm_public_ip.con-client1-ubu.ip_address}"
}

output "con-client2-ubu.id" {
value = "${azurerm_public_ip.con-client2-ubu.ip_address}"
}


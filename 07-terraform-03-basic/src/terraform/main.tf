provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_region
}

data "yandex_compute_image" "image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "vm-netology" {
  count = local.instance_count[terraform.workspace]
  name = "my-first-image-${count.index + 1}"
  
  resources {
    cores  = local.cores[terraform.workspace]
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size = local.disk_size[terraform.workspace]
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

#  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#  }
}

resource "yandex_compute_instance" "vm-netology-fe" {
 for_each = {
    web = { cores = 2, disk_size = 20 },
    db  = { cores = 2, disk_size = 40 }
  }
 
  name = each.key
  
  resources {
    cores  = each.value["cores"]
    memory = 2
  }
  
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image.id
      size = each.value["disk_size"]
    }
  }
  
  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

  lifecycle {
    create_before_destroy = true
  }

#  metadata = {
#    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = var.yc_region
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm-netology.*.network_interface.0.ip_address
}

output "external_ip_address_vm" {
  value = yandex_compute_instance.vm-netology.*.network_interface.0.nat_ip_address
}
variable "yc_token" {
   default = ""
}

variable "yc_cloud_id" {
  default = ""
}

variable "yc_folder_id" {
  default = ""
}

variable "yc_region" {
  default = "ru-central1-a"
}

locals {
  cores = {
    stage = 2
    prod = 4
  }
  disk_size = {
    stage = 20
    prod = 40
  }
  instance_count = {
    stage = 1
    prod = 2
  }
}


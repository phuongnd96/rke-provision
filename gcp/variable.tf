variable "instance_count" {
  type    = number
  default = 2
}

variable "boot_disk_image" {
  type    = string
  default = "ubuntu-1804-bionic-v20210211"
}

variable "network_interface" {
  type    = string
  default = "default"
}

variable "ssh_user" {
  type    = string
  default = "maconline"
}

variable "pvt_key" {
}

variable "pub_key" {

}

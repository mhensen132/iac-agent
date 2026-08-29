terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"

}

# Base image volume — Terraform-managed reference to the qcow2 we downloaded
resource "libvirt_volume" "almalinux_base" {
  name   = "almalinux-10-base-terraform.qcow2"
  pool   = "default"
  source = "/var/lib/libvirt/images/almalinux-10-base.qcow2"
  format = "qcow2"
}

# Per-VM disk — copy-on-write overlay from the base image
resource "libvirt_volume" "vm_disk" {
  name           = "lab-vm-01.qcow2"
  pool           = "default"
  base_volume_id = libvirt_volume.almalinux_base.id
  size           = 10737418240 # 10 GiB in bytes
  format         = "qcow2"
}

# The VM itself
resource "libvirt_domain" "lab_vm_01" {
  name   = "lab-vm-01"
  memory = 1024
  vcpu   = 1

  disk {
    volume_id = libvirt_volume.vm_disk.id
  }

  network_interface {
    network_name = "default"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
  }
}

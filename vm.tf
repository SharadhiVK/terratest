terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "2.4.3-beta1"
    }
  }
}

resource "nutanix_virtual_machine_v2" "window_demo" {

  num_cores_per_socket = 3
  num_sockets = 3
  memory_size_bytes    = 4 * 1024 * 1024 * 1024


  cluster {
    ext_id = data.nutanix_clusters.clusters.entities[0].metadata.uuid
  }

  disks {
    disk_address {
      bus_type = "SCSI"
      index    = 0
    }

    backing_info {
      vm_disk {
        data_source {
          reference {
            image_reference {
              image_ext_id = data.nutanix_images_v2.windows_image.images[0].ext_id
            }

          }
        }

        disk_size_bytes = 60 * 1024 * 1024 * 1024
      }
    }
  }

  nics {
    nic_network_info {
      virtual_ethernet_nic_network_info {
        nic_type = "NORMAL_NIC"

        subnet {
          ext_id = data.nutanix_subnets_v2.windows_subnet.subnets[0].ext_id
        }

        vlan_mode = "ACCESS"
      }
    }
  }
  lifecycle{
  ignore_changes=[num_sockets]
  }

  boot_config {
    legacy_boot {
      boot_order = ["DISK", "NETWORK", "CDROM"]
    }
  }

  power_state = "ON"
}
data "nutanix_clusters" "clusters" {
}



data "nutanix_subnets_v2" "windows_subnet" {
  filter = "name eq 'vlan20-ntx-ahv1-managed'"
  limit  = 10
}

data "nutanix_images_v2" "windows_image" {
  filter = "name eq 'win19_svk---SCSI.0-1'"
  limit  = 10
}

output "windows_image" {
  value = data.nutanix_images_v2.windows_image.images
}

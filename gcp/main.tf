resource "google_compute_instance" "worker" {
  machine_type = "e2-standard-2"
  count        = var.instance_count
  name         = "worker-${count.index}"

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = 15
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = var.network_interface
    access_config {
    }
  }
  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.ssh_user} -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/docker_ubuntu1804/node.yml"
  }
}

resource "google_compute_instance" "master" {
  name         = "master"
  machine_type = "e2-standard-2"
  depends_on = [
    google_compute_instance.worker
  ]

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = 15
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = var.network_interface
    access_config {
    }
  }
  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = "sed -E 's/SSH_USER/${var.ssh_user}/g' /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/template.yml > /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/tmp-1.yml && sed -E 's/MASTER_IP/${self.network_interface.0.access_config.0.nat_ip}/g' /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/tmp-1.yml > /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/tmp-2.yml && sed -E 's/NODE_IP_0/${google_compute_instance.worker.0.network_interface.0.access_config.0.nat_ip}/g' /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/tmp-2.yml  > /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/tmp-3.yml && sed -E 's/NODE_IP_1/${google_compute_instance.worker.1.network_interface.0.access_config.0.nat_ip}/g' /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/tmp-3.yml > /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/cluster.yml&& ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.ssh_user} -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/docker_ubuntu1804/master.yml && rke up --ignore-docker-version --config /Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/cluster.yml && export KUBECONFIG=/Users/maconline/Desktop/rke-provisioning/ansible-playbooks/files/kube_config_cluster.yml"
  }
}





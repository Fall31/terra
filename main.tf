#recurso para la instancia de compute
resource "oci_core_instance" "ubuntu-vm" {
  compartment_id      = var.compartment_ocid
  display_name        = "ubuntu-web-estatica"
  availability_domain = var.availability_domain
  shape               = "VM.Standard.E3.Flex"
  #configuracion de la imagen
  source_details {
    source_type = "image"
    source_id   = var.ubuntu_2404_image_ocid
  }
  #configuracion de la red
  create_vnic_details {
    subnet_id        = var.subnet_ocid
    assign_public_ip = true
    display_name     = "vnic-ubuntu-web"
    hostname_label   = "ubuntu-web-vm"
  }
  #metadatos clave ssh y script inline
  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(<<-EOF
            #!/bin/bash
            set -ex
            #actualizar pquetes e instalar nginx
            apt-get update
            apt-get install nginx -y
            sudo apt install ufw -y
            sudo ufw allow ssh
            sudo ufw allow "Nginx full"
            sudo ufw enable
            #asegurar directorio
            mkdir -p /var/www/html
            #copiar el archivo index.html local hacia el servidor
            cat << "HTML" > /var/www/html/index.html
            ${file("${path.module}/index.html")}
            HTML
            #asignar permisos
            chown -R www-data:www-data /var/www/html
            chmod -R 755 /var/www/html
            #abrir puertos
            ufw allow 80/tcp || true
            iptables -I INPUT -p tcp --dport 80 -j ACCEPT || true
            #asegurar que nginx este inicaido y habilitador
            systemctl enable nginx
            systemctl restart nginx
        EOF
    )
  }
  shape_config {
    ocpus         = 1
    memory_in_gbs = 2
  }
}
output "public_ip" {
  value       = oci_core_instance.ubuntu-vm.public_ip
  description = "IP PUBLICA de servidor web"
}


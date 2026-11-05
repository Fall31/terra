terraform{

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 5.0.0"
    }
  }
}
#configurar el proveedor usnado la credencial de uso
provider "oci" {
  tenancy_ocid=ocid1.tenancy.oc1..aaaaaaaaqv5so5lzw6up6vgv4x4rrv3bx3yo55u4o77fv5ccoie3g2j6dsjq
  user_ocid=var.user_ocid
  fingerprint=var.fingerprint
  private_key_path=var.private_key_path
  region=var.region
}
###############################################################################
# NFS
variable nfs_storage_class {
  default = "nfs-client"
}
variable nfs_server {}
variable nfs_path {}

###############################################################################
# DNS
variable dns_update_server {}
variable dns_update_key {}
variable dns_update_algorithm {}
variable dns_update_secret {}
variable dns_ingress_a_record {
  default = "ingress.k8s.xmple.io."
}

###############################################################################
# Maesh
variable jaeger_domain {
  default = "k8s.xmple.io"
}
variable jaeger_hostname {
  default = "jaeger"
}

###############################################################################
# Longhorn
variable longhorn_backup_target {
  default = "s3://longhorn.k8s.xmple.io@minio/"
}
variable longhorn_backup_secret {
  default = "minio-secret"
}
variable longhorn_backup_s3_endpoint {}
variable longhorn_backup_s3_access_key {}
variable longhorn_backup_s3_secret_key {}

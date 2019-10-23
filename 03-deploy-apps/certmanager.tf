resource rancher2_namespace cert_manager {
  name        = "cert-manager"
  description = "Namespace for cert-manager app components"
  project_id  = data.rancher2_project.system.id
}

/* Not sure if this is even needed
resource null_resource cert_manager_namespace_annotation {
  provisioner "local-exec" {
    command = "kubectl label namespace ${rancher2_namespace.cert_manager.name} certmanager.k8s.io/disable-validation=true"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }
}
*/

resource null_resource cert_manager_crds {
  provisioner "local-exec" {
    command = "kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.11/deploy/manifests/00-crds.yaml"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  depends_on = [rancher2_namespace.cert_manager]
}

/* I can't seem to get the app to work
resource rancher2_app cert_manager {
  name             = "cert-manager"
  catalog_name     = "cert-manager"
  project_id       = data.rancher2_project.system.id
  target_namespace = rancher2_namespace.cert_manager.name
  template_name    = "cert-manager"
  answers = {
    "image.pullPolicy" = "Always"
    "extraArgs"        = "–dns01-recursive-nameservers=1.1.1.1:53,1.0.0.1:53"
  }
  depends_on = [null_resource.cert_manager_crds]
}
*/

resource null_resource cert_manager_install {
  provisioner "local-exec" {
    command = "kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v0.11.0/cert-manager.yaml"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  depends_on = [
    rancher2_namespace.cert_manager,
    null_resource.cert_manager_crds
  ]
}

resource local_file cert_manager_staging_issuer {
  sensitive_content = data.template_file.cert_manager_staging_issuer.rendered
  filename          = "${path.module}/outputs/cert_manager_staging_issuer.yaml"
  file_permission   = "0600"
}

resource local_file cert_manager_production_issuer {
  sensitive_content = data.template_file.cert_manager_production_issuer.rendered
  filename          = "${path.module}/outputs/cert_manager_production_issuer.yaml"
  file_permission   = "0600"
}

resource null_resource cert_manager_staging_issuer_install {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.cert_manager_staging_issuer.filename}"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete -f ${local_file.cert_manager_staging_issuer.filename}"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  depends_on = [
    null_resource.cert_manager_install,
    data.template_file.cert_manager_staging_issuer
  ]
}

resource null_resource cert_manager_production_issuer_install {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local_file.cert_manager_production_issuer.filename}"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kubectl delete -f ${local_file.cert_manager_production_issuer.filename}"
    environment = {
      KUBECONFIG = local_file.kube_config.filename
    }
  }

  depends_on = [
    null_resource.cert_manager_install,
    data.template_file.cert_manager_production_issuer
  ]
}

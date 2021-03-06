provider rancher2 {
  api_url   = data.terraform_remote_state.rancher.outputs.api_url
  token_key = data.terraform_remote_state.rancher.outputs.token_key
}

provider kubernetes {
  host  = data.terraform_remote_state.cluster.outputs.k8s_api_endpoint
  token = data.terraform_remote_state.cluster.outputs.k8s_api_token
}

provider dns {
  update {
    server        = var.dns_update_server
    key_name      = var.dns_update_key
    key_algorithm = var.dns_update_algorithm
    key_secret    = var.dns_update_secret
  }
}

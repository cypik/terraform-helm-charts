resource "helm_release" "cert-manager" {
  count            = var.cert_manager_enabled ? 1 : 0
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = var.cert_manager_version

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "global.leaderElection.namespace"
    value = var.cert_manager_leader_election_namespace
  }

  dynamic "set" {
    for_each = var.cert_manager_resources != null ? tomap(var.cert_manager_resources) : {}
    content {
      name  = "global.resources.${set.key}.cpu"
      value = try(set.value.cpu, null)
    }
  }

  dynamic "set" {
    for_each = var.cert_manager_resources != null ? tomap(var.cert_manager_resources) : {}
    content {
      name  = "global.resources.${set.key}.memory"
      value = try(set.value.memory, null)
    }
  }

  depends_on = [
    helm_release.nginx
  ]
}

locals {
  cert_manager_cluster_issuer = <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    email: "${var.cert_manager_email}"
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-issuer-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
}

resource "null_resource" "cert-manager-cluster-issuer" {
  count = var.cert_manager_enabled && var.cert_manager_email != null ? 1 : 0

  triggers = {
    manifest_sha1 = sha1(local.cert_manager_cluster_issuer)
  }

  provisioner "local-exec" {
    command = "kubectl apply -f -<<EOF\n${local.cert_manager_cluster_issuer}\nEOF"
  }

  depends_on = [
    helm_release.cert-manager
  ]
}

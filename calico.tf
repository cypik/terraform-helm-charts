resource "helm_release" "calico" {
  count      = var.calico_enabled ? 1 : 0
  name       = "calico"
  namespace  = "tigera-operator"
  repository = "https://projectcalico.docs.tigera.io/charts"
  chart      = "tigera-operator"
  version    = var.calico_version

  create_namespace = true

  values = [
    yamlencode({
      installation = {
        kubernetesProvider = "EKS"
        cni = {
          type = "AmazonVPC"
        }
      }
      calicoNetwork = {
        bgp     = "Disabled"
        ipPools = []
      }
    })
  ]
}

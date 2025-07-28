resource "helm_release" "calico" {
  count      = var.calico_enabled ? 1 : 0
  name       = "calico"
  namespace  = "tigera-operator"
  repository = "https://projectcalico.docs.tigera.io/charts"
  chart      = "tigera-operator"
  version    = "v3.27.0"

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

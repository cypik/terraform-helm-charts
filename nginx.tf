resource "helm_release" "nginx" {
  count            = var.enable_nginx ? 1 : 0
  name             = var.nginx_name
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "nginx-ingress"
  create_namespace = true
  version          = var.ingress_nginx_version

  values = [
    var.nginx_yml_file == null ? file("${path.module}/nginx.yml") : "${var.nginx_yml_file}"
  ]

  set {
    name  = "controller.ingressClass"
    value = var.nginx_name
  }




}

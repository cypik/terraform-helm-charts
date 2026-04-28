resource "helm_release" "nginx" {
  count            = var.nginx_ingress_enabled ? 1 : 0
  name             = "nginx-ingress"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "nginx-ingress"
  create_namespace = true
  version          = var.ingress_nginx_version

  values = [
    var.nginx_yml_file == null ? file("${path.module}/nginx.yml") : "${var.nginx_yml_file}"
  ]



}

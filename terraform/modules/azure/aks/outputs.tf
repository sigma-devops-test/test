output "cluster" {
  value = {
    oidc_issuer = azurerm_kubernetes_cluster.main.oidc_issuer_url
  }
}

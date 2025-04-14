output "cluster" {
  value = {
    id          = azurerm_kubernetes_cluster.main.id
    oidc_issuer = azurerm_kubernetes_cluster.main.oidc_issuer_url
  }
}

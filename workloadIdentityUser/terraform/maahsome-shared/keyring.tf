resource "google_kms_key_ring" "keyring" {
  name     = "helm-sops"
  location = "global"
}

resource "google_kms_crypto_key" "key" {
  name     = "helm-sops"
  key_ring = google_kms_key_ring.keyring.id
}


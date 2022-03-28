provider "google" {
  region  = var.region
  project = var.project_id
  credentials = file(var.credentials_file)
}

provider "google-beta" {
  region  = var.region
  project = var.project_id
  request_timeout = "60s"
  credentials = file(var.credentials_file)

}

provider "random" {

}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.57.0"
    }
  }
}

provider "google" {
  # Configuration options
  project = "mythic-attic-304005"
  region  = "us-central1"
  zone    = "us-central1-c"
}


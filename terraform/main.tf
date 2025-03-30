terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
}
provider "docker" {}

resource "docker_image" "node_app" {
  name         = "node-app"
  keep_locally = false
}

resource "docker_container" "node_container" {
  name  = "node-container"
  image = docker_image.node_app.name
  ports {
    internal = 3000
    external = 3000
  }
}

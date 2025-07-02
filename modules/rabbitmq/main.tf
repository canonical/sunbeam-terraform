# Terraform module for deployment of RabbitMQ K8S
#
# Copyright (c) 2022 Canonical Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_providers {
    juju = {
      source  = "juju/juju"
      version = "= 0.20.0"
    }
  }
}

# core rabbitmq k8s operator
resource "juju_application" "rabbitmq" {
  name  = var.name
  trust = true
  model = var.model

  charm {
    name    = "rabbitmq-k8s"
    channel = var.channel
    base    = "ubuntu@24.04"
  }

  units = var.scale

  config = merge(var.resource-configs, {
    minimum-replicas = var.scale > 3 ? 3 : var.scale
  })

  storage_directives = var.resource-storages
}


resource "juju_offer" "rabbitmq-offer" {
  model            = var.model
  application_name = juju_application.rabbitmq.name
  endpoints        = ["amqp"]
}


resource "juju_integration" "rabbitmq-to-logging" {
  count = (var.logging-app != null) ? 1 : 0
  model = var.model

  application {
    name     = juju_application.rabbitmq.name
    endpoint = "logging"
  }

  application {
    name     = var.logging-app
    endpoint = "logging-provider"
  }
}

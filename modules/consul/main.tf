# Terraform module for deployment of RabbitMQ K8S
#
# Copyright (c) 2024 Canonical Ltd.
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
      version = "= 0.14.0"
    }
  }
}

resource "juju_application" "consul" {
  name  = var.name
  trust = true
  model = var.model

  charm {
    name     = "consul-k8s"
    channel  = var.channel
    revision = var.revision
    base     = var.base
  }

  units = var.scale

  config = var.resource-configs

  storage_directives = var.resource-storages
}

resource "juju_offer" "consul-cluster-offer" {
  model            = var.model
  application_name = juju_application.consul.name
  endpoint         = "consul-cluster"
}

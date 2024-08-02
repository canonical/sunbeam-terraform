# Terraform module for deployment of MySQL K8S
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
      version = "= 0.13.0"
    }
  }
}

# core mysql k8s operator
resource "juju_application" "mysql" {
  name        = var.name
  trust       = true
  model       = var.model
  constraints = var.constraints

  charm {
    name     = "mysql-k8s"
    channel  = var.channel
    revision = var.revision
  }

  config = var.resource-configs

  storage_directives = var.resource-storages

  units = var.scale
}

resource "juju_integration" "mysql-to-metrics-endpoint" {
  count = (var.metrics-endpoint-app != null) ? 1 : 0
  model = var.model

  application {
    name     = juju_application.mysql.name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = var.metrics-endpoint-app
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "mysql-to-grafana-dashboard" {
  count = (var.grafana-dashboard-app != null) ? 1 : 0
  model = var.model

  application {
    name     = juju_application.mysql.name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = var.grafana-dashboard-app
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_integration" "mysql-to-logging" {
  count = (var.logging-app != null) ? 1 : 0
  model = var.model

  application {
    name     = juju_application.mysql.name
    endpoint = "logging"
  }

  application {
    name     = var.logging-app
    endpoint = "logging-provider"
  }
}

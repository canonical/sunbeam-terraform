# Terraform module for deployment of OpenStack API services
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
      version = "= 1.3.1"
    }
  }
}

resource "juju_application" "service" {
  name       = var.name
  model_uuid = var.model-uuid
  trust      = var.trust

  charm {
    name     = var.charm
    channel  = var.channel
    revision = var.revision
    base     = var.base
  }

  config = var.resource-configs

  storage_directives = var.resource-storages

  units = var.scale
}

resource "juju_application" "mysql-router" {
  name       = "${var.name}-mysql-router"
  trust      = true
  model_uuid = var.model-uuid

  charm {
    name    = "mysql-router-k8s"
    channel = var.mysql-router-channel
  }

  units = var.scale
}

resource "juju_integration" "mysql-router-to-mysql" {
  model_uuid = var.model-uuid

  application {
    name     = juju_application.mysql-router.name
    endpoint = "backend-database"
  }

  application {
    name     = var.mysql
    endpoint = "database"
  }
}

resource "juju_integration" "service-to-mysql-router" {
  model_uuid = var.model-uuid

  application {
    name     = juju_application.service.name
    endpoint = "database"
  }

  application {
    name     = juju_application.mysql-router.name
    endpoint = "database"
  }
}

# NOTE: this integration is optional
resource "juju_integration" "service-to-rabbitmq" {
  for_each   = var.rabbitmq == "" ? {} : { target = var.rabbitmq }
  model_uuid = var.model-uuid

  application {
    name     = juju_application.service.name
    endpoint = "amqp"
  }

  application {
    name     = each.value
    endpoint = "amqp"
  }
}

# NOTE: this integration is optional
resource "juju_integration" "keystone-to-service" {
  for_each   = var.keystone == "" ? {} : { target = var.keystone }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "external-keystone-to-service" {
  for_each   = !can(coalesce(var.external-keystone-endpoints-offer-url)) ? {} : { target = var.external-keystone-endpoints-offer-url }
  model_uuid = var.model-uuid

  application {
    offer_url = each.value
    endpoint  = "identity-service"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "service-to-keystone" {
  for_each   = var.keystone-credentials == "" ? {} : { target = var.keystone-credentials }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "identity-credentials"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-credentials"
  }
}

// Only used with external Keystone offers (e.g. multi-region setups).
resource "juju_integration" "external-service-to-keystone" {
  for_each   = !can(coalesce(var.external-keystone-offer-url)) ? {} : { target = var.external-keystone-offer-url }
  model_uuid = var.model-uuid

  application {
    offer_url = var.external-keystone-offer-url
    endpoint  = "identity-credentials"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-credentials"
  }
}

resource "juju_integration" "service-to-keystone-ops" {
  for_each   = var.keystone-ops == "" ? {} : { target = var.keystone-ops }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "identity-ops"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-ops"
  }
}

resource "juju_integration" "external-service-to-keystone-ops" {
  for_each   = !can(coalesce(var.external-keystone-ops-offer-url)) ? {} : { target = var.external-keystone-ops-offer-url }
  model_uuid = var.model-uuid

  application {
    offer_url = each.value
    endpoint  = "identity-ops"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-ops"
  }
}

resource "juju_integration" "service-to-keystone-endpoints" {
  for_each   = var.keystone-endpoints == "" ? {} : { target = var.keystone-endpoints }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "identity-endpoints"
  }

  application {
    name     = juju_application.service.name
    endpoint = "identity-endpoints"
  }
}

resource "juju_integration" "service-to-keystone-cacerts" {
  for_each   = var.keystone-cacerts == "" ? {} : { target = var.keystone-cacerts }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "send-ca-cert"
  }

  application {
    name     = juju_application.service.name
    endpoint = "receive-ca-cert"
  }
}

resource "juju_integration" "external-service-to-keystone-cacerts" {
  for_each   = !can(coalesce(var.external-cert-distributor-offer-url)) ? {} : { target = var.external-cert-distributor-offer-url }
  model_uuid = var.model-uuid

  application {
    offer_url = each.value
    endpoint  = "send-ca-cert"
  }

  application {
    name     = juju_application.service.name
    endpoint = "receive-ca-cert"
  }
}


# juju integrate traefik-public glance
resource "juju_integration" "traefik-public-to-service" {
  for_each   = var.ingress-public == "" ? {} : { target = var.ingress-public }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "ingress"
  }

  application {
    name     = juju_application.service.name
    endpoint = "ingress-public"
  }
}

# juju integrate traefik-internal glance
resource "juju_integration" "traefik-internal-to-service" {
  for_each   = var.ingress-internal == "" ? {} : { target = var.ingress-internal }
  model_uuid = var.model-uuid

  application {
    name     = each.value
    endpoint = "ingress"
  }

  application {
    name     = juju_application.service.name
    endpoint = "ingress-internal"
  }
}

# TODO: specific module for nova?
resource "juju_application" "nova-api-mysql-router" {
  count      = var.name == "nova" ? 1 : 0
  name       = "nova-api-mysql-router"
  model_uuid = var.model-uuid
  trust      = true

  charm {
    name    = "mysql-router-k8s"
    channel = var.mysql-router-channel
  }

  units = var.scale
}

resource "juju_integration" "nova-api-to-mysql-router" {
  count      = length(juju_application.nova-api-mysql-router)
  model_uuid = var.model-uuid

  application {
    name     = juju_application.service.name
    endpoint = "api-database"
  }

  application {
    name     = juju_application.nova-api-mysql-router[count.index].name
    endpoint = "database"
  }
}

resource "juju_integration" "nova-api-router-to-mysql" {
  count      = length(juju_application.nova-api-mysql-router)
  model_uuid = var.model-uuid

  application {
    name     = var.mysql
    endpoint = "database"
  }

  application {
    name     = juju_application.nova-api-mysql-router[count.index].name
    endpoint = "backend-database"
  }
}

resource "juju_application" "nova-cell-mysql-router" {
  count      = var.name == "nova" ? 1 : 0
  name       = "nova-cell-mysql-router"
  model_uuid = var.model-uuid
  trust      = true

  charm {
    name    = "mysql-router-k8s"
    channel = var.mysql-router-channel
  }

  units = var.scale
}

resource "juju_integration" "nova-cell-router-to-mysql" {
  count      = length(juju_application.nova-cell-mysql-router)
  model_uuid = var.model-uuid

  application {
    name     = var.mysql
    endpoint = "database"
  }

  application {
    name     = juju_application.nova-cell-mysql-router[count.index].name
    endpoint = "backend-database"
  }
}

resource "juju_integration" "nova-cell-to-mysql-router" {
  count      = length(juju_application.nova-cell-mysql-router)
  model_uuid = var.model-uuid

  application {
    name     = juju_application.service.name
    endpoint = "cell-database"
  }

  application {
    name     = juju_application.nova-cell-mysql-router[count.index].name
    endpoint = "database"
  }
}

resource "juju_integration" "service-to-logging" {
  count      = (var.logging-app != null) ? 1 : 0
  model_uuid = var.model-uuid

  application {
    name     = juju_application.service.name
    endpoint = "logging"
  }

  application {
    name     = var.logging-app
    endpoint = "receive-loki-logs"
  }
}

# As a workaroud for bug
# https://github.com/juju/terraform-provider-juju/issues/787,
# the endpoints for keystone application are not
# exposed as single offer URL
resource "juju_offer" "keystone-offer" {
  count            = var.name == "keystone" ? 1 : 0
  model_uuid       = var.model-uuid
  application_name = juju_application.service.name
  endpoints        = ["identity-credentials"]
  name             = "keystone-credentials"
}

resource "juju_offer" "keystone-endpoints-offer" {
  count            = var.name == "keystone" ? 1 : 0
  model_uuid       = var.model-uuid
  application_name = juju_application.service.name
  endpoints        = ["identity-service"]
  name             = "keystone-endpoints"
}

resource "juju_offer" "keystone-ops-offer" {
  count            = var.name == "keystone" ? 1 : 0
  model_uuid       = var.model-uuid
  application_name = juju_application.service.name
  endpoints        = ["identity-ops"]
  name             = "keystone-ops"
}

resource "juju_offer" "cert-distributor-offer" {
  count            = var.name == "keystone" ? 1 : 0
  model_uuid       = var.model-uuid
  application_name = juju_application.service.name
  endpoints        = ["send-ca-cert"]
  name             = "cert-distributor"
}

resource "juju_offer" "nova-offer" {
  count            = var.name == "nova" ? 1 : 0
  model_uuid       = var.model-uuid
  application_name = juju_application.service.name
  endpoints        = ["nova-service"]
}

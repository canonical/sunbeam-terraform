# Terraform manifest for deployment of OpenStack Sunbeam
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
      version = "= 0.17.1"
    }
  }
}

provider "juju" {}

locals {
  mysql-services = {
    keystone  = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "keystone", {}), "storages" : lookup(var.mysql-storage-map, "keystone", {}) } : null,
    glance    = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "glance", {}), "storages" : lookup(var.mysql-storage-map, "glance", {}) } : null,
    nova      = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "nova", {}), "storages" : lookup(var.mysql-storage-map, "nova", {}) } : null,
    neutron   = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "neutron", {}), "storages" : lookup(var.mysql-storage-map, "neutron", {}) } : null,
    placement = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "placement", {}), "storages" : lookup(var.mysql-storage-map, "placement", {}) } : null,
    cinder    = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "cinder", {}), "storages" : lookup(var.mysql-storage-map, "cinder", {}) } : null,
    horizon   = var.many-mysql ? { "configs" : lookup(var.mysql-config-map, "horizon", {}), "storages" : lookup(var.mysql-storage-map, "horizon", {}) } : null,
    heat      = var.many-mysql && var.enable-heat ? { "configs" : lookup(var.mysql-config-map, "heat", {}), "storages" : lookup(var.mysql-storage-map, "heat", {}) } : null,
    magnum    = var.many-mysql && var.enable-magnum ? { "configs" : lookup(var.mysql-config-map, "magnum", {}), "storages" : lookup(var.mysql-storage-map, "magnum", {}) } : null,
    aodh      = var.many-mysql && var.enable-telemetry ? { "configs" : lookup(var.mysql-config-map, "aodh", {}), "storages" : lookup(var.mysql-storage-map, "aodh", {}) } : null,
    gnocchi   = var.many-mysql && var.enable-telemetry ? { "configs" : lookup(var.mysql-config-map, "gnocchi", {}), "storages" : lookup(var.mysql-storage-map, "gnocchi", {}) } : null,
    octavia   = var.many-mysql && var.enable-octavia ? { "configs" : lookup(var.mysql-config-map, "octavia", {}), "storages" : lookup(var.mysql-storage-map, "octavia", {}) } : null,
    designate = var.many-mysql && var.enable-designate ? { "configs" : lookup(var.mysql-config-map, "designate", {}), "storages" : lookup(var.mysql-storage-map, "designate", {}) } : null,
    barbican  = var.many-mysql && var.enable-barbican ? { "configs" : lookup(var.mysql-config-map, "barbican", {}), "storages" : lookup(var.mysql-storage-map, "barbican", {}) } : null,
    watcher   = var.many-mysql && var.enable-watcher ? { "configs" : lookup(var.mysql-config-map, "watcher", {}), "storages" : lookup(var.mysql-storage-map, "watcher", {}) } : null,
    masakari  = var.many-mysql && var.enable-masakari ? { "configs" : lookup(var.mysql-config-map, "watcher", {}), "storages" : lookup(var.mysql-storage-map, "watcher", {}) } : null,
  }
  single-mysql = "mysql"
  mysql = {
    for k, v in local.mysql-services : k => v != null ? "${k}-mysql" : local.single-mysql
  }
  grafana-agent-name = length(juju_application.grafana-agent) > 0 ? juju_application.grafana-agent[0].name : null
}

data "juju_offer" "microceph" {
  count = var.enable-ceph ? 1 : 0
  url   = var.ceph-offer-url
}

data "juju_offer" "cinder-volume" {
  count = var.enable-cinder-volume ? 1 : 0
  url   = var.cinder-volume-offer-url
}

resource "juju_model" "sunbeam" {
  name = var.model

  cloud {
    name   = var.cloud
    region = var.cloud-region
  }

  credential = var.credential
  config     = var.config
}

module "single-mysql" {
  count                 = var.many-mysql ? 0 : 1
  source                = "./modules/mysql"
  model                 = juju_model.sunbeam.name
  name                  = local.single-mysql
  channel               = var.mysql-channel
  revision              = var.mysql-revision
  scale                 = var.ha-scale
  resource-configs      = var.mysql-config
  resource-storages     = var.mysql-storage
  grafana-dashboard-app = local.grafana-agent-name
  metrics-endpoint-app  = local.grafana-agent-name
  logging-app           = local.grafana-agent-name
}

module "many-mysql" {
  for_each              = tomap({ for k, v in local.mysql-services : k => v if v != null })
  source                = "./modules/mysql"
  model                 = juju_model.sunbeam.name
  name                  = local.mysql[each.key]
  channel               = var.mysql-channel
  revision              = var.mysql-revision
  scale                 = var.ha-scale
  resource-configs      = merge(var.mysql-config, each.value.configs)
  resource-storages     = merge(var.mysql-storage, each.value.storages)
  grafana-dashboard-app = local.grafana-agent-name
  metrics-endpoint-app  = local.grafana-agent-name
  logging-app           = local.grafana-agent-name
}

module "rabbitmq" {
  source            = "./modules/rabbitmq"
  model             = juju_model.sunbeam.name
  scale             = var.ha-scale
  channel           = var.rabbitmq-channel
  revision          = var.rabbitmq-revision
  resource-configs  = var.rabbitmq-config
  resource-storages = var.rabbitmq-storage
  logging-app       = local.grafana-agent-name
}

module "glance" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "glance-k8s"
  name                 = "glance"
  model                = juju_model.sunbeam.name
  trust                = true
  channel              = var.glance-channel == null ? var.openstack-channel : var.glance-channel
  revision             = var.glance-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["glance"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.enable-ceph ? var.os-api-scale : 1
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.glance-config, {
    ceph-osd-replication-count     = var.ceph-osd-replication-count
    enable-telemetry-notifications = var.enable-telemetry
    region                         = var.region
  })
  resource-storages = var.glance-storage
}

module "keystone" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "keystone-k8s"
  name                 = "keystone"
  model                = juju_model.sunbeam.name
  channel              = var.keystone-channel == null ? var.openstack-channel : var.keystone-channel
  revision             = var.keystone-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["keystone"]
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.keystone-config, {
    enable-telemetry-notifications = var.enable-telemetry
    region                         = var.region
  })
  resource-storages = var.keystone-storage
}

module "nova" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "nova-k8s"
  name                 = "nova"
  model                = juju_model.sunbeam.name
  channel              = var.nova-channel == null ? var.openstack-channel : var.nova-channel
  revision             = var.nova-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["nova"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.nova-config, {
    region = var.region
  })
}

resource "juju_integration" "nova-to-ingress-public" {
  model = juju_model.sunbeam.name

  application {
    name     = module.nova.name
    endpoint = "traefik-route-public"
  }

  application {
    name     = juju_application.traefik-public.name
    endpoint = "traefik-route"
  }
}

resource "juju_integration" "nova-to-ingress-internal" {
  model = juju_model.sunbeam.name

  application {
    name     = module.nova.name
    endpoint = "traefik-route-internal"
  }

  application {
    name     = juju_application.traefik.name
    endpoint = "traefik-route"
  }
}

module "horizon" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "horizon-k8s"
  name                 = "horizon"
  model                = juju_model.sunbeam.name
  channel              = var.horizon-channel == null ? var.openstack-channel : var.horizon-channel
  revision             = var.horizon-revision
  mysql                = local.mysql["horizon"]
  keystone-credentials = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.horizon-config, {
    plugins = jsonencode(var.horizon-plugins)
  })
}

module "neutron" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "neutron-k8s"
  name                 = "neutron"
  model                = juju_model.sunbeam.name
  channel              = var.neutron-channel == null ? var.openstack-channel : var.neutron-channel
  revision             = var.neutron-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["neutron"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.neutron-config, {
    region = var.region
  })
}

module "placement" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "placement-k8s"
  name                 = "placement"
  model                = juju_model.sunbeam.name
  channel              = var.placement-channel == null ? var.openstack-channel : var.placement-channel
  revision             = var.placement-revision
  mysql                = local.mysql["placement"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.placement-config, {
    region = var.region
  })
}

resource "juju_application" "traefik" {
  name  = "traefik"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name     = "traefik-k8s"
    channel  = var.traefik-channel
    revision = var.traefik-revision
  }

  config             = var.traefik-config
  storage_directives = var.traefik-storage
  units              = var.ingress-scale
}

resource "juju_integration" "traefik-internal-to-metrics-endpoint" {
  count = var.enable-observability ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik.name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "traefik-internal-to-grafana-dashboard" {
  count = var.enable-observability ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik.name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_integration" "traefik-internal-to-grafana-agent-loki" {
  count = var.enable-observability ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik.name
    endpoint = "logging"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "logging-provider"
  }
}

resource "juju_application" "traefik-public" {
  name  = "traefik-public"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name     = "traefik-k8s"
    channel  = var.traefik-channel
    revision = var.traefik-revision
  }

  config             = var.traefik-config
  storage_directives = var.traefik-storage
  units              = var.ingress-scale
}

resource "juju_integration" "traefik-public-to-metrics-endpoint" {
  count = var.enable-observability ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-public.name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "traefik-public-to-grafana-dashboard" {
  count = var.enable-observability ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-public.name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_integration" "traefik-public-to-grafana-agent-loki" {
  count = var.enable-observability ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-public.name
    endpoint = "logging"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "logging-provider"
  }
}

resource "juju_application" "traefik-rgw" {
  count = var.enable-ceph ? 1 : 0
  name  = "traefik-rgw"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name     = "traefik-k8s"
    channel  = var.traefik-channel
    revision = var.traefik-revision
  }

  config             = var.traefik-config
  storage_directives = var.traefik-storage
  units              = var.ingress-scale
}

resource "juju_offer" "ingress-rgw-offer" {
  count            = var.enable-ceph ? 1 : 0
  model            = juju_model.sunbeam.name
  application_name = juju_application.traefik-rgw[count.index].name
  endpoint         = "traefik-route"
}

resource "juju_integration" "traefik-rgw-to-metrics-endpoint" {
  count = (var.enable-ceph && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-rgw[count.index].name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "traefik-rgw-to-grafana-dashboard" {
  count = (var.enable-ceph && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-rgw[count.index].name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_integration" "traefik-rgw-to-grafana-agent-loki" {
  count = (var.enable-ceph && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-rgw[count.index].name
    endpoint = "logging"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "logging-provider"
  }
}

resource "juju_application" "certificate-authority" {
  name  = "certificate-authority"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name     = "self-signed-certificates"
    channel  = var.certificate-authority-channel
    revision = var.certificate-authority-revision
  }

  config = merge(var.certificate-authority-config, {
    ca-common-name = "internal-ca"
  })
}

module "ovn" {
  source                 = "./modules/ovn"
  model                  = juju_model.sunbeam.name
  channel                = var.ovn-central-channel == null ? var.ovn-channel : var.ovn-central-channel
  revision               = var.ovn-central-revision
  scale                  = var.ha-scale
  relay                  = true
  relay-scale            = var.os-api-scale
  relay-channel          = var.ovn-relay-channel == null ? var.ovn-channel : var.ovn-relay-channel
  relay-revision         = var.ovn-relay-revision
  ca                     = juju_application.certificate-authority.name
  resource-configs       = var.ovn-central-config
  relay-resource-configs = var.ovn-relay-config
  resource-storages      = var.ovn-central-storage
  logging-app            = local.grafana-agent-name
}

# juju integrate ovn-central neutron
resource "juju_integration" "ovn-central-to-neutron" {
  model = juju_model.sunbeam.name

  application {
    name     = module.ovn.name
    endpoint = "ovsdb-cms"
  }

  application {
    name     = module.neutron.name
    endpoint = "ovsdb-cms"
  }
}

# juju integrate neutron vault
resource "juju_integration" "neutron-to-ca" {
  model = juju_model.sunbeam.name

  application {
    name     = module.neutron.name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.certificate-authority.name
    endpoint = "certificates"
  }
}

# juju integrate nova placement
resource "juju_integration" "nova-to-placement" {
  model = juju_model.sunbeam.name

  application {
    name     = module.nova.name
    endpoint = "placement"
  }

  application {
    name     = module.placement.name
    endpoint = "placement"
  }
}

# juju integrate glance microceph
resource "juju_integration" "glance-to-ceph" {
  count = length(data.juju_offer.microceph)
  model = juju_model.sunbeam.name

  application {
    name     = module.glance.name
    endpoint = "ceph"
  }

  application {
    offer_url = data.juju_offer.microceph[count.index].url
  }
}

module "cinder" {
  depends_on           = [module.single-mysql, module.many-mysql]
  source               = "./modules/openstack-api"
  charm                = "cinder-k8s"
  name                 = "cinder"
  model                = juju_model.sunbeam.name
  channel              = var.cinder-channel == null ? var.openstack-channel : var.cinder-channel
  revision             = var.cinder-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["cinder"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.cinder-config, {
    region = var.region
  })
}

# Cinder-volume MySQL router
resource "juju_application" "cinder-volume-mysql-router" {
  count = var.enable-cinder-volume ? 1 : 0
  name  = "cinder-volume-mysql-router"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name    = "mysql-router-k8s"
    channel = var.mysql-router-channel
  }

  units = var.ha-scale
  config = {
    "expose-external" = "loadbalancer"
  }
}

resource "juju_integration" "cinder-volume-mysql-router-to-mysql" {
  count      = length(juju_application.cinder-volume-mysql-router)
  depends_on = [module.single-mysql, module.many-mysql]
  model      = juju_model.sunbeam.name

  application {
    name     = juju_application.cinder-volume-mysql-router[count.index].name
    endpoint = "backend-database"
  }

  application {
    name     = local.mysql["cinder"]
    endpoint = "database"
  }
}

resource "juju_offer" "cinder-volume-database-offer" {
  count            = var.enable-cinder-volume ? 1 : 0
  model            = juju_model.sunbeam.name
  application_name = juju_application.cinder-volume-mysql-router[count.index].name
  endpoint         = "database"
}

resource "juju_integration" "cinder-to-cinder-volume" {
  count = length(data.juju_offer.cinder-volume)
  model = juju_model.sunbeam.name

  application {
    name     = module.cinder.name
    endpoint = "storage-backend"
  }

  application {
    offer_url = data.juju_offer.cinder-volume[count.index].url
  }
}

resource "juju_offer" "ca-offer" {
  model            = juju_model.sunbeam.name
  application_name = juju_application.certificate-authority.name
  endpoint         = "certificates"
}

module "heat" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-heat ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "heat-k8s"
  name                 = "heat"
  model                = juju_model.sunbeam.name
  channel              = var.heat-channel == null ? var.openstack-channel : var.heat-channel
  revision             = var.heat-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["heat"]
  keystone             = module.keystone.name
  keystone-ops         = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = ""
  ingress-public       = ""
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.heat-config, {
    region = var.region
  })
}

resource "juju_integration" "heat-to-ingress-public" {
  count = var.enable-heat ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.heat[count.index].name
    endpoint = "traefik-route-public"
  }

  application {
    name     = juju_application.traefik-public.name
    endpoint = "traefik-route"
  }
}

resource "juju_integration" "heat-to-ingress-internal" {
  count = var.enable-heat ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.heat[count.index].name
    endpoint = "traefik-route-internal"
  }

  application {
    name     = juju_application.traefik.name
    endpoint = "traefik-route"
  }
}

module "aodh" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-telemetry ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "aodh-k8s"
  name                 = "aodh"
  model                = juju_model.sunbeam.name
  channel              = var.aodh-channel == null ? var.openstack-channel : var.aodh-channel
  revision             = var.aodh-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["aodh"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.aodh-config, {
    region = var.region
  })
}

module "gnocchi" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-telemetry ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "gnocchi-k8s"
  name                 = "gnocchi"
  model                = juju_model.sunbeam.name
  channel              = var.gnocchi-channel == null ? var.openstack-channel : var.gnocchi-channel
  revision             = var.gnocchi-revision
  mysql                = local.mysql["gnocchi"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.gnocchi-config, {
    ceph-osd-replication-count = var.ceph-osd-replication-count
    region                     = var.region
  })
}

# juju integrate gnocchi microceph
resource "juju_integration" "gnocchi-to-ceph" {
  count = var.enable-telemetry ? length(data.juju_offer.microceph) : 0
  model = juju_model.sunbeam.name
  application {
    name     = module.gnocchi[count.index].name
    endpoint = "ceph"
  }
  application {
    offer_url = data.juju_offer.microceph[count.index].url
  }
}

resource "juju_application" "ceilometer" {
  count = var.enable-telemetry ? 1 : 0
  name  = "ceilometer"
  model = juju_model.sunbeam.name

  charm {
    name     = "ceilometer-k8s"
    channel  = var.ceilometer-channel == null ? var.openstack-channel : var.ceilometer-channel
    revision = var.ceilometer-revision
    base     = "ubuntu@24.04"
  }

  config = merge(var.ceilometer-config, { region = var.region })
  units  = var.ha-scale
}

resource "juju_integration" "ceilometer-to-rabbitmq" {
  count = var.enable-telemetry ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.ceilometer[count.index].name
    endpoint = "amqp"
  }

  application {
    name     = module.rabbitmq.name
    endpoint = "amqp"
  }
}

resource "juju_integration" "ceilometer-to-keystone" {
  count = var.enable-telemetry ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "identity-credentials"
  }

  application {
    name     = juju_application.ceilometer[count.index].name
    endpoint = "identity-credentials"
  }
}

resource "juju_integration" "ceilometer-to-keystone-cacert" {
  count = var.enable-telemetry ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "send-ca-cert"
  }

  application {
    name     = juju_application.ceilometer[count.index].name
    endpoint = "receive-ca-cert"
  }
}

resource "juju_integration" "ceilometer-to-gnocchi" {
  count = var.enable-telemetry ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.gnocchi[count.index].name
    endpoint = "gnocchi-service"
  }

  application {
    name     = juju_application.ceilometer[count.index].name
    endpoint = "gnocchi-db"
  }
}

resource "juju_integration" "ceilometer-to-logging" {
  count = (local.grafana-agent-name != null && length(juju_application.ceilometer) > 0) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.ceilometer[count.index].name
    endpoint = "logging"
  }

  application {
    name     = local.grafana-agent-name
    endpoint = "logging-provider"
  }
}

resource "juju_offer" "ceilometer-offer" {
  count            = var.enable-telemetry ? 1 : 0
  model            = juju_model.sunbeam.name
  application_name = juju_application.ceilometer[count.index].name
  endpoint         = "ceilometer-service"
}

resource "juju_application" "openstack-exporter" {
  count = var.enable-telemetry ? 1 : 0
  name  = "openstack-exporter"
  model = juju_model.sunbeam.name

  charm {
    name     = "openstack-exporter-k8s"
    channel  = var.openstack-exporter-channel == null ? var.openstack-channel : var.openstack-exporter-channel
    revision = var.openstack-exporter-revision
    base     = "ubuntu@24.04"
  }

  config = merge(var.openstack-exporter-config, { region = var.region })
  units  = 1
}

resource "juju_integration" "openstack-exporter-to-keystone" {
  count = var.enable-telemetry ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "identity-ops"
  }

  application {
    name     = juju_application.openstack-exporter[count.index].name
    endpoint = "identity-ops"
  }
}

resource "juju_integration" "openstack-exporter-to-keystone-cacert" {
  count = var.enable-telemetry ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "send-ca-cert"
  }

  application {
    name     = juju_application.openstack-exporter[count.index].name
    endpoint = "receive-ca-cert"
  }
}

resource "juju_integration" "openstack-exporter-to-metrics-endpoint" {
  count = (var.enable-telemetry && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.openstack-exporter[count.index].name
    endpoint = "metrics-endpoint"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "metrics-endpoint"
  }
}

resource "juju_integration" "openstack-exporter-to-grafana-dashboard" {
  count = (var.enable-telemetry && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.openstack-exporter[count.index].name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_integration" "openstack-exporter-to-logging" {
  count = (local.grafana-agent-name != null && length(juju_application.openstack-exporter) > 0) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.openstack-exporter[count.index].name
    endpoint = "logging"
  }

  application {
    name     = local.grafana-agent-name
    endpoint = "logging-provider"
  }
}

module "octavia" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-octavia ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "octavia-k8s"
  name                 = "octavia"
  model                = juju_model.sunbeam.name
  channel              = var.octavia-channel == null ? var.openstack-channel : var.octavia-channel
  revision             = var.octavia-revision
  mysql                = local.mysql["octavia"]
  keystone             = module.keystone.name
  keystone-ops         = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.octavia-config, {
    region = var.region
  })
  resource-storages = var.octavia-storage
}

# juju integrate ovn-central octavia
resource "juju_integration" "ovn-central-to-octavia" {
  count = var.enable-octavia ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.ovn.name
    endpoint = "ovsdb-cms"
  }

  application {
    name     = module.octavia[count.index].name
    endpoint = "ovsdb-cms"
  }
}

# juju integrate octavia certificates
resource "juju_integration" "octavia-to-ca" {
  count = var.enable-octavia ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.octavia[count.index].name
    endpoint = "certificates"
  }

  application {
    name     = juju_application.certificate-authority.name
    endpoint = "certificates"
  }
}

resource "juju_application" "bind" {
  count = var.enable-designate ? 1 : 0
  name  = "bind"
  trust = true
  model = juju_model.sunbeam.name

  charm {
    name     = "designate-bind-k8s"
    channel  = var.bind-channel
    revision = var.bind-revision
    base     = "ubuntu@24.04"
  }

  config = var.bind-config
  units  = var.ha-scale
}

resource "juju_integration" "bind-to-logging" {
  count = (local.grafana-agent-name != null && length(juju_application.bind) > 0) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.bind[count.index].name
    endpoint = "logging"
  }

  application {
    name     = local.grafana-agent-name
    endpoint = "logging-provider"
  }
}

module "designate" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-designate ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "designate-k8s"
  name                 = "designate"
  model                = juju_model.sunbeam.name
  channel              = var.designate-channel == null ? var.openstack-channel : var.designate-channel
  revision             = var.designate-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["designate"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.designate-config, {
    "nameservers" = var.nameservers
    region        = var.region
  })
}

resource "juju_integration" "designate-to-bind" {
  count = var.enable-designate ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.designate[count.index].name
    endpoint = "dns-backend"
  }

  application {
    name     = juju_application.bind[count.index].name
    endpoint = "dns-backend"
  }
}

resource "juju_integration" "designate-to-neutron" {
  count = var.enable-designate ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.designate[count.index].name
    endpoint = "dnsaas"
  }

  application {
    name     = module.neutron.name
    endpoint = "external-dns"
  }
}

resource "juju_application" "vault" {
  count = var.enable-vault ? 1 : 0
  model = juju_model.sunbeam.name
  name  = "vault"

  charm {
    name     = "vault-k8s"
    channel  = var.vault-channel
    revision = var.vault-revision
  }

  config             = var.vault-config
  storage_directives = var.vault-storage
  units              = var.ha-scale
}

module "barbican" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-barbican ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "barbican-k8s"
  name                 = "barbican"
  model                = juju_model.sunbeam.name
  channel              = var.barbican-channel == null ? var.openstack-channel : var.barbican-channel
  revision             = var.barbican-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["barbican"]
  keystone             = module.keystone.name
  keystone-ops         = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.barbican-config, {
    region = var.region
  })
}

resource "juju_integration" "barbican-to-vault" {
  count = (var.enable-barbican && var.enable-vault) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.barbican[count.index].name
    endpoint = "vault-kv"
  }

  application {
    name     = juju_application.vault[count.index].name
    endpoint = "vault-kv"
  }
}

module "magnum" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-magnum ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "magnum-k8s"
  name                 = "magnum"
  model                = juju_model.sunbeam.name
  channel              = var.magnum-channel == null ? var.openstack-channel : var.magnum-channel
  revision             = var.magnum-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["magnum"]
  keystone             = module.keystone.name
  keystone-ops         = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.magnum-config, {
    "cluster-user-trust" = "true"
    region               = var.region
  })
}

resource "juju_application" "ldap-apps" {
  for_each = var.ldap-apps
  name     = "keystone-ldap-${each.key}"
  model    = var.model

  charm {
    name     = "keystone-ldap-k8s"
    channel  = var.ldap-channel
    revision = var.ldap-revision
    base     = "ubuntu@24.04"
  }
  # This is a config charm so 1 unit is enough
  units  = 1
  config = each.value
}

resource "juju_integration" "ldap-apps-to-logging" {
  for_each = local.grafana-agent-name != null ? var.ldap-apps : {}
  model    = juju_model.sunbeam.name

  application {
    name     = juju_application.ldap-apps[each.key].name
    endpoint = "logging"
  }

  application {
    name     = local.grafana-agent-name
    endpoint = "logging-provider"
  }
}

resource "juju_integration" "ldap-to-keystone" {
  for_each = var.ldap-apps
  model    = juju_model.sunbeam.name

  application {
    name     = "keystone-ldap-${each.key}"
    endpoint = "domain-config"
  }

  application {
    name     = module.keystone.name
    endpoint = "domain-config"
  }
}

resource "juju_application" "manual-tls-certificates" {
  count = (var.traefik-to-tls-provider == null) ? 0 : 1
  name  = "manual-tls-certificates"
  model = juju_model.sunbeam.name

  charm {
    name     = "manual-tls-certificates"
    channel  = var.manual-tls-certificates-channel
    revision = var.manual-tls-certificates-revision
  }

  units  = 1 # does not scale
  config = var.manual-tls-certificates-config
}

resource "juju_integration" "manual-tls-certificates-to-vault" {
  count = var.traefik-to-tls-provider == "vault" ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = "manual-tls-certificates"
    endpoint = "certificates"
  }

  application {
    name     = var.traefik-to-tls-provider
    endpoint = "tls-certificates-pki"
  }
}

resource "juju_integration" "traefik-public-to-tls-provider" {
  count = var.enable-tls-for-public-endpoint ? (var.traefik-to-tls-provider == null ? 0 : 1) : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-public.name
    endpoint = "certificates"
  }

  application {
    name     = var.traefik-to-tls-provider
    endpoint = (var.traefik-to-tls-provider == "manual-tls-certificates") ? "certificates" : "vault-pki"
  }
}

resource "juju_integration" "traefik-to-tls-provider" {
  count = var.enable-tls-for-internal-endpoint ? (var.traefik-to-tls-provider == null ? 0 : 1) : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik.name
    endpoint = "certificates"
  }

  application {
    name     = var.traefik-to-tls-provider
    endpoint = (var.traefik-to-tls-provider == "manual-tls-certificates") ? "certificates" : "vault-pki"
  }
}

resource "juju_integration" "traefik-rgw-to-tls-provider" {
  count = (var.enable-ceph && var.enable-tls-for-rgw-endpoint) ? (var.traefik-to-tls-provider == null ? 0 : 1) : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-rgw[count.index].name
    endpoint = "certificates"
  }

  application {
    name     = var.traefik-to-tls-provider
    endpoint = (var.traefik-to-tls-provider == "manual-tls-certificates") ? "certificates" : "vault-pki"
  }
}

resource "juju_application" "tempest" {
  count = var.enable-validation ? 1 : 0
  name  = "tempest"
  model = juju_model.sunbeam.name

  charm {
    name     = "tempest-k8s"
    channel  = var.tempest-channel == null ? var.openstack-channel : var.tempest-channel
    revision = var.tempest-revision
    base     = "ubuntu@24.04"
  }

  units  = 1
  config = merge(var.tempest-config, { region = var.region })
}

resource "juju_integration" "tempest-to-keystone" {
  count = var.enable-validation ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "identity-ops"
  }

  application {
    name     = juju_application.tempest[count.index].name
    endpoint = "identity-ops"
  }
}

resource "juju_integration" "tempest-to-keystone-cacert" {
  count = var.enable-validation ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "send-ca-cert"
  }

  application {
    name     = juju_application.tempest[count.index].name
    endpoint = "receive-ca-cert"
  }
}

resource "juju_integration" "tempest-to-grafana-agent-loki" {
  count = (var.enable-validation && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.tempest[count.index].name
    endpoint = "logging"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "logging-provider"
  }
}

resource "juju_integration" "tempest-to-grafana-agent-grafana" {
  count = (var.enable-validation && var.enable-observability) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.tempest[count.index].name
    endpoint = "grafana-dashboard"
  }

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "grafana-dashboards-consumer"
  }
}

resource "juju_application" "grafana-agent" {
  count = var.enable-observability ? 1 : 0
  name  = "grafana-agent"
  model = juju_model.sunbeam.name


  charm {
    name     = "grafana-agent-k8s"
    base     = "ubuntu@22.04"
    channel  = var.grafana-agent-channel
    revision = var.grafana-agent-revision
  }

  units  = 1
  config = var.grafana-agent-config
}

resource "juju_integration" "grafana-agent-to-receive-remote-write" {
  count = (var.enable-observability && var.receive-remote-write-offer-url != null) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "send-remote-write"
  }

  application {
    offer_url = var.receive-remote-write-offer-url
  }
}

resource "juju_integration" "grafana-agent-to-logging" {
  count = (var.enable-observability && var.logging-offer-url != null) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "logging-consumer"
  }

  application {
    offer_url = var.logging-offer-url
  }
}

resource "juju_integration" "grafana-agent-to-cos-grafana" {
  count = (var.enable-observability && var.grafana-dashboard-offer-url != null) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.grafana-agent[count.index].name
    endpoint = "grafana-dashboards-provider"
  }

  application {
    offer_url = var.grafana-dashboard-offer-url
  }
}

resource "juju_application" "images-sync" {
  count = var.enable-images-sync ? 1 : 0
  name  = "images-sync"
  model = juju_model.sunbeam.name

  charm {
    name     = "openstack-images-sync-k8s"
    channel  = var.images-sync-channel == null ? var.openstack-channel : var.images-sync-channel
    revision = var.images-sync-revision
    base     = "ubuntu@24.04"
  }

  units  = 1
  config = merge(var.images-sync-config, { region = var.region })
}

resource "juju_integration" "images-sync-to-keystone" {
  count = var.enable-images-sync ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.keystone.name
    endpoint = "identity-service"
  }

  application {
    name     = juju_application.images-sync[count.index].name
    endpoint = "identity-service"
  }
}

resource "juju_integration" "images-sync-to-traefik-internal" {
  count = var.enable-images-sync ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.images-sync[count.index].name
    endpoint = "ingress-internal"
  }
}

resource "juju_integration" "images-sync-to-traefik-public" {
  count = var.enable-images-sync ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.traefik-public.name
    endpoint = "ingress"
  }

  application {
    name     = juju_application.images-sync[count.index].name
    endpoint = "ingress-public"
  }
}

resource "juju_integration" "images-sync-to-logging" {
  count = (local.grafana-agent-name != null && length(juju_application.images-sync) > 0) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = juju_application.images-sync[count.index].name
    endpoint = "logging"
  }

  application {
    name     = local.grafana-agent-name
    endpoint = "logging-provider"
  }
}

module "watcher" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-watcher ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "watcher-k8s"
  name                 = "watcher"
  model                = juju_model.sunbeam.name
  channel              = var.watcher-channel == null ? var.openstack-channel : var.watcher-channel
  revision             = var.watcher-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["watcher"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.watcher-config, {
    enable-telemetry-notifications = var.enable-telemetry
    region                         = var.region
  })
}

resource "juju_integration" "watcher-to-gnocchi" {
  count = (var.enable-watcher && var.enable-telemetry) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.gnocchi[count.index].name
    endpoint = "gnocchi-service"
  }

  application {
    name     = module.watcher[count.index].name
    endpoint = "gnocchi-db"
  }
}

module "consul-management" {
  count             = var.enable-consul-management ? 1 : 0
  source            = "./modules/consul"
  model             = juju_model.sunbeam.name
  name              = "consul-management"
  scale             = var.ha-scale
  channel           = var.consul-channel
  revision          = var.consul-revision
  resource-configs  = merge(var.consul-config, lookup(var.consul-config-map, "consul-management", {}))
  resource-storages = var.consul-storage
}

module "consul-tenant" {
  count             = var.enable-consul-tenant ? 1 : 0
  source            = "./modules/consul"
  model             = juju_model.sunbeam.name
  name              = "consul-tenant"
  scale             = var.ha-scale
  channel           = var.consul-channel
  revision          = var.consul-revision
  resource-configs  = merge(var.consul-config, lookup(var.consul-config-map, "consul-tenant", {}))
  resource-storages = var.consul-storage
}

module "consul-storage" {
  count             = var.enable-consul-storage ? 1 : 0
  source            = "./modules/consul"
  model             = juju_model.sunbeam.name
  name              = "consul-storage"
  scale             = var.ha-scale
  channel           = var.consul-channel
  revision          = var.consul-revision
  resource-configs  = merge(var.consul-config, lookup(var.consul-config-map, "consul-storage", {}))
  resource-storages = var.consul-storage
}

module "masakari" {
  depends_on           = [module.single-mysql, module.many-mysql]
  count                = var.enable-masakari ? 1 : 0
  source               = "./modules/openstack-api"
  charm                = "masakari-k8s"
  name                 = "masakari"
  model                = juju_model.sunbeam.name
  channel              = var.masakari-channel == null ? var.openstack-channel : var.masakari-channel
  revision             = var.masakari-revision
  rabbitmq             = module.rabbitmq.name
  mysql                = local.mysql["masakari"]
  keystone             = module.keystone.name
  keystone-cacerts     = module.keystone.name
  ingress-internal     = juju_application.traefik.name
  ingress-public       = juju_application.traefik-public.name
  scale                = var.os-api-scale
  mysql-router-channel = var.mysql-router-channel
  logging-app          = local.grafana-agent-name
  resource-configs = merge(var.masakari-config, {
    region = var.region
  })
}

resource "juju_integration" "masakari-to-consul-management" {
  count = (var.enable-masakari && var.enable-consul-management) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.masakari[count.index].name
    endpoint = "consul-management"
  }

  application {
    name     = module.consul-management[count.index].name
    endpoint = "consul-cluster"
  }
}

resource "juju_integration" "masakari-to-consul-tenant" {
  count = (var.enable-masakari && var.enable-consul-tenant) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.masakari[count.index].name
    endpoint = "consul-tenant"
  }

  application {
    name     = module.consul-tenant[count.index].name
    endpoint = "consul-cluster"
  }
}

resource "juju_integration" "masakari-to-consul-storage" {
  count = (var.enable-masakari && var.enable-consul-storage) ? 1 : 0
  model = juju_model.sunbeam.name

  application {
    name     = module.masakari[count.index].name
    endpoint = "consul-storage"
  }

  application {
    name     = module.consul-storage[count.index].name
    endpoint = "consul-cluster"
  }
}

resource "juju_offer" "masakari-offer" {
  count            = var.enable-masakari ? 1 : 0
  model            = juju_model.sunbeam.name
  application_name = module.masakari[count.index].name
  endpoint         = "masakari-service"
}

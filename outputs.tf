# Terraform manifest for deployment of OpenStack Sunbeam
#
# Copyright (c) 2023 Canonical Ltd.
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

output "ca-offer-url" {
  description = "URL of the certificates authority offer"
  value       = juju_offer.ca-offer.url
}

output "keystone-offer-url" {
  description = "URL of the keystone offer"
  value       = var.is-secondary-region ? var.external-keystone-offer-url : one(module.keystone.keystone-offer-url[*])
}

output "keystone-endpoints-offer-url" {
  description = "URL of the keystone endpoints offer"
  value       = var.is-secondary-region ? var.external-keystone-endpoints-offer-url : one(module.keystone.keystone-endpoints-offer-url[*])
}

output "keystone-ops-offer-url" {
  description = "URL of the keystone ops offer"
  value       = var.is-secondary-region ? var.external-keystone-ops-offer-url : one(module.keystone.keystone-ops-offer-url[*])
}

output "rabbitmq-offer-url" {
  description = "URL of the RabbitMQ offer"
  value       = module.rabbitmq.rabbitmq-offer-url
}

output "ovn-relay-offer-url" {
  description = "URL of the ovn relay offer"
  value       = try(one(module.ovn[0].ovn-relay-offer-url[*]), null)
}

output "ceilometer-offer-url" {
  description = "URL of the ceilometer offer"
  value       = one(juju_offer.ceilometer-offer[*].url)
}

output "cert-distributor-offer-url" {
  description = "URL of the cert distributor offer"
  value       = var.is-secondary-region ? var.external-cert-distributor-offer-url : one(module.keystone.cert-distributor-offer-url[*])
}

output "nova-offer-url" {
  description = "URL of the nova service offer"
  value       = one(module.nova.nova-offer-url[*])
}

output "ingress-rgw-offer-url" {
  description = "URL of the RGW ingress offer"
  value       = one(juju_offer.ingress-rgw-offer[*].url)
}

output "consul-management-cluster-offer-url" {
  description = "URL of the Consul Management cluster offer"
  value       = one(module.consul-management[*].consul-cluster-offer-url)
}

output "consul-tenant-cluster-offer-url" {
  description = "URL of the Consul Tenant cluster offer"
  value       = one(module.consul-tenant[*].consul-cluster-offer-url)
}

output "consul-storage-cluster-offer-url" {
  description = "URL of the Consul Storage cluster offer"
  value       = one(module.consul-storage[*].consul-cluster-offer-url)
}

output "masakari-offer-url" {
  description = "URL of the masakari offer"
  value       = one(juju_offer.masakari-offer[*].url)
}

output "cinder-volume-database-offer-url" {
  description = "URL of the cinder volume database offer"
  value       = one(juju_offer.cinder-volume-database-offer[*].url)
}

output "manila-data-database-offer-url" {
  description = "URL of the manila data database offer"
  value       = one(juju_offer.manila-data-database-offer[*].url)
}

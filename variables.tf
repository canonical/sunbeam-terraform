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

variable "openstack-channel" {
  description = "Operator channel for OpenStack deployment"
  type        = string
  default     = "2024.1/stable"
}

variable "mysql-channel" {
  description = "Operator channel for MySQL deployment"
  type        = string
  default     = "8.0/stable"
}

variable "mysql-revision" {
  description = "Operator channel revision for MySQL deployment"
  type        = number
  default     = null
}

variable "mysql-config" {
  description = "Operator configs for MySQL deployment"
  type        = map(string)
  default = {
    "profile-limit-memory" = 3456
  }
}

variable "mysql-storage" {
  description = "Storage directives for MySQL deployment"
  type        = map(string)
  default     = {}
}

variable "mysql-config-map" {
  description = "Operator configs for specific MySQL deployment (applied on top of mysql-config for specific application)"
  type        = map(map(string))
  default     = {}
}

variable "mysql-storage-map" {
  description = "Operator storage directives for specific MySQL deployment (applied on top of mysql-storage for specific application)"
  type        = map(map(string))
  default     = {}
}

variable "mysql-router-channel" {
  description = "Operator channel for MySQL router deployment"
  default     = "8.0/stable"
  type        = string
}

variable "traefik-channel" {
  description = "Operator channel for Traefik deployment"
  type        = string
  default     = "1.0/stable"
}

variable "traefik-revision" {
  description = "Operator revision for Traefik deployment"
  type        = number
  default     = null
}

variable "traefik-config" {
  description = "Operator configs for Traefik deployment"
  type        = map(string)
  default     = {}
}

variable "traefik-public-config" {
  description = "Operator configs for Traefik public deployment"
  type        = map(string)
  default     = {}
}
variable "traefik-rgw-config" {
  description = "Operator configs for Traefik rgw deployment"
  type        = map(string)
  default     = {}
}

variable "traefik-storage" {
  description = "Operator storage directives for Traefik deployment"
  type        = map(string)
  default     = {}
}

variable "rabbitmq-channel" {
  description = "Operator channel for RabbitMQ deployment"
  type        = string
  default     = "3.12/stable"
}

variable "rabbitmq-revision" {
  description = "Operator revision for RabbitMQ deployment"
  type        = number
  default     = null
}

variable "rabbitmq-config" {
  description = "Operator configs for RabbitMQ deployment"
  type        = map(string)
  default     = {}
}

variable "rabbitmq-storage" {
  description = "Operator storage directives for RabbitMQ deployment"
  type        = map(string)
  default     = {}
}

variable "certificate-authority-channel" {
  description = "Operator channel for Certificate Authority deployment"
  type        = string
  default     = "1/stable"
}

variable "certificate-authority-revision" {
  description = "Operator channel revision for Certificate Authority deployment"
  type        = number
  default     = null
}

variable "certificate-authority-config" {
  description = "Operator channel for Certificate Authority deployment"
  type        = map(string)
  default     = {}
}

variable "ovn-channel" {
  description = "Operator channel for OVN deployment"
  type        = string
  default     = "24.03/stable"
}

variable "ovn-central-channel" {
  description = "Operator channel for OVN Central deployment"
  type        = string
  default     = null
}

variable "ovn-central-revision" {
  description = "Operator channel revision for OVN Central deployment"
  type        = number
  default     = null
}

variable "ovn-central-config" {
  description = "Operator config for OVN Central deployment"
  type        = map(string)
  default     = {}
}

variable "ovn-central-storage" {
  description = "Operator storage directives for OVN Central deployment"
  type        = map(string)
  default     = {}
}

variable "ovn-relay-channel" {
  description = "Operator channel for OVN Relay deployment"
  type        = string
  default     = null
}

variable "ovn-relay-revision" {
  description = "Operator channel revision for OVN Relay deployment"
  type        = number
  default     = null
}

variable "ovn-relay-config" {
  description = "Operator config for OVN Relay deployment"
  type        = map(string)
  default     = {}
}

variable "keystone-channel" {
  description = "Operator channel for Keystone deployment"
  type        = string
  default     = null
}

variable "keystone-revision" {
  description = "Operator channel revision for Keystone deployment"
  type        = number
  default     = null
}

variable "keystone-config" {
  description = "Operator config for Keystone deployment"
  type        = map(string)
  default     = {}
}

variable "keystone-storage" {
  description = "Operator storage directives for Keystone deployment"
  type        = map(string)
  default     = {}
}

variable "glance-channel" {
  description = "Operator channel for Glance deployment"
  type        = string
  default     = null
}

variable "glance-revision" {
  description = "Operator channel revision for Glance deployment"
  type        = number
  default     = null
}

variable "glance-config" {
  description = "Operator config for Glance deployment"
  type        = map(string)
  default     = {}
}

variable "glance-storage" {
  description = "Operator storage directives for Glance deployment"
  type        = map(string)
  default     = {}
}

variable "nova-channel" {
  description = "Operator channel for Nova deployment"
  type        = string
  default     = null
}

variable "nova-revision" {
  description = "Operator channel revision for Nova deployment"
  type        = number
  default     = null
}

variable "nova-config" {
  description = "Operator config for Nova deployment"
  type        = map(string)
  default     = {}
}

variable "horizon-channel" {
  description = "Operator channel for Horizon deployment"
  type        = string
  default     = null
}

variable "horizon-revision" {
  description = "Operator channel revision for Horizon deployment"
  type        = number
  default     = null
}

variable "horizon-config" {
  description = "Operator config for Horizon deployment"
  type        = map(string)
  default     = {}
}

variable "neutron-channel" {
  description = "Operator channel for Neutron deployment"
  type        = string
  default     = null
}

variable "neutron-revision" {
  description = "Operator channel revision for Neutron deployment"
  type        = number
  default     = null
}

variable "neutron-config" {
  description = "Operator config for Neutron deployment"
  type        = map(string)
  default     = {}
}

variable "placement-channel" {
  description = "Operator channel for Placement deployment"
  type        = string
  default     = null
}

variable "placement-revision" {
  description = "Operator channel revision for Placement deployment"
  type        = number
  default     = null
}

variable "placement-config" {
  description = "Operator config for Placement deployment"
  type        = map(string)
  default     = {}
}

variable "cinder-channel" {
  description = "Operator channel for Cinder deployment"
  type        = string
  default     = null
}

variable "cinder-revision" {
  description = "Operator channel revision for Cinder deployment"
  type        = number
  default     = null
}

variable "cinder-config" {
  description = "Operator config for Cinder deployment"
  type        = map(string)
  default     = {}
}

variable "model" {
  description = "Name of Juju model to use for deployment"
  type        = string
  default     = "openstack"
}

variable "cloud" {
  description = "Name of K8S cloud to use for deployment"
  type        = string
  default     = "microk8s"
}

variable "cloud-region" {
  description = "Name of cloud region to use for deployment"
  type        = string
  default     = "localhost"
}

# https://github.com/juju/terraform-provider-juju/issues/147
variable "credential" {
  description = "Name of credential to use for deployment"
  type        = string
  default     = ""
}

variable "config" {
  description = "Set configuration on model"
  type        = map(string)
  default     = {}
}

variable "enable-ceph" {
  description = "Enable Ceph integration"
  type        = bool
  default     = false
}

variable "enable-ceph-nfs" {
  description = "Enable Ceph NFS integration"
  type        = bool
  default     = false
}

variable "ceph-offer-url" {
  description = "Offer URL from microceph app"
  type        = string
  default     = "admin/controller.microceph"
}

variable "ceph-nfs-offer-url" {
  description = "NFS offer URL from microceph app"
  type        = string
  default     = "admin/controller.microceph-ceph-nfs"
}

variable "ceph-rgw-offer-url" {
  description = "RGW readiness offer URL from microceph app"
  type        = string
  default     = "admin/controller.microceph-ceph-rgw"
}

variable "ceph-osd-replication-count" {
  description = "Ceph OSD replication count to set on glance/cinder"
  type        = number
  default     = 1
}

variable "enable-cinder-volume" {
  description = "Enable Cinder Volume integration"
  type        = bool
  default     = false
}

variable "is-region-controller" {
  # Only a small subset of API services will be deployed on region
  # controllers (e.g. Keystone, Horizon).
  description = "Specify if this is a region controller."
  type        = bool
  default     = false
}

variable "is-secondary-region" {
  # Secondary regions will not host services that are expected to run
  # on the region controller (e.g. Keystone, Horizon).
  description = "Specify if this is a secondary region."
  type        = bool
  default     = false
}

variable "cinder-volume-offer-url" {
  description = "Offer URL from cinder-volume app"
  type        = string
  default     = "admin/controller.cinder-volume"
}

variable "ha-scale" {
  description = "Scale of traditional HA deployments"
  # Need better name, because 1 is not HA, needs to encompass services like MySQL, RabbitMQ and OVN
  type    = number
  default = 1
}

variable "os-api-scale" {
  description = "Scale of OpenStack API service deployments"
  type        = number
  default     = 1
}

variable "ingress-scale" {
  description = "Scale of ingress deployment"
  type        = number
  default     = 1
}

variable "many-mysql" {
  description = "Enabling this will switch architecture from one global mysql to one per service"
  type        = bool
  default     = false
}

variable "enable-heat" {
  description = "Enable OpenStack Heat service"
  type        = bool
  default     = false
}

variable "heat-channel" {
  description = "Operator channel for Heat deployment"
  type        = string
  default     = null
}

variable "heat-revision" {
  description = "Operator channel revision for Heat deployment"
  type        = number
  default     = null
}

variable "heat-config" {
  description = "Operator config for Heat deployment"
  type        = map(string)
  default     = {}
}

variable "enable-telemetry" {
  description = "Enable OpenStack Telemetry services"
  type        = bool
  default     = false
}

variable "aodh-channel" {
  description = "Operator channel for Aodh deployment"
  type        = string
  default     = null
}

variable "aodh-revision" {
  description = "Operator channel revision for Aodh deployment"
  type        = number
  default     = null
}

variable "aodh-config" {
  description = "Operator config for Aodh deployment"
  type        = map(string)
  default     = {}
}

variable "gnocchi-channel" {
  description = "Operator channel for Gnocchi deployment"
  type        = string
  default     = null
}

variable "gnocchi-revision" {
  description = "Operator channel revision for Gnocchi deployment"
  type        = number
  default     = null
}

variable "gnocchi-config" {
  description = "Operator config for Gnocchi deployment"
  type        = map(string)
  default     = {}
}

variable "ceilometer-channel" {
  description = "Operator channel for Ceilometer deployment"
  type        = string
  default     = null
}

variable "ceilometer-revision" {
  description = "Operator channel revision for Ceilometer deployment"
  type        = number
  default     = null
}

variable "ceilometer-config" {
  description = "Operator config for Ceilometer deployment"
  type        = map(string)
  default     = {}
}

variable "openstack-exporter-channel" {
  description = "Operator channel for OpenStack Exporter deployment"
  type        = string
  default     = null
}

variable "openstack-exporter-revision" {
  description = "Operator channel revision for OpenStack Exporter deployment"
  type        = number
  default     = null
}

variable "openstack-exporter-config" {
  description = "Operator config for OpenStack Exporter deployment"
  type        = map(string)
  default     = {}
}

variable "enable-masakari" {
  description = "Enable OpenStack Masakari service"
  type        = bool
  default     = false
}

variable "masakari-channel" {
  description = "Operator channel for Masakari deployment"
  type        = string
  default     = null
}

variable "masakari-revision" {
  description = "Operator channel revision for Masakari deployment"
  type        = number
  default     = null
}

variable "masakari-config" {
  description = "Operator config for Masakari deployment"
  type        = map(string)
  default     = {}
}

variable "receive-remote-write-offer-url" {
  description = "Offer URL from prometheus-k8s:receive-remote-write application"
  type        = string
  default     = null
}

variable "grafana-dashboard-offer-url" {
  description = "Offer URL from grafana-k8s:grafana-dashboard application"
  type        = string
  default     = null
}

variable "logging-offer-url" {
  description = "Offer URL from loki-k8s:logging application"
  type        = string
  default     = null
}

variable "enable-octavia" {
  description = "Enable OpenStack Octavia service"
  type        = bool
  default     = false
}

variable "octavia-channel" {
  description = "Operator channel for Octavia deployment"
  type        = string
  default     = null
}

variable "octavia-revision" {
  description = "Operator channel revision for Octavia deployment"
  type        = number
  default     = null
}

variable "octavia-config" {
  description = "Operator config for Octavia deployment"
  type        = map(string)
  default     = {}
}

variable "octavia-storage" {
  description = "Operator storage directives for Octavia deployment"
  type        = map(string)
  default     = {}
}

variable "enable-designate" {
  description = "Enable OpenStack Designate service"
  type        = bool
  default     = false
}

variable "bind-channel" {
  description = "Operator channel for Bind deployment"
  type        = string
  default     = "9/stable"
}

variable "bind-revision" {
  description = "Operator channel revision for Bind deployment"
  type        = number
  default     = null
}

variable "bind-config" {
  description = "Operator config for Bind deployment"
  type        = map(string)
  default     = {}
}

variable "designate-channel" {
  description = "Operator channel for Designate deployment"
  type        = string
  default     = null
}

variable "designate-revision" {
  description = "Operator channel revision for Designate deployment"
  type        = number
  default     = null
}

variable "designate-config" {
  description = "Operator config for Designate deployment"
  type        = map(string)
  default     = {}
}

variable "nameservers" {
  description = <<-EOT
    Space delimited list of nameservers. These are the nameservers that have been provided
    to the domain registrar in order to delegate the domain to Designate.
    e.g. "ns1.example.com. ns2.example.com."
  EOT
  type        = string
  default     = ""
}

variable "enable-vault" {
  description = "Enable Vault service"
  type        = bool
  default     = false
}

variable "vault-channel" {
  description = "Operator channel for Vault deployment"
  type        = string
  default     = "1.16/stable"
}

variable "vault-revision" {
  description = "Operator channel revision for Vault deployment"
  type        = number
  default     = null
}

variable "vault-config" {
  description = "Operator config for Vault deployment"
  type        = map(string)
  default     = {}
}

variable "vault-storage" {
  description = "Operator storage directives for Vault deployment"
  type        = map(string)
  default     = {}
}

variable "enable-barbican" {
  description = "Enable OpenStack Barbican service"
  type        = bool
  default     = false
}

variable "barbican-channel" {
  description = "Operator channel for Barbican deployment"
  type        = string
  default     = null
}

variable "barbican-revision" {
  description = "Operator channel revision for Barbican deployment"
  type        = number
  default     = null
}

variable "barbican-config" {
  description = "Operator config for Barbican deployment"
  type        = map(string)
  default     = {}
}

# Ironic and Ironic-related variables.
variable "enable-ironic" {
  description = "Enable OpenStack Ironic service"
  type        = bool
  default     = false
}

variable "ironic-channel" {
  description = "Operator channel for Ironic deployment"
  type        = string
  default     = null
}

variable "ironic-revision" {
  description = "Operator channel revision for Ironic deployment"
  type        = number
  default     = null
}

variable "ironic-config" {
  description = "Operator config for Ironic deployment"
  type        = map(string)
  default     = {}
}

variable "nova-ironic-channel" {
  description = "Operator channel for Ironic nova-compute deployment"
  type        = string
  default     = null
}

variable "nova-ironic-revision" {
  description = "Operator channel revision for Ironic nova-compute deployment"
  type        = number
  default     = null
}

variable "nova-ironic-config" {
  description = "Operator config for Ironic nova-compute deployment"
  type        = map(string)
  default     = {}
}

variable "ironic-conductor-channel" {
  description = "Operator channel for Ironic Conductor deployment"
  type        = string
  default     = null
}

variable "ironic-conductor-revision" {
  description = "Operator channel revision for Ironic Conductor deployment"
  type        = number
  default     = null
}

variable "ironic-conductor-config" {
  description = "Operator config for Ironic Conductor deployment"
  type        = map(string)
  default     = {}
}

variable "ironic-compute-shards" {
  description = "Ironic nova-compute shards and their config flags"
  type        = map(map(string))
  default     = {}
}

variable "ironic-conductor-groups" {
  description = "ironic-conductor groups and their config flags"
  type        = map(map(string))
  default     = {}
}

variable "neutron-baremetal-switch-config-channel" {
  description = "Operator channel for the Neutron Baremetal Switch Config Charm"
  type        = string
  default     = null
}

variable "neutron-baremetal-switch-config-revision" {
  description = "Operator channel revision for the Neutron Baremetal Switch Config Charm"
  type        = number
  default     = null
}

variable "netconf-conf-secrets" {
  description = "Neutron Baremetal Switch Config Charm secrets"
  type        = string
  default     = ""
}

variable "neutron-generic-switch-config-channel" {
  description = "Operator channel for the Neutron Generic Switch Config Charm"
  type        = string
  default     = null
}

variable "neutron-generic-switch-config-revision" {
  description = "Operator channel revision for the Neutron Generic Switch Config Charm"
  type        = number
  default     = null
}

variable "generic-conf-secrets" {
  description = "Neutron Generic Switch Config Charm secrets"
  type        = string
  default     = ""
}

variable "switch-conf-secrets" {
  description = "Neutron Generic Switch Config Charm secrets"
  type        = map(any)
  default     = {}
}

variable "enable-magnum" {
  description = "Enable OpenStack Magnum service"
  type        = bool
  default     = false
}

variable "magnum-channel" {
  description = "Operator channel for Magnum deployment"
  type        = string
  default     = null
}

variable "magnum-revision" {
  description = "Operator channel revision for Magnum deployment"
  type        = number
  default     = null
}

variable "magnum-config" {
  description = "Operator config for Magnum deployment"
  type        = map(string)
  default     = {}
}

variable "enable-manila" {
  description = "Enable OpenStack Manila service"
  type        = bool
  default     = false
}

variable "manila-channel" {
  description = "Operator channel for Manila deployment"
  type        = string
  default     = null
}

variable "manila-revision" {
  description = "Operator channel revision for Manila deployment"
  type        = number
  default     = null
}

variable "manila-config" {
  description = "Operator config for Manila deployment"
  type        = map(string)
  default     = {}
}

variable "enable-manila-cephfs" {
  description = "Enable OpenStack CEPHFS storage backend for the Manila service"
  type        = bool
  default     = false
}

variable "manila-cephfs-channel" {
  description = "Operator channel for the CEPHFS manila-share service"
  type        = string
  default     = null
}

variable "manila-cephfs-revision" {
  description = "Operator channel revision for the CEPHFS manila-share service"
  type        = number
  default     = null
}

variable "manila-cephfs-config" {
  description = "Operator config for the CEPHFS manila-share service"
  type        = map(string)
  default     = {}
}

variable "ldap-channel" {
  description = "Operator channel for Keystone LDAP deployment"
  type        = string
  default     = "2024.1/stable"
}

variable "ldap-revision" {
  description = "Operator channel revision for Keystone LDAP deployment"
  type        = number
  default     = null
}

variable "ldap-apps" {
  description = "LDAP Apps and their config flags"
  type        = map(map(string))
  default     = {}
}

variable "horizon-plugins" {
  description = "List of horizon plugin to enable."
  type        = list(string)
  default     = []
}

variable "traefik-to-tls-provider" {
  description = "Application name providing the certificates endpoint traefik will be integrated with"
  type        = string
  default     = null
}

variable "manual-tls-certificates-channel" {
  description = "Operator channel for Manual Tls Certificates deployment"
  type        = string
  default     = "latest/stable"
}

variable "manual-tls-certificates-revision" {
  description = "Operator channel revision for Manual Tls Certificates deployment"
  type        = number
  default     = null
}

variable "manual-tls-certificates-config" {
  description = "Operator config for Manual Tls Certificates deployment"
  type        = map(string)
  default     = {}
}

variable "enable-tls-for-public-endpoint" {
  description = "Enable TLS for traefik-public"
  type        = bool
  default     = false
}

variable "enable-tls-for-internal-endpoint" {
  description = "Enable TLS for traefik"
  type        = bool
  default     = false
}

variable "enable-tls-for-rgw-endpoint" {
  description = "Enable TLS for traefik rgw"
  type        = bool
  default     = false
}

variable "enable-validation" {
  description = "Enable Tempest deployment"
  type        = bool
  default     = false
}

variable "tempest-channel" {
  description = "Operator channel for Tempest deployment"
  type        = string
  default     = null
}

variable "tempest-revision" {
  description = "Operator channel revision for Tempest deployment"
  type        = number
  default     = null
}

variable "tempest-config" {
  description = "Operator config for Tempest deployment"
  type        = map(string)
  default     = {}
}

variable "enable-observability" {
  description = "Enable Observability"
  type        = bool
  default     = false
}

variable "grafana-agent-channel" {
  type        = string
  default     = "latest/stable"
  description = "Operator channel for grafana-agent deployment"
}

variable "grafana-agent-revision" {
  type        = number
  default     = null
  description = "Operator channel revision for grafana-agent deployment"
}

variable "grafana-agent-config" {
  type        = map(string)
  default     = {}
  description = "Operator config for grafana-agent deployment"
}

variable "enable-images-sync" {
  description = "Enable Images Sync"
  type        = bool
  default     = false
}

variable "images-sync-channel" {
  type        = string
  default     = null
  description = "Operator channel for openstack-images-sync deployment"
}

variable "images-sync-revision" {
  type        = number
  default     = null
  description = "Operator channel revision for openstack-images-sync deployment"
}

variable "images-sync-config" {
  type        = map(string)
  default     = {}
  description = "Operator config for openstack-images-sync deployment"
}

variable "enable-watcher" {
  description = "Enable OpenStack Watcher service"
  type        = bool
  default     = false
}

variable "watcher-channel" {
  description = "Operator channel for Watcher deployment"
  type        = string
  default     = null
}

variable "watcher-revision" {
  description = "Operator channel revision for Watcher deployment"
  type        = number
  default     = null
}

variable "watcher-config" {
  description = "Operator config for Watcher deployment"
  type        = map(string)
  default     = {}
}

variable "enable-consul-management" {
  description = "Enable Consul to track clients running on management network"
  type        = bool
  default     = false
}

variable "enable-consul-tenant" {
  description = "Enable Consul to track clients running on tenant network"
  type        = bool
  default     = false
}

variable "enable-consul-storage" {
  description = "Enable Consul to track clients running on storage network"
  type        = bool
  default     = false
}

variable "consul-channel" {
  description = "Operator channel for Consul K8S deployment"
  type        = string
  default     = null
}

variable "consul-revision" {
  description = "Operator channel revision for Consul K8S deployment"
  type        = number
  default     = null
}

variable "consul-config" {
  description = "Operator config for Consul K8S deployment"
  type        = map(string)
  default     = {}
}

variable "consul-config-map" {
  description = "Operator configs for specific Consul deployment (applied on top of consul-config for specific application)"
  type        = map(map(string))
  default     = {}
}

variable "consul-storage" {
  description = "Operator storage directives for Consul K8S deployment"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "Region name"
  type        = string
  default     = "RegionOne"
}

variable "kratos-idp-channel" {
  description = "Operator channel for Kratos external integrator"
  type        = string
  default     = "0.2/stable"
}

variable "kratos-idp-revision" {
  description = "Operator channel revision for Kratos external integrator"
  type        = number
  default     = null
}

variable "keystone-saml-channel" {
  description = "Operator channel for keystone-saml-k8s external integrator"
  type        = string
  default     = null
}

variable "keystone-saml-revision" {
  description = "Operator channel revision for keystone-saml-k8s external integrator"
  type        = number
  default     = null
}

variable "external-keystone-offer-url" {
  # In multi-region setups, the cluster connects to an external Keystone
  # service, in which case an offer URL must be provided.
  description = "URL of the external keystone credentials offer"
  type        = string
  default     = null
}

variable "external-keystone-endpoints-offer-url" {
  description = "URL of the external keystone endpoints offer"
  type        = string
  default     = null
}

variable "external-keystone-ops-offer-url" {
  description = "URL of the external keystone ops offer"
  type        = string
  default     = null
}

variable "external-cert-distributor-offer-url" {
  description = "URL of the external cert distributor offer"
  type        = string
  default     = null
}

variable "sso-providers" {
  description = "Keystone IDPs and their configs"
  # type        = map(map(string))
  type = object({
    openid = optional(map(map(string)))
    saml2  = optional(map(map(string)))
  })

  default = {
    openid = {}
    saml2  = {}
  }
}

variable "saml-x509-keypair" {
  description = "The juju secret that holds the SAML2 certificate and key"
  type        = string
  default     = ""
}

variable "enable-cloudkitty" {
  description = "Enable Openstack Rating service"
  type        = bool
  default     = false
}

variable "cloudkitty-channel" {
  description = "Operator channel for Cloudkitty deployment"
  type        = string
  default     = "2025.1/edge"
}

variable "cloudkitty-revision" {
  description = "Operator channel revision for Cloudkitty deployment"
  type        = number
  default     = null
}

variable "cloudkitty-config" {
  description = "Operator config for Cloudkitty deployment"
  type        = map(string)
  default     = {}
}

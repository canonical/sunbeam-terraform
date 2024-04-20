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

output "name" {
  description = "Name of the deployed operator"
  value       = juju_application.service.name
}

output "keystone-offer-url" {
  description = "URL of the keystone offer"
  value       = juju_offer.keystone-offer[*].url
}

output "cinder-ceph-offer-url" {
  description = "URL of the cinder ceph offer"
  value       = juju_offer.cinder-ceph-offer[*].url
}

output "cert-distributor-offer-url" {
  description = "URL of the cert distributor offer"
  value       = juju_offer.cert-distributor-offer[*].url
}

output "nova-offer-url" {
  description = "URL of the nova offer"
  value       = juju_offer.nova-offer[*].url
}

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

variable "openstack_channel" {
  description = "Operator channel for OpenStack deployment"
  default     = "yoga/beta"
}

variable "mysql_channel" {
  description = "Operator channel for MySQL deployment"
  default     = "edge"
}

variable "rabbitmq_channel" {
  description = "Operator channel for RabbitMQ deployment"
  default     = "3.11/beta"
}

variable "ovn_channel" {
  description = "Operator channel for OVN deployment"
  default     = "22.03/beta"
}

variable "model" {
  description = "Name of Juju model to use for deployment"
  default     = "openstack"
}

variable "cloud" {
  description = "Name of K8S cloud to use for deployment"
  default     = "microk8s"
}

# https://github.com/juju/terraform-provider-juju/issues/147
variable "credential" {
  description = "Name of credential to use for deployment"
  default     = "microk8s-creds"
}

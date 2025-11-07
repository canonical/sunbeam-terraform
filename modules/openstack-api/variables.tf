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

variable "name" {
  description = "Name of the deployed operator"
  type        = string
}

variable "channel" {
  description = "Operator channel"
  type        = string
  default     = "latest/edge"
}

variable "revision" {
  description = "Operator channel revision"
  type        = string
  default     = null
}

variable "base" {
  description = "Operator base"
  type        = string
  default     = "ubuntu@24.04"
}

variable "mysql-router-channel" {
  description = "Operator channel for MySQL router deployment"
  type        = string
  default     = "8.0/edge"
}

variable "scale" {
  description = "Scale of application"
  type        = number
  default     = 1
}

variable "charm" {
  description = "Charmed operator to deploy"
  type        = string
}

variable "model" {
  description = "Juju model to deploy resources in"
  type        = string
}

variable "trust" {
  description = "Give charm rights to it's k8s resources"
  type        = bool
  default     = false
}

variable "rabbitmq" {
  description = "RabbitMQ operator to integrate with"
  type        = string
  default     = ""
}

variable "mysql" {
  description = "MySQL operator to integrate with"
  type        = string
}

variable "keystone" {
  description = "Keystone operator to integrate with"
  type        = string
  default     = ""
}

variable "keystone-credentials" {
  description = "Keystone operator to integrate with"
  type        = string
  default     = ""
}

variable "keystone-ops" {
  description = "Keystone operator to integrate with"
  type        = string
  default     = ""
}

variable "keystone-endpoints" {
  description = "Keystone operator to integrate with"
  type        = string
  default     = ""
}

variable "keystone-cacerts" {
  description = "Keystone operator to integrate with"
  type        = string
  default     = ""
}

variable "ingress-internal" {
  description = "Ingress operator to integrate with for internal endpoints"
  type        = string
}

variable "ingress-public" {
  description = "Ingress operator to integrate with for public endpoints"
  type        = string
}

variable "resource-configs" {
  description = "Configs to set for all resources"
  type        = map(string)
  default     = {}
}

variable "resource-storages" {
  description = "Storage directives to set for all resources"
  type        = map(string)
  default     = {}
}

variable "logging-app" {
  description = "Name of application providing logging endpoint"
  type        = string
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

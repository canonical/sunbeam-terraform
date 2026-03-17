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

variable "name" {
  description = "Name of the deployed Consul K8S operator"
  type        = string
  default     = "consul"
}

variable "channel" {
  description = "Consul K8S charm channel"
  type        = string
  default     = "1.19/edge"
}

variable "revision" {
  description = "Consul K8S charm channel revision"
  type        = number
  default     = null
}

variable "base" {
  description = "Operator base"
  type        = string
  default     = "ubuntu@24.04"
}

variable "scale" {
  description = "Scale of Consul K8S charm"
  type        = number
  default     = 1
}

variable "model-uuid" {
  description = "Juju model UUID to deploy resources in"
  type        = string
}

variable "resource-configs" {
  description = "Configs to set for consul"
  type        = map(string)
  default     = {}
}

variable "resource-storages" {
  description = "Storage directives to set for consul"
  type        = map(string)
  default     = {}
}

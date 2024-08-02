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

variable "channel" {
  description = "Operator channel for OVN Central"
  type        = string
  default     = "22.03/edge"
}

variable "revision" {
  description = "Operator channel revision for OVN Central"
  type        = number
  default     = null
}

variable "resource-configs" {
  description = "Operator config for OVN Central"
  type        = map(string)
  default     = {}
}

variable "resource-storages" {
  description = "Operator storage directives for OVN Central"
  type        = map(string)
  default     = {}
}

variable "scale" {
  description = "Scale of OVN central application"
  type        = number
  default     = 1
}

variable "model" {
  description = "Juju model to deploy resources in"
  type        = string
}

variable "relay" {
  description = "Enable OVN relay"
  type        = bool
  default     = true
}

variable "relay-channel" {
  description = "Operator channel for OVN Relay"
  type        = string
  default     = "22.03/edge"
}

variable "relay-revision" {
  description = "Operator channel revision for OVN Relay"
  type        = number
  default     = null
}

variable "relay-resource-configs" {
  description = "Operator config for OVN Relay"
  type        = map(string)
  default     = {}
}

variable "relay-scale" {
  description = "Scale of OVN relay application"
  type        = number
  default     = 1
}

variable "ca" {
  description = "Application name of certificate authority operator"
  type        = string
  default     = ""
}

variable "logging-app" {
  description = "Name of application providing logging endpoint"
  type        = string
  default     = null
}

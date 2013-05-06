#
# Cookbook Name:: iptables_persistent
#
# Copyright 2013, Planio GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default["iptables_persistent"]["dir"] = "/etc/iptables"
if platform == "debian" && node["platform_version"].to_f < 7 ||
   platform == "ubuntu" && node["platform_version"].to_f < 12
  default["iptables_persistent"]["rules_v4"] = "rules"
else
  default["iptables_persistent"]["rules_v4"] = "rules.v4"
end
default["iptables_persistent"]["rules_v6"] = "rules.v6"

# Fail open to make sure the system isn't killed when unconfigured
default["iptables_persistent"]["ipv4"]["chains"]["INPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["chains"]["FORWARD"] = "ACCEPT"

default["iptables_persistent"]["ipv4"]["any_pre"] = []
default["iptables_persistent"]["ipv4"]["tcp"] = []
default["iptables_persistent"]["ipv4"]["udp"] = []
default["iptables_persistent"]["ipv4"]["icmp"] = []
default["iptables_persistent"]["ipv4"]["any_post"] = []
default["iptables_persistent"]["ipv6"]["nat"] = []

# Fail open to make sure the system isn't killed when unconfigured
default["iptables_persistent"]["ipv6"]["chains"]["INPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["chains"]["FORWARD"] = "ACCEPT"

default["iptables_persistent"]["ipv6"]["any_pre"] = []
default["iptables_persistent"]["ipv6"]["tcp"] = []
default["iptables_persistent"]["ipv6"]["udp"] = []
default["iptables_persistent"]["ipv6"]["icmp"] = []
default["iptables_persistent"]["ipv6"]["any_post"] = []

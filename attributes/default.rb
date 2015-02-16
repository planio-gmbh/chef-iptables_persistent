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

# In Debian Jessie and Ubuntu Utopic, iptables-persistent became a plugin to
# the netfilter-persistent.
if platform == "debian" && node["platform_version"].to_f < 8 ||
   platform == "ubuntu" && node["platform_version"].to_f < 14.1
  default["iptables_persistent"]["service_name"] = "iptables-persistent"
else
  default["iptables_persistent"]["service_name"] = "netfilter-persistent"
end

# Fail open to make sure the system isn't killed when unconfigured
default["iptables_persistent"]["ipv4"]["filter"]["chains"]["INPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["filter"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["filter"]["chains"]["FORWARD"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["filter"]["any_pre"] = []
default["iptables_persistent"]["ipv4"]["filter"]["tcp"] = []
default["iptables_persistent"]["ipv4"]["filter"]["udp"] = []
default["iptables_persistent"]["ipv4"]["filter"]["icmp"] = []
default["iptables_persistent"]["ipv4"]["filter"]["any_post"] = []

default["iptables_persistent"]["ipv4"]["nat"]["chains"]["PREROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["nat"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["nat"]["chains"]["POSTROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["nat"]["any_pre"] = []
default["iptables_persistent"]["ipv4"]["nat"]["tcp"] = []
default["iptables_persistent"]["ipv4"]["nat"]["udp"] = []
default["iptables_persistent"]["ipv4"]["nat"]["any_post"] = []

default["iptables_persistent"]["ipv4"]["mangle"]["chains"]["PREROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["mangle"]["chains"]["INPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["mangle"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["mangle"]["chains"]["FORWARD"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["mangle"]["chains"]["POSTROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["mangle"]["any_pre"] = []
default["iptables_persistent"]["ipv4"]["mangle"]["tcp"] = []
default["iptables_persistent"]["ipv4"]["mangle"]["udp"] = []
default["iptables_persistent"]["ipv4"]["mangle"]["any_post"] = []

default["iptables_persistent"]["ipv4"]["raw"]["chains"]["PREROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["raw"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv4"]["raw"]["any_pre"] = []
default["iptables_persistent"]["ipv4"]["raw"]["tcp"] = []
default["iptables_persistent"]["ipv4"]["raw"]["udp"] = []
default["iptables_persistent"]["ipv4"]["raw"]["any_post"] = []

# Fail open to make sure the system isn't killed when unconfigured
default["iptables_persistent"]["ipv6"]["filter"]["chains"]["INPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["filter"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["filter"]["chains"]["FORWARD"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["filter"]["any_pre"] = []
default["iptables_persistent"]["ipv6"]["filter"]["tcp"] = []
default["iptables_persistent"]["ipv6"]["filter"]["udp"] = []
default["iptables_persistent"]["ipv6"]["filter"]["icmpv6"] = []
default["iptables_persistent"]["ipv6"]["filter"]["any_post"] = []

default["iptables_persistent"]["ipv6"]["mangle"]["chains"]["PREROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["mangle"]["chains"]["INPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["mangle"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["mangle"]["chains"]["FORWARD"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["mangle"]["chains"]["POSTROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["mangle"]["any_pre"] = []
default["iptables_persistent"]["ipv6"]["mangle"]["tcp"] = []
default["iptables_persistent"]["ipv6"]["mangle"]["udp"] = []
default["iptables_persistent"]["ipv6"]["mangle"]["any_post"] = []

default["iptables_persistent"]["ipv6"]["raw"]["chains"]["PREROUTING"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["raw"]["chains"]["OUTPUT"] = "ACCEPT"
default["iptables_persistent"]["ipv6"]["raw"]["any_pre"] = []
default["iptables_persistent"]["ipv6"]["raw"]["tcp"] = []
default["iptables_persistent"]["ipv6"]["raw"]["udp"] = []
default["iptables_persistent"]["ipv6"]["raw"]["any_post"] = []


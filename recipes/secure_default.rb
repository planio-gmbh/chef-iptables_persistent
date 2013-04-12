#
# Cookbook Name:: iptables-persistent
# Recipe:: simple_firewall
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

include_recipe "iptables-persistent"

node.default["iptables-persistent"]["ipv4"]["defaults"]["INPUT"] = "DROP"
node.default["iptables-persistent"]["ipv4"]["defaults"]["OUTPUT"] = "ACCEPT"
node.default["iptables-persistent"]["ipv4"]["defaults"]["FORWARD"] = "DROP"

node.default["iptables-persistent"]["ipv4"]["any_pre"] = [
  "\n# allow any traffic over loopback",
  {"chain" => "INPUT", "interface" => "lo"},
  {"chain" => "OUTPUT", "interface" => "lo"},

  "\n# reject any traffic from or to 127/0 that doesn't involve the loopback interface",
  {"!interface" => "lo", "destination" => "127.0.0.1/8", "target" => "REJECT"},

  "\n# Drop any TCP packet that does not start a connection with a syn flag.",
  {"protocol" => "tcp", "state" => "NEW", "opts" => ["! --syn"], "target" => "DROP"},

  "\n# allow established or related traffic to any chain",
  {"chain" => "INPUT", "state" => %w[ESTABLISHED RELATED]},
  {"chain" => "OUTPUT", "state" => %w[ESTABLISHED RELATED]},
  {"chain" => "FORWARD", "state" => %w[ESTABLISHED RELATED]},

  "\n# Drop any incomming invalid packet that could not be identified.",
  {"state" => "INVALID", "target" => "DROP"},

  "\n# ICMP echo-request",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 0"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 0"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 0"]},

  "\n# ICMP host-unreachable",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 3/1"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 3/1"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 3/1"]},

  "\n# ICMP port-unreachable",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 3/3"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 3/3"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 3/3"]},

  "\n# ICMP fragmentation-needed (filtering that is a BAD idea)",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 3/4"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 3/4"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 3/4"]},

  "\n# ICMP source quench RFC 792 (filtering that is a BAD idea)",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 4"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 4"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 4"]},

  "\n# ICMP echo-reply, limited to 2 per second",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 8", "-m limit", "--limit 2/s"]},
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 8"], "target" => "DROP"},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 8"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 8"]},

  "\n# ICMP Time Exceeded",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 11"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 11"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 11"]},

  "\n# ICMP Parameter Problem",
  {"chain" => "INPUT", "protocol" => "icmp", "opts" => ["--icmp-type 12"]},
  {"chain" => "OUTPUT", "protocol" => "icmp", "opts" => ["--icmp-type 12"]},
  {"chain" => "FORWARD", "protocol" => "icmp", "opts" => ["--icmp-type 12"]}
] + node.default["iptables-persistent"]["ipv4"]["any_pre"]

node.default["iptables-persistent"]["ipv4"]["tcp"] = [
  # Allow at least all incomming traffic on Port 22 (SSH)
  {"port" => 22}
] + node.default["iptables-persistent"]["ipv4"]["tcp"]

# completely disable ipv6 traffic
node.default["iptables-persistent"]["ipv6"]["defaults"]["INPUT"] = "DROP"
node.default["iptables-persistent"]["ipv6"]["defaults"]["OUTPUT"] = "DROP"
node.default["iptables-persistent"]["ipv6"]["defaults"]["FORWARD"] = "DROP"

# Set some kernel parameters for proper ICMP handling
file '/etc/sysctl.d/60-iptables-persistent.conf' do
  mode 0644
  content <<-EOF.gsub /^\s+/, ""
    # Accept ICMP redirects only for gateways listed in our default gateway list
    net.ipv4.conf.all.secure_redirects=1

    # Kernel ignores ICMP Echo requests sent to broadcast/multicast addresses
    # Prevention: Smurf IP Denial-of-Service Attacks
    net.ipv4.icmp_echo_ignore_broadcasts=1

    # Kernel ignores bogus responses to broadcast frames
    net.ipv4.icmp_ignore_bogus_error_responses=1
  EOF
  notifies :start, "service[procps]", :immediately
end

service 'procps' do
  provider Chef::Provider::Service::Upstart if platform?("ubuntu")
  action :nothing
end

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

extend IptablesPersistent::RecipeHelpers

node.default["iptables-persistent"]["ipv4"]["defaults"]["INPUT"] = "DROP"
node.default["iptables-persistent"]["ipv4"]["defaults"]["OUTPUT"] = "ACCEPT"
node.default["iptables-persistent"]["ipv4"]["defaults"]["FORWARD"] = "DROP"

prepend_rules "ipv4", "any_pre", [
  "# allow any traffic over loopback",
  {"chain" => "INPUT", "interface" => "lo"},
  {"chain" => "OUTPUT", "interface" => "lo"},

  {"!interface" => "lo", "destination" => "127.0.0.1/8", "target" => "REJECT", "comment" => "Reject any traffic from or to 127/0 that doesn't involve the loopback interface."},
  {"protocol" => "tcp", "state" => "NEW", "opts" => ["! --syn"], "target" => "DROP", "comment" => "Drop any TCP packet that does not start a connection with a syn flag."},

  {"chain" => "INPUT", "state" => %w[ESTABLISHED RELATED], "comment" => "Allow established or related traffic to any chain."},
  {"chain" => "OUTPUT", "state" => %w[ESTABLISHED RELATED]},
  {"chain" => "FORWARD", "state" => %w[ESTABLISHED RELATED]},

  {"state" => "INVALID", "target" => "DROP", "comment" => "Drop any incomming invalid packet that could not be identified."},
]

prepend_rules "ipv4", "icmp", [
  {"chain" => "INPUT", "opts" => ["--icmp-type 0"], "comment" => "ICMP echo-request"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 0"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 0"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 3/1"], "comment" => "ICMP host-unreachable"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 3/1"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 3/1"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 3/3"], "comment" => "ICMP port-unreachable"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 3/3"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 3/3"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 3/4"], "comment" => "ICMP fragmentation-needed (filtering that is a BAD idea)"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 3/4"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 3/4"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 4"], "comment" => "ICMP source quench RFC 792 (filtering that is a BAD idea)"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 4"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 4"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 8", "-m limit", "--limit 2/s"], "comment" => "ICMP echo-reply, limited to 2 per second"},
  {"chain" => "INPUT", "opts" => ["--icmp-type 8"], "target" => "DROP"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 8"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 8"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 11"], "comment" => "ICMP Time Exceeded"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 11"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 11"]},

  {"chain" => "INPUT", "opts" => ["--icmp-type 12"], "comment" => "ICMP Parameter Problem"},
  {"chain" => "OUTPUT", "opts" => ["--icmp-type 12"]},
  {"chain" => "FORWARD", "opts" => ["--icmp-type 12"]}
]

prepend_rules "ipv4", "tcp", [
  {"port" => 22, "comment" => "Always allow at least Port 22 (SSH)"}
]

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

#
# Cookbook Name:: iptables_persistent
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

include_recipe "iptables_persistent"

extend IptablesPersistent::RecipeHelpers

#############################################################################
# IPV4

node.default["iptables_persistent"]["ipv4"]["filter"]["chains"]["INPUT"] = "DROP" if node["iptables_persistent"]["ipv4"]["filter"]["chains"]["INPUT"] == "ACCEPT"
node.default["iptables_persistent"]["ipv4"]["filter"]["chains"]["FORWARD"] = "DROP" if node["iptables_persistent"]["ipv4"]["filter"]["chains"]["FORWARD"] == "ACCEPT"

prepend_rules "ipv4", "filter", "any_pre", [
  "# allow any traffic over loopback",
  {"chain" => "INPUT", "interface" => "lo"},
  {"chain" => "OUTPUT", "interface" => "lo"},

  {"!interface" => "lo", "destination" => "127.0.0.1/8", "target" => "REJECT", "comment" => "Reject any traffic from or to 127/0 that doesn't involve the loopback interface."},
  {"protocol" => "tcp", "state" => "NEW", "opts" => ["! --syn"], "target" => "DROP", "comment" => "Drop suspicious TCP traffic"},
  {"protocol" => "tcp", "opts" => ["--fragment"], "target" => "DROP"}, # Fragmented packets
  {"protocol" => "tcp", "opts" => ["--tcp-flags", "ALL", "ALL"], "target" => "DROP"}, # XMAS packets
  {"protocol" => "tcp", "opts" => ["--tcp-flags", "ALL", "NONE"], "target" => "DROP"}, # NULL packet

  {"chain" => "INPUT", "state" => %w[ESTABLISHED RELATED], "comment" => "Allow established or related traffic to any chain."},
  {"chain" => "OUTPUT", "state" => %w[ESTABLISHED RELATED]},
  {"chain" => "FORWARD", "state" => %w[ESTABLISHED RELATED]},

  {"state" => "INVALID", "target" => "DROP", "comment" => "Drop any incomming invalid packet that could not be identified."},
]

prepend_rules "ipv4", "filter", "icmp", [
  {"chain" => "INPUT", "opts" => ["--icmp-type 0"], "comment" => "ICMP echo-reply"},
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

  {"chain" => "INPUT", "opts" => [
      "--icmp-type 8", "-m hashlimit", "--hashlimit-name icmp_ping",
      "--hashlimit-mode srcip", "--hashlimit-upto 3/second", "--hashlimit-burst 5"
    ], "comment" => "ICMP echo-request, limited to 3 per second"},
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

prepend_rules "ipv4", "filter", "tcp", [
  {"port" => 22, "comment" => "Always allow at least Port 22 (SSH)"}
]


#############################################################################
# IPV6

node.default["iptables_persistent"]["ipv6"]["filter"]["chains"]["INPUT"] = "DROP" if node["iptables_persistent"]["ipv6"]["filter"]["chains"]["INPUT"] == "ACCEPT"
node.default["iptables_persistent"]["ipv6"]["filter"]["chains"]["FORWARD"] = "DROP" if node["iptables_persistent"]["ipv6"]["filter"]["chains"]["FORWARD"] == "ACCEPT"

prepend_rules "ipv6", "filter", "any_pre", [
  "# Disable processing of any RH0 packet which could allow a ping-pong of packets",
  {"chain" => "INPUT", "opts" => ["-m", "rt", "--rt-type", 0], "target" => "DROP"},
  {"chain" => "OUTPUT", "opts" => ["-m", "rt", "--rt-type", 0], "target" => "DROP"},
  {"chain" => "FORWARD", "opts" => ["-m", "rt", "--rt-type", 0], "target" => "DROP"},

  "# allow any traffic over loopback",
  {"chain" => "INPUT", "interface" => "lo"},
  {"chain" => "OUTPUT", "interface" => "lo"},

  {"!interface" => "lo", "destination" => "::1", "target" => "REJECT", "comment" => "Reject any traffic from or to ::1 that doesn't involve the loopback interface."},
  {"protocol" => "tcp", "state" => "NEW", "opts" => ["! --syn"], "target" => "DROP", "comment" => "Drop suspicious TCP traffic"},
  {"protocol" => "tcp", "opts" => ["--tcp-flags", "ALL", "ALL"], "target" => "DROP"}, # XMAS packets
  {"protocol" => "tcp", "opts" => ["--tcp-flags", "ALL", "NONE"], "target" => "DROP"}, # NULL packet

  {"chain" => "INPUT", "state" => %w[ESTABLISHED RELATED], "comment" => "Allow established or related traffic to any chain."},
  {"chain" => "OUTPUT", "state" => %w[ESTABLISHED RELATED]},
  {"chain" => "FORWARD", "state" => %w[ESTABLISHED RELATED]},

  {"state" => "INVALID", "target" => "DROP", "comment" => "Drop any incomming invalid packet that could not be identified."},
]

prepend_rules "ipv6", "filter", "icmpv6", [
  {"chain" => "INPUT", "opts" => ["--icmpv6-type 128", "-m limit", "--limit 2/s"], "comment" => "ICMP echo-request, limited to 2 per second"},
  {"chain" => "INPUT", "opts" => ["--icmpv6-type 128"], "target" => "DROP"},
  {"chain" => "OUTPUT", "opts" => ["--icmpv6-type 128"]},
  {"chain" => "FORWARD", "opts" => ["--icmpv6-type 128"]},

  {"chain" => "INPUT", "opts" => ["--icmpv6-type 129"], "comment" => "ICMP echo-reply"},
  {"chain" => "OUTPUT", "opts" => ["--icmpv6-type 129"]},
  {"chain" => "FORWARD", "opts" => ["--icmpv6-type 129"]},

  {"chain" => "INPUT", "opts" => ["--icmpv6-type 1"], "comment" => "ICMP Destination Unreachable"},
  {"chain" => "OUTPUT", "opts" => ["--icmpv6-type 1"]},
  {"chain" => "FORWARD", "opts" => ["--icmpv6-type 1"]},

  {"chain" => "INPUT", "opts" => ["--icmpv6-type 2"], "comment" => "ICMP Packet Too Big"},
  {"chain" => "OUTPUT", "opts" => ["--icmpv6-type 2"]},
  {"chain" => "FORWARD", "opts" => ["--icmpv6-type 2"]},

  {"chain" => "INPUT", "opts" => ["--icmpv6-type 3"], "comment" => "ICMP Time Exceeded"},
  {"chain" => "OUTPUT", "opts" => ["--icmpv6-type 3"]},
  {"chain" => "FORWARD", "opts" => ["--icmpv6-type 3"]},

  {"chain" => "INPUT", "opts" => ["--icmpv6-type 4"], "comment" => "ICMP Parameter Problem"},
  {"chain" => "OUTPUT", "opts" => ["--icmpv6-type 4"]},
  {"chain" => "FORWARD", "opts" => ["--icmpv6-type 4"]},
]

prepend_rules "ipv6", "filter", "tcp", [
  {"port" => 22, "comment" => "Always allow at least Port 22 (SSH)"}
]


# Set some kernel parameters for proper ICMP handling
file '/etc/sysctl.d/60-iptables_persistent.conf' do
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

# Remove old file orphaned from 5e291f9
file '/etc/sysctl.d/60-iptables-persistent.conf' do
  action :delete
end

service 'procps' do
  provider Chef::Provider::Service::Upstart if platform?("ubuntu")
  action :nothing
end

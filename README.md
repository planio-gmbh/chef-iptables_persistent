iptables-persistent Cookbook
============================

This cookbook configures iptables-persistent to setup a full firewall based on
node attributes, settable in roles.

Attributes
----------

### Basic settings

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["dir"]`</td>
    <td>String</td>
    <td>The configuration directory</td>
    <td>`/etc/iptables`</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["rules_v4"]`</td>
    <td>String</td>
    <td>The name of the rules file for IPv4 rules</td>
    <td>`rules` or `rules.v4` depending on the platform</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["rules_v6"]`</td>
    <td>String</td>
    <td>The name of the rules file for IPv6 rules</td>
    <td>`rules.v6`</td>
  </tr>
</table>

### IPv4 rules

These settings describe the IPv4 firewall rules.

Rules can be defined using the folliwing three variants:

#### Integer

If a rule simply consist of an interer, it will result in a rule hat will
open this protocol port (typically UDP or TCP) on the INPUT chain for all.
The generated rule will be similar to this:

    -A INPUT -p TCP --dport 22 -j ACCEPT

#### String

The rule will be included verbatim. It is up to you to ensure proper syntax.

#### Hash

This is the most common form as it allows to define rules without having to
intimitly know the iptables syntax. In the hash, you can use the following
keys to define a single rule:


<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>`protocol`</td>
    <td>String</td>
    <td>The protocol (udp, tcp, icmp, ...). This attribute is only settable in `any_pre` and `any_post` rules. Else it is the same as the rule section.</td>
    <td>contained rule section or emtpy</td>
  </tr>
  <tr>
    <td>`chain`</td>
    <td>String</td>
    <td>The iptables chain, typically either INPUT, OUTPUT, or FORWARD</td>
    <td>INPUT</td>
  </tr>
  <tr>
    <td>`source`</td>
    <td>String</td>
    <td>A single IP or a network specification of the source IP</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`destination`</td>
    <td>String</td>
    <td>A single IP or a network specification of the destination IP</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`interface`</td>
    <td>String</td>
    <td>The network interface (outgoing interface for OUTPUT chain, incommine interface for all others)</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`state`</td>
    <td>String or Array or Strings</td>
    <td>Possible connection state</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`port`</td>
    <td>String or Integer</td>
    <td>The destination port of the packet</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`source_port`</td>
    <td>String or Integer</td>
    <td>The source port of the packet</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`opts`</td>
    <td>Array of Strings</td>
    <td>Additional free-form conditions. This array is just concatenated at the end</td>
    <td>*no default*</td>
  </tr>
  <tr>
    <td>`target`</td>
    <td>String</td>
    <td>The target of the rule. Either another chain or a decision or ACCEPT, REJECT, or DROP</td>
    <td>ACCEPT</td>
  </tr>
  <tr>
    <td>`comment`</td>
    <td>String</td>
    <td>An optional comment which is appended at the end of the line</td>
    <td>*no default*</td>
  </tr>
</table>

The rules can then be appended to the respective section arrays described
below. You can set the rules in different roles where they will be merged
at the end. You just have to make sure to always use the same attribute level
throughout your whole configuration as higher levels completely overwrite lower
levels. E.g. if you have set some rules in `default` and then set some in
`override`, the `default` rules will be completely ignored.

Generally, it is recommended to use `default` in roles.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["defaults"]["INPUT"]`</td>
    <td>String</td>
    <td>The default action for the IPv4 INPUT chain</td>
    <td>`ACCEPT`</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["defaults"]["OUTPUT"]`</td>
    <td>String</td>
    <td>The default action for the IPv4 FORWARD chain</td>
    <td>`ACCEPT`</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["defaults"]["FORWARD"]`</td>
    <td>String</td>
    <td>The default action for the IPv4 FORWARD chain</td>
    <td>`ACCEPT`</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["any_pre"]`</td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>non-protocol-specific rules for the IPv4 firewall. These rules are evaluated first.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["tcp"]`</td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>TCP-specific rules for the IPv4 firewall.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["udp"]`</td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>UDP-specific rules for the IPv4 firewall.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv4"]["any_post"]`</td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>non-protocol-specific rules for the IPv4 firewall. These rules are evaluated last.</td>
    <td>empty Array</td>
  </tr>
</table>

#### IPv6 rules

Note: these rules are only evaluated if the `iptables-persistent` package
available on the node is recent enough, i.e. >= 0.0.20101230.

Rules are evaulated exactly the same as for IPv4.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv6"]["defaults"]["INPUT"]`</td>
    <td>String</td>
    <td>The default action for the IPv6 INPUT chain</td>
    <td>`ACCEPT`</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv6"]["defaults"]["OUTPUT"]`</td>
    <td>String</td>
    <td>The default action for the IPv6 FORWARD chain</td>
    <td>`ACCEPT`</td>
  </tr>
  <tr>
    <td>`["iptables-persistent"]["ipv6"]["defaults"]["FORWARD"]`</td>
    <td>String</td>
    <td>The default action for the IPv6 FORWARD chain</td>
    <td>`ACCEPT`</td>
  </tr>
</table>


default["iptables-persistent"]["ipv4"]["any_pre"] = []
default["iptables-persistent"]["ipv4"]["tcp"] = []
default["iptables-persistent"]["ipv4"]["udp"] = []
default["iptables-persistent"]["ipv4"]["any_post"] = []


Usage
-----
#### iptables-persistent::default

Just include `iptables-persistent` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[iptables-persistent]"
  ]
}
```

This will install iptables-persistent and will setup basic firewall rules.
The firewall fill default to accept everything. You will need to configure
rules in roles or application cookbooks.

#### iptables-persistent::secure_default

This will include the `default` recipe and will configure it with some secure
defaults for a minimally working firewall:

* Drop any IPv6 traffic
* Allow only established incomming and forwarded traffic on IPv4 by default
* Allow all ICMP traffic on IPv4
* Allow IPv4 traffic from the local host to the local IP and back
* Allow Traffic to SSH (Port 22) on IPv4

If you extend these rules, make sure to add rules on the `default` level.
If you set rules on any higher level, they will completely replace all previous
rules. You *have* to make sure that you can still reach your system
before configuring this on production.

Contributing
------------

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Holger Just, Planio GmbH

Copyright 2013, Planio GmbH

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

iptables_persistent Cookbook
============================

This cookbook configures iptables_persistent to setup a full firewall based on
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
    <td><tt>["iptables_persistent"]["dir"]</tt></td>
    <td>String</td>
    <td>The configuration directory</td>
    <td><tt>/etc/iptables</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["rules_v4"]</tt></td>
    <td>String</td>
    <td>The name of the rules file for IPv4 rules</td>
    <td><tt>rules</tt> or <tt>rules.v4</tt>, depending on the platform</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["rules_v6"]</tt></td>
    <td>String</td>
    <td>The name of the rules file for IPv6 rules</td>
    <td><tt>rules.v6</tt></td>
  </tr>
</table>

### IPv4 rules

These settings describe the IPv4 firewall rules.

Rules can be defined using the following four variants:

#### Integer

If a rule simply consist of an interer, it will result in a rule hat will
open this protocol port (typically UDP or TCP) on the INPUT chain for all.
The generated rule will be similar to this:

    -A INPUT -p tcp --dport 22 -j ACCEPT

#### Range

If a rule consist of a Range (e.g. `10000..20000`), it will result in a
rule hat will open the port range on the INPUT chain for all.
The generated rule will be similar to this:

    -A INPUT -p tcp --dport 10000:20000 -j ACCEPT

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
    <td><tt>protocol</tt></td>
    <td>String</td>
    <td>The protocol (udp, tcp, icmp, ...). This attribute is only settable in <tt>any_pre</tt> and <tt>any_post</tt> rules. Else it is the same as the rule section.</td>
    <td>contained rule section or emtpy</td>
  </tr>
  <tr>
    <td><tt>chain</tt></td>
    <td>String</td>
    <td>The iptables chain, typically either INPUT, OUTPUT, or FORWARD</td>
    <td><tt>INPUT</tt></td>
  </tr>
  <tr>
    <td><tt>source</tt></td>
    <td>String</td>
    <td>A single IP or a network specification of the source IP</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>destination</tt></td>
    <td>String</td>
    <td>A single IP or a network specification of the destination IP</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>interface</tt></td>
    <td>String</td>
    <td>The network interface (outgoing interface for OUTPUT chain, incommine interface for all others)</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>state</tt></td>
    <td>Array of Strings</td>
    <td>Possible connection state</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>port</tt></td>
    <td>String or Integer</td>
    <td>The destination port of the packet</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>source_port</tt></td>
    <td>String or Integer</td>
    <td>The source port of the packet</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>opts</tt></td>
    <td>Array of Strings</td>
    <td>Additional free-form conditions. This array is just concatenated at the end</td>
    <td><em>no default</em></td>
  </tr>
  <tr>
    <td><tt>target</tt></td>
    <td>String</td>
    <td>The target of the rule. Either another chain or a decision of <tt>ACCEPT</tt>, <tt>REJECT</tt>, or <tt>DROP</tt></td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>comment</tt></td>
    <td>String</td>
    <td>An optional comment which is appended at the end of the line</td>
    <td><em>no default</em></td>
  </tr>
</table>

### Where to define rules

The rules can then be appended to the respective section arrays described
below. You can set the rules in different roles where they will be merged
at the end. You just have to make sure to always use the same attribute level
throughout your whole configuration as higher levels completely overwrite lower
levels. E.g. if you have set some rules in `default` and then set some in
`override`, the `default` rules will be completely ignored.

Generally, it is recommended to use `default` in roles.

Using the rules hash, you can define rules for all tables available to
iptables. The table below describes the default rules for the `filter` table
which contains the most commonly used rules. For `ipv4`, there are the
`filter`, `nat`, `mangle`, and `raw` tables. For `ipv6` there are the
`filter`, `mangle`, and `raw` tables. Please refer to the iptables
documentation about the use of these tables and the default chains available.

For some example on how to set rules, please have a look at the
`secure_default` recipe.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["chains"]["INPUT"]</tt></td>
    <td>String</td>
    <td>The default action for the IPv4 INPUT chain</td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["chains"]["OUTPUT"]</tt></td>
    <td>String</td>
    <td>The default action for the IPv4 FORWARD chain</td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["chains"]["FORWARD"]</tt></td>
    <td>String</td>
    <td>The default action for the IPv4 FORWARD chain</td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["any_pre"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>non-protocol-specific rules for the IPv4 firewall. These rules are evaluated first.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["tcp"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>TCP-specific rules for the IPv4 firewall.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["udp"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>UDP-specific rules for the IPv4 firewall.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv4"]["filter"]["any_post"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>non-protocol-specific rules for the IPv4 firewall. These rules are evaluated last.</td>
    <td>empty Array</td>
  </tr>
</table>

#### IPv6 rules

Note: these rules are only evaluated if the `iptables_persistent` package
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
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["chains"]["INPUT"]</tt></td>
    <td>String</td>
    <td>The default action for the IPv6 INPUT chain</td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["chains"]["OUTPUT"]</tt></td>
    <td>String</td>
    <td>The default action for the IPv6 FORWARD chain</td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["chains"]["FORWARD"]</tt></td>
    <td>String</td>
    <td>The default action for the IPv6 FORWARD chain</td>
    <td><tt>ACCEPT</tt></td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["any_pre"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>non-protocol-specific rules for the IPv6 firewall. These rules are evaluated first.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["tcp"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>TCP-specific rules for the IPv6 firewall.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["udp"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>UDP-specific rules for the IPv6 firewall.</td>
    <td>empty Array</td>
  </tr>
  <tr>
    <td><tt>["iptables_persistent"]["ipv6"]["filter"]["any_post"]</tt></td>
    <td>Array of Integers, Strings or Hashes</td>
    <td>non-protocol-specific rules for the IPv6 firewall. These rules are evaluated last.</td>
    <td>empty Array</td>
  </tr>
</table>

Usage
-----
#### iptables_persistent::default

Just include `iptables_persistent` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[iptables_persistent]"
  ]
}
```

This will install iptables_persistent and will setup basic firewall rules.
The firewall fill default to accept everything. You will need to configure
rules in roles or application cookbooks.

#### iptables_persistent::secure_default

This will include the `default` recipe and will configure it with some secure
defaults for a minimally working firewall:

* Drop any IPv6 traffic
* Allow traffic on the loopback adapter
* Allow only established incomming and forwarded traffic on IPv4 by default
* Allow important ICMP traffic on IPv4
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

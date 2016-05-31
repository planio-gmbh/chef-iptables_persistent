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
module IptablesPersistent
  module TemplateHelpers
    def rules(ip_proto, table)
      table_rules = node["iptables_persistent"][ip_proto][table]
      rule_types = ["any_pre"] + (table_rules.keys.sort - %w[any_pre any_post chains]) + ["any_post"]

      rule_types.inject([]) do |rules, rule_type|
        force_protocol = %w[any_pre any_post].include?(rule_type) ? nil : rule_type
        added_rules = expand_rules(table_rules[rule_type], force_protocol)

        if added_rules.any?
          rules << nil if rules.any?
          rules << "### #{rule_type.upcase} RULES"
        end
        rules += added_rules
      end
    end

    def expand_rules(raw_rules, force_protocol=nil)
      raw_rules.to_a.collect do |rule|
        case rule
        when Numeric
          "-A INPUT #{"-p #{force_protocol}" if force_protocol} --dport #{rule.to_i} -j ACCEPT"
        when Range
          "-A INPUT #{"-p #{force_protocol}" if force_protocol} --dport #{rule.first.to_i}:#{rule.last(1).first.to_i} -j ACCEPT"
        when Hash
          expand_hash_rule(rule)
        else
          rule
        end
      end
    end

    # @param rule [#to_hash]
    def expand_hash_rule(rule, force_protocol=nil)
      # workaround for CHEF-3953
      rule = rule.to_hash if rule.respond_to?(:to_hash)

      if force_protocol
        rule["protocol"] = force_protocol
        rule.delete("!protocol")
      end
      rule["chain"] ||= "INPUT"
      rule["target"] ||= "ACCEPT"

      str = ""
      str << "# #{rule["comment"]}\n" if rule["comment"]
      str << "-A #{rule["chain"]}"
      str << rule_part(rule, "protocol"){ |neg, v| "#{neg} -p #{v}" }
      str << rule_part(rule, "source"){ |neg, v| "#{neg} -s #{IPAddress(v).to_string}" }
      str << rule_part(rule, "destination"){ |neg, v| "#{neg} -d #{IPAddress(v).to_string}" }
      str << rule_part(rule, "interface") do |neg, v|
        selector = rule["chain"] == "OUTPUT" ? "-o" : "-i"
        "#{neg} #{selector} #{v}"
      end
      str << " -m state --state #{Array(rule["state"]).map{|s| s.to_s.upcase}.join(",")}" if rule["state"]
      str << rule_part(rule, "port") do |neg, v|
        ports = Array(v)
        ports.count > 1 ? " -m multiport#{neg} --dports #{ports.join(",")}" : "#{neg} --dport #{v}"
      end
      str << rule_part(rule, "source_port") do |neg, v|
        ports = Array(v)
        ports.count > 1 ? " -m multiport#{neg} --sports #{ports.join(",")}" : "#{neg} --sport #{v}"
      end
      opts = (rule["opts"] || []).to_a.flatten.compact
      str << " " << opts.join(" ") if opts.any?
      str << " -j #{rule["target"]}"
      str
    end

    def rule_part(rule, key)
      if rule.has_key?("!#{key}")
        yield " !", rule["!#{key}"]
      elsif rule.has_key?(key)
        yield "", rule[key]
      else
        ""
      end
    end
  end
end

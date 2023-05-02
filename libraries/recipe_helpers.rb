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
  module RecipeHelpers
    def prepend_rules(protocol, table, rule_type, rules)
      existing = node.default["iptables_persistent"][protocol][table][rule_type]
      node.default["iptables_persistent"][protocol][table][rule_type] = rules + existing.to_a
    end

    # Limit new connections to `limit` new connections per `seconds` seconds per
    # source IP Additional connection attempts will be DROP'ed
    #
    # @return Array<Hash> a list of new rules
    def limit_rate_rules(rule = {}, name:, limit:, seconds:)
      limit = limit.to_i
      raise ArgumentError, "limit must be > 0" if limit <= 0

      seconds = seconds.to_i
      raise ArgumentError, "seconds must be > 0" if seconds <= 0

      name = name.to_s
      raise ArgumentError, "name must match /\w+/" unless name =~ /\A\w+\z/

      # If an entry was already in the `name` list, we check if we have seen >=
      # `limit` hits (i.e. new connection attempts) within the last `seconds`
      # seconds from this IP. If this is the case, we drop the packet and update
      # the list with the new attempt.
      [
        rule.merge(
          "opts" => (rule['opts'] || []) + [
            "-m recent", "--update", "--seconds #{seconds}", "--hitcount #{limit}", "--name #{name}", "--rsource", "--rttl"
          ],
          "target" => "DROP"
        ),

        # If there was no entry in the list yet or it dod not exceed the limits,
        # we insert or update the list entry, but allow the packet. This is the
        # normal case where there were only few attempts.
        rule.merge(
          "opts" => (rule['opts'] || []) + [
            "-m recent", "--set", "--name #{name}", "--rsource"
          ],
          "target" => "ACCEPT"
        )
      ]
    end

    # Limit the overall number of active connections from a source IP to `limit`
    # connections.
    #
    # @return Array<Hash> a list of new rules
    def limit_active_rules(rule = {}, limit:)
      limit = limit.to_i
      raise ArgumentError, "limit must be > 0" if limit <= 0

      rule.merge(
        "opts" => (rule['opts'] || []) + [
          "-m connlimit", "--connlimit-above #{limit}"
        ],
        "target" => "REJECT"
      )
    end
  end
end

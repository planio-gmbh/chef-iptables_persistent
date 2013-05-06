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
    def prepend_rules(protocol, rule_type, rules)
      existing = node.default["iptables-persistent"][protocol][rule_type]
      node.default["iptables-persistent"][protocol][rule_type] = rules + existing.to_a
    end
  end
end

#
# Cookbook Name:: iptables_persistent
# Recipe:: default
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

package "iptables"
package "iptables-persistent"

chef_gem "ipaddress"
require "ipaddress"

directory node["iptables_persistent"]["dir"] do
  action :create
end

%w[v4 v6].each do |version|
  template "iptables-persistent_#{version}" do
    path "#{node["iptables_persistent"]["dir"]}/#{node["iptables_persistent"]["rules_#{version}"]}"
    source "rules.erb"
    owner "root"
    group "root"
    mode "0644"

    variables :protocol => "ip#{version}"
    notifies :create, "ruby_block[restart iptables-persistent]", :immediately
  end
end

ruby_block "restart iptables-persistent" do
  action :nothing
  block do
    fail2ban = resources(:service => "fail2ban") rescue nil

    fail2ban.run_action(:stop) if fail2ban
    resources(:service => "iptables-persistent").run_action(:start)
    fail2ban.run_action(:start) if fail2ban
  end
end

service "iptables-persistent" do
  supports :status => true
  status_command "/bin/false"
  action [:enable]
end

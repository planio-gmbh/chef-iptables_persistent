# Set to nil or an empty array to not apply any special ssh rules in the
# secure_default recipe.
default["iptables_persistent"]["secure_default"]["ssh"]["ports"] = [22]

# Set to an integer to limit the overall number of current TCP connections per
# source IP to any of the SSH ports
default["iptables_persistent"]["secure_default"]["ssh"]["limit"] = nil

# Set to an integer to limit the number of new connections per limit_seconds
# per source IP to any of the SSH ports
default["iptables_persistent"]["secure_default"]["ssh"]["limit_hits"] = nil
default["iptables_persistent"]["secure_default"]["ssh"]["limit_seconds"] = 60

# If neither limit nor limit_hits is set, we do not apply any rate limiting on
# the firewall level but plainly allow all ssh ports.

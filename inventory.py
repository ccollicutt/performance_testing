#!/usr/bin/python

import sys

try:
	import json
except:
	print "Can't import json..."
	sys.exit(1)


file = open("/var/lib/misc/dnsmasq.leases", "r")

servers = []
groups = {}

for line in file.readlines():
	date, mac, ip, name1, name2 = line.split(" ")
	group = 'undefined'

	if group not in groups:
		groups[group] = []
	groups[group].append(ip)

print json.dumps(groups)

#print "number of servers is " + str(len(servers))

#print "Dumping json..."
#try:
#	json.dumps(servers)
#except:
#	print "Could not dump json..."
#	sys.exit(1)

sys.exit(0)

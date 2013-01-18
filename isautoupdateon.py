#!/usr/bin/python

## required libraries for making xmlrpc calls and interpreting timestamps
import xmlrpclib 

SATELLITE_URL = 
SATELLITE_LOGIN = 
SATELLITE_PASSWORD = 

## Create xml-rpc connection object to the sat server
satellite = xmlrpclib.Server(SATELLITE_URL, verbose=0)

## Log in via xml-rpc
key = satellite.auth.login(SATELLITE_LOGIN, SATELLITE_PASSWORD)

## instantiate empty arrays
enabled = []
disabled = [] 

## collect array of active systems
systems = satellite.system.listActiveSystems(key)
print "Retrieved " + str(len(systems)) + " active systems total"

## iterate over systems, append them to arrays by whether they're enabled 
for system in systems:
	systemdetails = satellite.system.getDetails(key, system['id'])
	# auto_update is boolean in Satellite, so tests true or false
	if systemdetails['auto_update']:
		enabled.append(systemdetails['hostname'])
	else:
		disabled.append(systemdetails['hostname'])

## print count of enabled and disabled systems, print hostnames of any enabled hosts
print str(len(disabled)) + " systems have auto_update disabled"
print str(len(enabled)) + " systems have auto_update enabled"
if len(enabled) > 0: 
	print "hostnames with auto_update enabled:"
	for host in enabled:
		print host

## destroy satellite login session
satellite.auth.logout(key)

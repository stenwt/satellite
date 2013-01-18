#!/usr/bin/python

## required libraries for making xmlrpc calls and interpreting timestamps
import xmlrpclib, datetime

SATELLITE_URL = 
SATELLITE_LOGIN = 
SATELLITE_PASSWORD = 

print "config channel, config file, perms, owner, revision, rev date"

## Create xml-rpc connection object to the sat server
satellite = xmlrpclib.Server(SATELLITE_URL, verbose=0)

## Log in via xml-rpc
key = satellite.auth.login(SATELLITE_LOGIN, SATELLITE_PASSWORD)

## collect array of active systems
channels = satellite.configchannel.listGlobals(key)

## iterate over systems, append them to arrays by whether they're enabled 
for channel in channels:
	#channeldetails = satellite.configchannel.getDetails(key, channel['label'])
	#channellabel = channeldetails['label']
	#channelname = channeldetails['name']
	files = satellite.configchannel.listFiles(key,channel['label'])
	for file in files: 
		files = []
		files.append(file['path'])
		filedetails = satellite.configchannel.lookupFileInfo(key, channel['label'], files)
		#modified = filedetails[0]['modified'].ctime()
		print channel['name'] + " , " + file['path'] + " , " + filedetails[0]['permissions_mode'] + " , " + str(filedetails[0]['revision']) + " , " # + modified

## destroy satellite login session
satellite.auth.logout(key)

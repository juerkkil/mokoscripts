#!/usr/bin/python

# dump SMS messages from SIM card to stdout
import sys
import dbus
from dbus.mainloop.glib import DBusGMainLoop
DBusGMainLoop(set_as_default=True)

bus = dbus.SystemBus()
device = bus.get_object( 'org.freesmartphone.ogsmd', '/org/freesmartphone/GSM/Device' )
iface = dbus.Interface(device, 'org.freesmartphone.GSM.SIM')
for i in iface.RetrieveMessagebook("all"):
#	print unicode(i[3]).encode("utf-8")
	number = i[2]
	message = unicode(i[3]).encode("utf-8")
	if('timestamp' in i[4]):
		timestamp = unicode(i[4]['timestamp']).encode("utf-8")
	else:
		timestamp = "Unknown"
	print i[0]
	print i[1]
	print number
	print timestamp
	print message
	print "\n"


#!/usr/bin/env python
# coding: utf -8

# [SNIPPET_NAME: Show notification bubble]
# [SNIPPET_CATEGORIES: Notify OSD]
# [SNIPPET_DESCRIPTION: Show a simple notification bubble]
# [SNIPPET_AUTHOR: Jono Bacon <jono@ubuntu.com>]
# [SNIPPET_LICENSE: GPL]

import pynotify
import os
import sys

# say the message loud and clear requires espeak 
def speak():
	os.system("espeak -v de "+chr(34)+" - "+sys.argv[2]+chr(34)) 

pynotify.init('Rene')

# a image if possible
imageURI = 'file://' + os.path.abspath(os.path.curdir) + '/home/user/backup/logo.png'
# show the message
if (len(sys.argv)==3):
	n = pynotify.Notification(sys.argv[1], sys.argv[2], imageURI)
	n.show()
	speak()
elif (len(sys.argv)==2):
	n = pynotify.Notification(sys.argv[0], sys.argv[1], imageURI)
	n.show()
	#speak()
else:
	n = pynotify.Notification("test", "1 2 3 4 .. ", imageURI)
	n.show()
	print "No arguments given: starting with -> bubble topic message"

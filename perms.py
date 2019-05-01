#!/usr/bin/python
import time
import datetime
import os

print "Start permission check/change: " , datetime.datetime.now()
for root, dir, files in os.walk("/cadcam"):
    for f in files:
        fullpath = root + "/" + f
        if (os.path.isfile(fullpath) and (os.stat(fullpath).st_mode & 0400) == 0400):
                os.chmod(fullpath, 0755)
print "Finished permission check/change: " , datetime.datetime.now()

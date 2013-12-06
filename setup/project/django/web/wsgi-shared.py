#Generic wsgi that can be shared between all user dev sites and the public site.
#Adds web dir to the python path and adds the site config env.

#insert the contents of this file into wsgi.py before the line:
#from django.core.wsgi import get_wsgi_application

import sys
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
sys.path.append(os.path.join(PROJECT_ROOT, 'web'))

import subprocess
out = subprocess.getoutput("ps -p " + str(os.getpid()) + " -o args=")
start = out.find("wsgi:") + len("wsgi:")
os.environ['SITE_CONFIG'] = out[start : out.find(')', start)]

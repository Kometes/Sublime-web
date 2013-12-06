#Generic settings that can be shared between all user-dev/public sites.
#Copy to your settings.py.

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.realpath(__file__))))
SITE_NAME = os.path.basename(PROJECT_ROOT)
#user-dev/public site differentiated by project directory name
SITE_DEV = "-dev-" in SITE_NAME
SITE_DEV_USER = SITE_NAME.split('-')[-1] if SITE_DEV else ""
#apache virtualhost settings stored SITE_CONFIG env, tells us if the site is down
SITE_DOWN = os.environ.get('SITE_CONFIG', '').endswith("-down")
SITE_DOWN_DEV = os.environ.get('SITE_CONFIG', '').endswith("-down-dev")

#user-dev/public site domain
DOMAIN = 'foo.com'
if SITE_DEV:
    SITE_DOMAIN = SITE_DEV_USER + '.dev.' + DOMAIN
else:
    if not SITE_DOWN_DEV:
        SITE_DOMAIN = DOMAIN
    else:
        SITE_DOMAIN = 'dev.' + DOMAIN

DEBUG = SITE_DEV
TEMPLATE_DEBUG = DEBUG

#All user-dev/public sites should have separate databases.
#Ex. 2 users and the public site need these databases created: foo-dev-alice foo-dev-bob foo.
DATABASES = {
    'default': {
        'NAME': SITE_NAME,
    }
}

#set up user-dev/public site email to receive errors
SERVER_EMAIL = "django@" + SITE_DOMAIN
DEFAULT_FROM_EMAIL = SERVER_EMAIL
admins = {
    'alice':        ("Alice", "alice@foo.com"),
    'bob':          ("Bob", "bob@foo.com")
}
ADMINS = [admins[SITE_DEV_USER]] if SITE_DEV else list(admins.values())
MANAGERS = ADMINS

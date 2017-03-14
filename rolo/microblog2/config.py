# -*- coding: utf8 -*-
import os
basedir = os.path.abspath(os.path.dirname(__file__))

CSRF_ENABLED = True
SECRET_KEY = 'you-will-never-guess'

OAUTH_PROVIDERS = {
    'facebook': {
        'id':                       'facebook',
        'name':                     'Facebook', 
        'type':                     'oauth',
        'consumer_key':             '1007224459316342',
        'consumer_secret':          '7b2e52a6052aa340bc517a9c88ac60f6',
        'request_token_params':     {'scope': 'email'},
        'base_url':                 'https://graph.facebook.com',
        'callback_url':             '/login/authorized', 
        'authorize_url':            'https://www.facebook.com/dialog/oauth',
        'request_token_url':        None,
        'access_token_url':         '/oauth/access_token',
        'access_token_method':      'GET'
    },
    'twitter':  {
        'id':                       'twitter',
        'name':                     'Twitter', 
        'type':                     'oauth',
        'consumer_key':             'bPx16mRLknWGfZUGLcflEh8MX',
        'consumer_secret':          'unRU8RXmNU1ui7lU7JfWUnI8YORo7G2XtnjNxsDXwvpmpJDjcI',
        'token':                    '772933167468650496-VKCOQ6yF56vZ107ZrYGiUL4Y9OhOJZ1',
        'token_secret':             'm9bWFogQqKmN2mxPKs3mpY8SqWscnCSS5rPeLmtzPOdhC',
        'request_token_params':     None,
        'base_url':                 'https://api.twitter.com/1.1/',
        'request_token_url':        'https://api.twitter.com/oauth/request_token',
        'access_token_url':         'https://api.twitter.com/oauth/access_token',
        'authorize_url':            'https://api.twitter.com/oauth/authenticate',
        'access_token_method':      'GET'
    }
}

if os.environ.get('DATABASE_URL') is None:
    SQLALCHEMY_DATABASE_URI = ('sqlite:///' + os.path.join(basedir, 'app.db') +
                               '?check_same_thread=False')
else:
    SQLALCHEMY_DATABASE_URI = os.environ['DATABASE_URL']

SQLALCHEMY_MIGRATE_REPO = os.path.join(basedir, 'db_repository')
SQLALCHEMY_RECORD_QUERIES = True
WHOOSH_BASE = os.path.join(basedir, 'search.db')

# Whoosh does not work on Heroku
WHOOSH_ENABLED = os.environ.get('HEROKU') is None

# slow database query threshold (in seconds)
DATABASE_QUERY_TIMEOUT = 0.5

# email server
#MAIL_SERVER = 'mail.1stcallhelp.co.uk'  # your mailserver
MAIL_SERVER = ''
MAIL_PORT = 25
MAIL_USE_TLS = True
MAIL_USE_SSL = False
#MAIL_USERNAME = os.environ.get('MAIL_USERNAME')
#MAIL_PASSWORD = os.environ.get('MAIL_PASSWORD')
MAIL_USERNAME = 'carl@1stcallhelp.co.uk'
MAIL_PASSWORD = 'manager*#09#'

# available languages
LANGUAGES = {
    'en': 'English',
    'es': 'Español'
}

# microsoft translation service
MS_TRANSLATOR_CLIENT_ID = ''  # enter your MS translator app id here
MS_TRANSLATOR_CLIENT_SECRET = ''  # enter your MS translator app secret here

# administrator list

ADMINS = ['carl@1stcallhelp.co.uk']

# pagination
POSTS_PER_PAGE = 4
MAX_SEARCH_RESULTS = 50
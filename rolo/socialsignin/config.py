OAUTH_CREDENTIALS = {
    'facebook': { 
        'base_url': 'https://graph.facebook.com/',
        'access_token_url': 'https://graph.facebook.com/oauth/access_token',
        'authorize_url': 'https://www.facebook.com/dialog/oauth',
        'consumer_key': '193577541062365',
        'consumer_secret': 'f4f732fa19625d5a12b5669ba5c586bd',
        'request_token_params': {'scope': 'email'}
    },
    'twitter': {
        'base_url': 'https://api.twitter.com/1/',
        'request_token_url': 'https://api.twitter.com/oauth/request_token',
        'access_token_url': 'https://api.twitter.com/oauth/access_token',
        'authorize_url': 'https://api.twitter.com/oauth/authenticate',
        'consumer_key': 'bPx16mRLknWGfZUGLcflEh8MX',
        'consumer_secret': 'unRU8RXmNU1ui7lU7JfWUnI8YORo7G2XtnjNxsDXwvpmpJDjcI'
    },
    'google': {
        'client_id': '105329164027958299449',
        'project_id': 'firstcallhelp-co-uk',
        'authorize_url': 'https://accounts.google.com/o/oauth2/auth',
        'access_token_url': 'https://accounts.google.com/o/oauth2/token',
        'auth_provider_x509_cert_url': 'https://www.googleapis.com/oauth2/v1/certs'
    }
}

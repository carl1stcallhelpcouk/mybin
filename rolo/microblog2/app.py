# coding: utf-8

from flask import Flask, redirect, url_for, session, request, g, flash, render_template
from flask_oauthlib.client import OAuth, OAuthException
from config import SECRET_KEY, OAUTH_PROVIDERS

app = Flask(__name__)
app.debug = True
app.secret_key = SECRET_KEY
oauth = OAuth(app)

provider = OAUTH_PROVIDERS['twitter']

oauth_provider = oauth.remote_app(
    provider['id'],
    consumer_key=provider['consumer_key'],
    consumer_secret=provider['consumer_secret'],
    request_token_params=provider['request_token_params'],
    base_url=provider['base_url'],
    request_token_url=provider['request_token_url'],
    access_token_url=provider['access_token_url'],
    access_token_method=provider['access_token_method'],
    authorize_url=provider['authorize_url']
)

@app.before_request
def before_request():
    g.user = None
    if 'oauth_provider_oauth' in session:
        g.user = session['oauth_provider_oauth']

@app.route('/')
def index():
    if provider['id'] == 'twitter':
        tweets = None
        if g.user is not None:
            resp = oauth_provider.request('statuses/home_timeline.json')
            if resp.status == 200:
                tweets = resp.data
            else:
                flash('Unable to load tweets from Twitter.')
            return tweets #render_template('index.html', tweets=tweets)
    else:
        return tweets #redirect(url_for('login'))

@app.route('/tweet', methods=['POST'])
def tweet():
    if g.user is None:
        return redirect(url_for('login', next=request.url))
    status = request.form['tweet']
    if not status:
        return redirect(url_for('index'))
    resp = oauth_provider.post('statuses/update.json', data={
        'status': status
    })

    if resp.status == 403:
        flash("Error: #%d, %s " % (
            resp.data.get('errors')[0].get('code'),
            resp.data.get('errors')[0].get('message'))
        )
    elif resp.status == 401:
        flash('Authorization error with Twitter.')
    else:
        flash('Successfully tweeted your tweet (ID: #%s)' % resp.data['id'])
    return redirect(url_for('index'))

@app.route('/login')
def login():
    callback = url_for(
        'oauth_provider_authorized',
        next=request.args.get('next') or request.referrer or None,
        _external=True
    )
    return oauth_provider.authorize(callback=callback)


@app.route('/logout')
def logout():
    session.pop('oauth_provider_oauth', None)
    return redirect(url_for('index'))

@app.route('/oauthorized')
def oauthorized():
    resp = oauth_provider.authorized_response()
    if resp is None:
        flash('You denied the request to sign in.')
    else:
        session['oauth_provider_oauth'] = resp
    return redirect(url_for('index'))


@app.route('/login/authorized')
def oauth_provider_authorized():
    resp = oauth_provider.authorized_response()
    if resp is None:
        return 'Access denied: reason=%s error=%s' % (
            request.args['error_reason'],
            request.args['error_description']
        )
    if isinstance(resp, OAuthException):
        return 'Access denied: %s' % resp.message

    session['oauth_token'] = (resp['access_token'], '')
    me = oauth_provider.get('/me')
    return 'Logged in as id=%s name=%s redirect=%s' % \
        (me.data['id'], me.data['name'], request.args.get('next'))


@oauth_provider.tokengetter
def get_oauth_provider_oauth_token():
    if 'oauth_provider_oauth' in session:
        resp = session['oauth_provider_oauth']
        return resp['access_token'], resp['expires']
    else:
        return session.get('oauth_token')

if __name__ == '__main__':
    app.run()

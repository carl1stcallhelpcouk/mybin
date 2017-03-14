#!/usr/bin/env python
# coding=utf-8

from flask import Flask
from oauth import OAuthSignIn

from config import OAUTH_CREDENTIALS

app = Flask(__name__)
app.config['SECRET_KEY'] = 'you-will-never-guess'
app.config['OAUTH_CREDENTIALS'] = OAUTH_CREDENTIALS


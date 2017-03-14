#!/usr/bin/python
from mailjet_rest import Client
import os
api_key = os.environ['MJ_APIKEY_PUBLIC']
api_secret = os.environ['MJ_APIKEY_PRIVATE']
mailjet = Client(auth=(api_key, api_secret))
data = {
    'FromEmail': 'carl@1stcallhelp.co.uk',
    'FromName': 'Mailjet Pilot',
    'Subject': 'Your email flight plan!',
    'Text-part': 'Dear passenger, welcome to Mailjet! May the delivery force be with you!',
    'Html-part': '<h3>Dear passenger, welcome to Mailjet!</h3><br />May the delivery force be with you!',
    'Recipients': [{'Email':'carl@1stcallhelp.co.uk'}]
}
result = mailjet.send.create(data=data)
print (result.status_code)
print (result.json())
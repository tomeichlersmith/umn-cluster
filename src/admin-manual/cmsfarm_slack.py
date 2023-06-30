#!/home/user1/phansen/local/bin/python

""" 
For a message: 
curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}'
<full-slack-https-hook>

For a File
curl -F file=@graph.png -F channels=C7E3JCYG2 -F token=<slack-token>  https://slack.com/api/files.upload
"""

import urllib2
import json
import requests

bot_token = "<slack-bot-token>"
token = "<slack-token>"
def post_message(text):
   url = "<full-slack-https-hook>"
   headers = {'content-type': 'application/json'}
   payload = {"text":text}

   data = json.dumps(payload)
   req = urllib2.Request(url, data)
   response = urllib2.urlopen(req)
   the_page = response.read()

def post_image(filename, channels):

    f = {'file': (filename, open(filename, 'rb'), 'image/png', {'Expires':'0'})}
    response = requests.post(url='https://slack.com/api/files.upload', data=
       {'token': bot_token, 'channels': channels, 'media': f}, 
       headers={'Accept': 'application/json'}, files=f)
    return response.text

def post_image_from_url(name, url, channels):

    f = {'file': (name, urllib2.urlopen(url).read(), 'image/png', {'Expires':'0'})}
    response = requests.post(url='https://slack.com/api/files.upload', data=
       {'token': bot_token, 'channels': channels, 'media': f}, 
       headers={'Accept': 'application/json'}, files=f)
    return response.text
def api_call(call, data):
    payload = {'token': bot_token,}
    payload.update(data)
    response = requests.post(url='https://slack.com/api/' + call, data=payload)
    return response.text

import re
cmsfarm_url = "http://monitor.physics.umn.edu/ganglia/?m=load_one&r=day&s=descending&c=cmsfarm&h=&sh=1&hc=4&z=small"
f = urllib2.urlopen(cmsfarm_url)
website = f.read()
f.close()

#print re.match(".*<tr><td colspan=2>Avg Load (15, 5, 1m):<br>&nbsp;&nbsp;<b>103%, 103%, 103%</b></td></tr>.*", 
for line in website.split('\n'):
   m = re.match(".*Avg Load.*<b>.*?([\d]+%), ([\d%]+), ([\d%]+)</b>.*", line)
   if m:
      load15, load5, load1, = m.groups()

channel = "C7F83CMST"
cpu_url = "http://monitor.physics.umn.edu/ganglia/graph.php?g=cpu_report&z=medium&c=cmsfarm&m=load_one&r=day"
response = post_image_from_url("CMS Farm: CPU Load",cpu_url, channel)
response = json.loads(response)
api_call("files.comments.add", {"comment": "Average Load in the last 15 Min " + load15, "file":response["file"]["id"]})

load_url = "http://monitor.physics.umn.edu/ganglia/graph.php?g=load_report&z=medium&c=cmsfarm&m=load_one&r=day"
response = post_image_from_url("CMS Farm: Core Load",load_url, channel)
#print api_call("channels.setTopic", {"channel":"C7E3JCYG2", "topic":"newtopic"})
#test

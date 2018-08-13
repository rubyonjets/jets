from pprint import pprint
import json
import os
import os.path
import mimetypes
import sys

def lambda_handler(event, context):
    public_path = "public%s" % event["path"]

    body = None
    if os.path.exists(public_path):
        body = render(public_path)

    if body:
        mimetype = mimetypes.guess_type(public_path)
        headers = {"Content-Type": mimetype[0]}
        return response(body, 200, headers)
    else:
        return response("404 Not Found: %s" % public_path, 404)

def render(file=None):
    with open(file,'r') as f:
        return(f.read())

def response(body, status_code=200, headers={}):
    default_headers = {
        'Content-Type': 'text/html',
        'Access-Control-Allow-Origin': '*'
    }
    # http://treyhunner.com/2016/02/how-to-merge-dictionaries-in-python/
    headers = {**default_headers, **headers}
    return {
        'statusCode': str(status_code),
        'body': body,
        'headers': headers,
        }

def log(message):
    print(message, file=sys.stderr)

if __name__ == '__main__':
    with open('event.json') as f:
        data = json.load(f)
    # pprint(data)
    # print(lambda_handler(data, {}))
    print(json.dumps(lambda_handler(data, {}))) # if result is json
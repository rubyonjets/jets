from pprint import pprint
import json

import os.path

def response(body, status_code=200):
    return {
        'statusCode': str(status_code),
        'body': body,
        'headers': {
            'Content-Type': 'text/html',
            'Access-Control-Allow-Origin': '*'
            },
        }

def render(file=None):
    with open(file,'r') as f:
        return(f.read())

def handle(event, context):
    # html = render(file="public/foo.html")
    # return response(html, 200)

    print(event)
    return response(json.dumps(event), 200)

if __name__ == '__main__':
    print(handle({"test": 1}, {}))
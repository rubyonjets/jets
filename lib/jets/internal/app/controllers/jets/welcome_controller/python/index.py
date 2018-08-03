from pprint import pprint
import json

import os.path


def response(message, status_code):
    return {
        'statusCode': str(status_code),
        'body': json.dumps(message),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
            },
        }

def handle(event, context):
    homepage = "public/index.html"
    html = None
    if os.path.exists(homepage):
        with open(homepage,'r') as f:
            html = f.read()
    return response(html, 200)

if __name__ == '__main__':
    print(handle({}, {}))
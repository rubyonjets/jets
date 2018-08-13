from pprint import pprint
import json
import os.path

def lambda_handler(event, context):
    homepage = "public/index.html"
    html = None
    if os.path.exists(homepage):
        with open(homepage,'r') as f:
            html = f.read()
    return response(html, 200)

def response(body, status_code):
    return {
        'statusCode': str(status_code),
        'body': body,
        'headers': {
            'Content-Type': 'text/html',
            'Access-Control-Allow-Origin': '*'
            },
        }

if __name__ == '__main__':
    print(lambda_handler({}, {}))
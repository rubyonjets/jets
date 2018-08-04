from pprint import pprint
import json
import os
import os.path

def handle(event, context):
    public_path = "public%s" % event["path"]

    body = None
    if os.path.exists(public_path):
        with open(public_path, 'r') as f:
            body = f.read()
    else:
        print("path not found")

    if body:
        return response(body, 200)
    else:
        return response("404 Not Found: %s" % public_path, 404)


def render(file=None):
    with open(file,'r') as f:
        return(f.read())

def response(body, status_code=200):
    return {
        'statusCode': str(status_code),
        'body': body,
        'headers': {
            'Content-Type': 'text/html',
            'Access-Control-Allow-Origin': '*'
            },
        }

if __name__ == '__main__':
    with open('event.json') as f:
        data = json.load(f)
    # pprint(data)

    print(handle(data, {}))
    # print(json.dumps(handle(data, {}))) # if result is json
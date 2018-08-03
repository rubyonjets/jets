from pprint import pprint
import json

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
    print("index")
    pprint(event)

    try:
        # print("value1 = " + event['key1'])
        # print("value2 = " + event['key2'])
        return response({'message': 'Jets::WelcomeController#index'}, 200)
    except Exception as e:
        return response({'message': e.message}, 400)

if __name__ == '__main__':
    print(handle({"test": "1"}, {}))
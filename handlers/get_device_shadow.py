import boto3
import json


def get_thing_state(thing_name):
    client = boto3.client('iot-data', region_name='us-east-1')
    try: 
        response = client.get_thing_shadow(thingName=thing_name)
        streamingBody = response["payload"]
        jsonState = json.loads(streamingBody.read())
        return jsonState
    except ResourceNotFoundException:
        state_data = {
            'state': {
                'desired': {
                    'alarm': 'OFF'
                }, 
                'reported': {
                    'alarm':'OFF'
                }
            }
        }
        client.update_thing_shadow(
            thingName=thing_name,
            payload=json.dumps(state_data)
        )
        return state_data['state']
    

def handler(event, context):
    print(event)
    thing_name = event['queryStringParameters']['thing_name']
    state = get_thing_state(thing_name)
    response = {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin":"*"},
        "body": json.dumps(state)
    }
    return response

import boto3
import json


 
print jsonState
print jsonState["state"]["reported"]["pump_mode"]

def get_state():
    client = boto3.client('iot-data', region_name='us-east-1')
    response = client.get_thing_shadow(thingName='raspi')
    streamingBody = response["payload"]
    jsonState = json.loads(streamingBody.read())
    return jsonState["state"]["reported"]["pump_mode"]


def handler(event, context):
    response = {
        "statusCode": 200,
        "body": json.dumps(body)
    }

    return response

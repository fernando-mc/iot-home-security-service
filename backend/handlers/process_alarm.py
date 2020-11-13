import boto3
import json
import datetime
import time

client = boto3.client('iot-data', region_name='us-east-1')
sns = boto3.client('sns')

def get_thing_state(thing_name):
    response = client.get_thing_shadow(thingName=thing_name)
    streamingBody = response["payload"]
    jsonState = json.loads(streamingBody.read())
    return jsonState["state"]


def handler(event, context):
    print(event)
    thing_name = event['clientid']
    message = event['message']
    if message == 'motion detected':
        last_alarm_state = str(int(datetime.datetime.now().timestamp()))
        human_readable_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(int(last_alarm_state)))
        sns.publish(
            PhoneNumber="+15412076854",
            Message="Your security system just detected motion at:" + human_readable_time
        )
        response = client.update_thing_shadow(
            thingName=thing_name,
            payload=json.dumps({
                'state': {
                    'reported': {
                        'alarm':'on',
                        'last_alarm': last_alarm_state
                    }
                }
            })
        )
    response = {
        "statusCode": 200,
        "body": json.dumps(get_thing_state(thing_name))
    }
    return response

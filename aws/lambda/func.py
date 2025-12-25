import json
import boto3

# Initialize the DynamoDB resource
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('crc-visitor-counter')

def lambda_handler(event, context):
    # 1. Retrieve the current count from the table
    response = table.get_item(Key={
        'id': 'visitors'
    })
    
    # Check if item exists, if not, initialize count
    if 'Item' in response:
        count = response['Item']['count']
    else:
        count = 0

    # 2. Increment the count
    new_count = int(count) + 1

    # 3. Update the item in the table
    table.put_item(Item={
        'id': 'visitors',
        'count': new_count
    })

    # 4. Return the new count with CORS headers for the frontend
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*', # Required for website access
            'Access-Control-Allow-Methods': 'GET,POST,OPTIONS'
        },
        'body': json.dumps({'count': str(new_count)})
    }
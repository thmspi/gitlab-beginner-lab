def lambda_handler(event, context):
    name = event.get('name', 'GitLab')
    return {"statusCode": 200, "body": f"Hello {name}!"}

from src.lambda_function import lambda_handler


def test_default_name():
    response = lambda_handler({}, None)
    assert response == {"statusCode": 200, "body": "Hello GitLab!"}


def test_custom_name():
    response = lambda_handler({"name": "Ada"}, None)
    assert response == {"statusCode": 200, "body": "Hello Ada!"}

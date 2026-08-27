import json
import logging
import os
import uuid
from datetime import datetime

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.client("dynamodb")
TABLE_NAME = os.getenv("TABLE_NAME", "shopping_list")


def lambda_handler(event, context):
    try:
        body = event.get("body")
        if body and isinstance(body, str):
            body = json.loads(body)
        elif not body:
            body = {}

        name = body.get("name")
        email = body.get("email")
        phone = body.get("phone")
        course = body.get("course")

        if not all(isinstance(value, str) and value.strip() for value in (name, email, phone, course)):
            return error_response(400, "'name', 'email', 'phone' e 'course' são obrigatórios.")

        lead_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat() + "Z"

        item = {
            "PK": {"S": "leads"},
            "SK": {"S": f"lead#{lead_id}"},
            "name": {"S": name},
            "email": {"S": email},
            "phone": {"S": phone},
            "course": {"S": course},
            "createdAt": {"S": created_at},
        }

        dynamodb.put_item(TableName=TABLE_NAME, Item=item)

        response = {"success": True, "message": "Lead recebido com sucesso.", "lead": simplify_item(item)}

        return lambda_response(201, response)

    except Exception as e:
        logger.error(f"Erro ao salvar item: {str(e)}")
        return error_response(500, "Erro interno ao salvar item.")


def simplify_item(item):
    """Converte valores do DynamoDB para um dicionário simples Python."""
    return {k: list(v.values())[0] for k, v in item.items()}


def error_response(status_code, message):
    body = {"success": False, "message": message}

    return lambda_response(status_code, body)


def lambda_response(status_code, body_dict):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST",
        },
        "body": json.dumps(body_dict),
    }

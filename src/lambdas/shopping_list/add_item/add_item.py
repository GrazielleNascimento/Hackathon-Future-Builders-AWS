import json
import logging
import os
import uuid
from datetime import datetime

import boto3

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sqs = boto3.client("sqs")
dynamodb = boto3.client("dynamodb")
TABLE_NAME = os.getenv("TABLE_NAME", "shopping_list")
QUEUE_URL = os.getenv("QUEUE_URL")


def lambda_handler(event, context):
    try:
        if event.get("Records"):
            for record in event["Records"]:
                lead = json.loads(record["body"])
                save_lead(lead)
                logger.info("Lead processado com sucesso: %s", lead["leadId"])
            return {"batchItemFailures": []}

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

        if not QUEUE_URL:
            raise RuntimeError("QUEUE_URL não configurada")

        lead = {
            "leadId": str(uuid.uuid4()),
            "name": name,
            "email": email,
            "phone": phone,
            "course": course,
            "createdAt": datetime.utcnow().isoformat() + "Z",
        }
        sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=json.dumps(lead))
        logger.info("Lead enfileirado com sucesso: %s", lead["leadId"])

        response = {"success": True, "message": "Lead recebido e enfileirado com sucesso.", "lead": lead}

        return lambda_response(201, response)

    except Exception as e:
        logger.error(f"Erro ao salvar item: {str(e)}")
        if event.get("Records"):
            raise
        return error_response(500, "Erro interno ao salvar item.")


def save_lead(lead):
    item = {
        "PK": {"S": "leads"},
        "SK": {"S": f"lead#{lead['leadId']}"},
        "name": {"S": lead["name"]},
        "email": {"S": lead["email"]},
        "phone": {"S": lead["phone"]},
        "course": {"S": lead["course"]},
        "createdAt": {"S": lead["createdAt"]},
    }
    dynamodb.put_item(TableName=TABLE_NAME, Item=item)


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

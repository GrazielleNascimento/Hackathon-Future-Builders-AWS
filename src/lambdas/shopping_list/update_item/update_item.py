import boto3
import os
import logging
from datetime import datetime

logger = logging.getLogger()

dynamodb = boto3.client('dynamodb')
TABLE_NAME = os.getenv("TABLE_NAME", "shopping_list")


def lambda_handler(event, context):
    try:
        item_id = event.get("itemId")
        data_atual = event.get("dataAtual")
        novo_nome = event.get("novoNome")
        nova_data = event.get("novaData")
        novo_status = event.get("novoStatus")

        if not item_id or not data_atual:
            return error_response(400, "'itemId' e 'dataAtual' são obrigatórios.")

        pk_atual = f"list#{data_atual}"
        sk = f"item#{item_id}"
        item = get_item(pk_atual, sk)

        if not item:
            return error_response(404, "Item não encontrado.")

        pk_nova = f"list#{nova_data}" if nova_data else pk_atual

        if pk_nova == pk_atual:
            updated_item = update_fields(pk_atual, sk, novo_nome, novo_status)
            return {"success": True, "item": simplify_item(updated_item)}
        else:
            copy_item(item, pk_nova, novo_nome, novo_status)
            delete_item(pk_atual, sk)
            item["PK"]["S"] = pk_nova
            if novo_nome:
                item["name"]["S"] = novo_nome
            if novo_status:
                item["status"]["S"] = novo_status
            return {"success": True, "item": simplify_item(item)}

    except Exception as e:
        logger.error(f"Erro: {e}")
        return error_response(500, "Erro interno.")


def get_item(pk, sk):
    response = dynamodb.get_item(TableName=TABLE_NAME, Key={"PK": {"S": pk}, "SK": {"S": sk}})
    return response.get("Item")


def update_fields(pk, sk, name, status):
    exprs = []
    values = {}
    attr_names = {}

    if name:
        exprs.append("#n = :n")
        values[":n"] = {"S": name}
        attr_names["#n"] = "name"
    if status:
        exprs.append("#s = :s")
        values[":s"] = {"S": status}
        attr_names["#s"] = "status"

    if not exprs:
        return get_item(pk, sk)

    response = dynamodb.update_item(
        TableName=TABLE_NAME,
        Key={"PK": {"S": pk}, "SK": {"S": sk}},
        UpdateExpression="SET " + ", ".join(exprs),
        ExpressionAttributeValues=values,
        ExpressionAttributeNames=attr_names,
        ReturnValues="ALL_NEW"
    )
    return response["Attributes"]


def copy_item(item, new_pk, name=None, status=None):
    item["PK"]["S"] = new_pk
    if name:
        item["name"] = {"S": name}
    if status:
        item["status"] = {"S": status}
    dynamodb.put_item(TableName=TABLE_NAME, Item=item)


def delete_item(pk, sk):
    dynamodb.delete_item(TableName=TABLE_NAME, Key={"PK": {"S": pk}, "SK": {"S": sk}})


def simplify_item(item):
    return {k: list(v.values())[0] for k, v in item.items()}


def error_response(code, msg):
    return {"success": False, "statusCode": code, "message": msg}

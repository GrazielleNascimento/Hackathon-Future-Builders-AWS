import boto3
import os

dynamodb = boto3.client("dynamodb")
TABLE_NAME = os.getenv("TABLE_NAME", "shopping_list")


def lambda_handler(event, context):
    try:
        item_id = event.get("itemId")
        pk = event.get("pk")

        if not item_id or not pk:
            return error_response(400, "Campos obrigatórios 'itemId' e 'pk' são necessários.")

        pk_formatado = f"list#{pk}"
        sk = f"item#{item_id}"

        key = {
            "PK": {"S": pk_formatado},
            "SK": {"S": sk}
        }

        # Verifica se o item existe
        result = dynamodb.get_item(TableName=TABLE_NAME, Key=key)
        existing_item = result.get("Item")

        if not existing_item:
            return {
                "success": True,
                "message": "Item já não existe ou foi removido anteriormente."
            }

        # Remove o item
        dynamodb.delete_item(TableName=TABLE_NAME, Key=key)

        return {
            "success": True,
            "message": "Item excluído com sucesso."
        }

    except Exception as e:
        if context:
            context.logger.log(f"Erro ao excluir item: {str(e)}")
        return error_response(500, "Erro interno ao tentar excluir o item.")


def error_response(status_code, message):
    return {
        "success": False,
        "statusCode": status_code,
        "message": message
    }

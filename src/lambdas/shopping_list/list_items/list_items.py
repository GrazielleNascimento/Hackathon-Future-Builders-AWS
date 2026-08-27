import boto3
import os
import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.client('dynamodb')
TABLE_NAME = os.getenv("TABLE_NAME", "shopping_list")

def lambda_handler(event, context):
    """
    Lista itens de uma data específica ou todas as datas se não especificado.
    Parâmetros opcionais: date (formato YYYY-MM-DD)
    """
    try:
        date = event.get("date")
        
        # Verifica se 'date' está presente no evento (incluindo string vazia)
        if "date" in event:
            # Lista itens de uma data específica (inclui validação para string vazia)
            items = list_items_by_date(date)
        else:
            # Lista todos os itens (quando 'date' não está presente)
            items = list_all_items()
        
        response = {
            "success": True,
            "items": items,
            "count": len(items)
        }
        
        return {
            "statusCode": 200,
            "body": json.dumps(response)
        }
        
    except ValueError as ve:
        logger.warning(f"Parâmetro inválido: {str(ve)}")
        return error_response(400, str(ve))
    except Exception as e:
        logger.error(f"Erro ao listar itens: {str(e)}")
        return error_response(500, "Erro interno ao listar itens.")

def list_items_by_date(date):
    """Lista itens de uma data específica."""
    validate_date_format(date)
    
    pk = f"list#{date.replace('-', '')}"
    
    response = dynamodb.query(
        TableName=TABLE_NAME,
        KeyConditionExpression="PK = :pk",
        ExpressionAttributeValues={
            ":pk": {"S": pk}
        }
    )
    
    return [simplify_item(item) for item in response.get("Items", [])]

def list_all_items():
    """Lista todos os itens da tabela."""
    response = dynamodb.scan(
        TableName=TABLE_NAME,
        FilterExpression="begins_with(PK, :prefix)",
        ExpressionAttributeValues={
            ":prefix": {"S": "list#"}
        }
    )
    
    items = [simplify_item(item) for item in response.get("Items", [])]
    
    # Ordena por data de criação (mais recente primeiro)
    return sorted(items, key=lambda x: x.get("createdAt", ""), reverse=True)

def validate_date_format(date):
    """Valida se a data está no formato correto YYYY-MM-DD."""
    if not date:
        raise ValueError("Data é obrigatória.")
    
    try:
        datetime.strptime(date, "%Y-%m-%d")
    except ValueError:
        raise ValueError("Formato de data inválido. Use YYYY-MM-DD.")

def simplify_item(item):
    """Converte valores do DynamoDB para um dicionário simples Python."""
    return {k: list(v.values())[0] for k, v in item.items()}

def error_response(status_code, message):
    """Retorna resposta de erro padronizada."""
    return {
        "statusCode": status_code,
        "body": json.dumps({
            "success": False,
            "message": message
        })
    }
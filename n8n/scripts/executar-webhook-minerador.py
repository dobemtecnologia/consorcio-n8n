#!/usr/bin/env python3
"""
Script para executar webhook minerador para múltiplos grupos
Uso: python executar-webhook-minerador.py [arquivo-grupos]
"""

import sys
import json
import time
import requests
from pathlib import Path

# Caminho padrão do arquivo de grupos
SCRIPT_DIR = Path(__file__).parent
DEFAULT_GRUPOS_FILE = SCRIPT_DIR.parent.parent / "grupos.txt"

# URL do webhook
WEBHOOK_URL = "https://maestro.consorcio.dobemtech.com/webhook/minerador"

def ler_grupos(arquivo):
    """Lê os grupos do arquivo, removendo linhas vazias e espaços."""
    grupos = []
    with open(arquivo, 'r', encoding='utf-8') as f:
        for linha in f:
            grupo = linha.strip()
            if grupo:  # Ignora linhas vazias
                grupos.append(grupo)
    return grupos

def executar_webhook(grupo):
    """Executa o webhook para um grupo específico."""
    payload = {
        "cdGrupo": f"'{grupo}'"
    }
    
    headers = {
        'Content-Type': 'application/json'
    }
    
    try:
        response = requests.post(
            WEBHOOK_URL,
            json=payload,
            headers=headers,
            timeout=30
        )
        return response.status_code, response.text
    except requests.exceptions.RequestException as e:
        return None, str(e)

def main():
    # Determinar arquivo de grupos
    if len(sys.argv) > 1:
        grupos_file = Path(sys.argv[1])
    else:
        grupos_file = DEFAULT_GRUPOS_FILE
    
    # Verificar se o arquivo existe
    if not grupos_file.exists():
        print(f"Erro: Arquivo de grupos não encontrado: {grupos_file}")
        sys.exit(1)
    
    # Ler grupos
    grupos = ler_grupos(grupos_file)
    
    if not grupos:
        print("Nenhum grupo encontrado no arquivo.")
        sys.exit(1)
    
    # Estatísticas
    total = len(grupos)
    sucesso = 0
    erro = 0
    
    print("=" * 50)
    print("Executando webhook minerador para grupos")
    print(f"Arquivo: {grupos_file}")
    print("=" * 50)
    print()
    
    # Processar cada grupo
    for idx, grupo in enumerate(grupos, 1):
        print(f"[{idx}/{total}] Processando grupo: {grupo}")
        
        status_code, resposta = executar_webhook(grupo)
        
        if status_code and 200 <= status_code < 300:
            print(f"  ✓ Sucesso (HTTP {status_code})")
            sucesso += 1
        else:
            print(f"  ✗ Erro (HTTP {status_code if status_code else 'N/A'})")
            if resposta:
                print(f"  Resposta: {resposta[:200]}")  # Limita tamanho da resposta
            erro += 1
        
        print()
        
        # Pequeno delay para não sobrecarregar o servidor
        time.sleep(0.5)
    
    # Resumo final
    print("=" * 50)
    print("Resumo da execução:")
    print(f"  Total processado: {total}")
    print(f"  Sucesso: {sucesso}")
    print(f"  Erro: {erro}")
    print("=" * 50)

if __name__ == "__main__":
    main()


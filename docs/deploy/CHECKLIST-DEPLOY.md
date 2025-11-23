# ✅ Checklist de Deploy

Use este checklist para garantir que tudo está configurado antes do deploy.

## Antes de Fazer o Push

### 1. ☐ Aplicar Mudanças do Terraform

```bash
cd infra
terraform plan   # Revisar mudanças
terraform apply  # Aplicar
cd ..
```

**O que será alterado:**

- Target Group health check: path, timeout, intervalo, retries

---

### 2. ☐ Configurar Secret (escolha UMA opção)

#### Opção A: GitHub Secret (Recomendado para começar) ⭐

1. Acesse: https://github.com/[seu-usuario]/minerador-cotas-contemplada/settings/secrets/actions
2. Clique em "New repository secret"
3. Nome: `DB_PASSWORD`
4. Valor: `jEdRpcDBzq`
5. Salvar

#### Opção B: AWS Secrets Manager (Mais seguro para produção)

```bash
./setup-secrets.sh
```

Ou manualmente via AWS CLI (veja `CONFIGURAR-SECRETS.md`)

---

### 3. ☐ Fazer Commit e Push

```bash
git add .
git commit -m "fix: remover senha hardcoded e corrigir deploy ECS"
git push origin main
```

---

## Durante o Deploy

### 4. ☐ Monitorar GitHub Actions

Acesse: https://github.com/[seu-usuario]/minerador-cotas-contemplada/actions

**Verifique se você vê:**

- ✅ Build da imagem concluído
- ✅ Credenciais configuradas (com senha mascarada)
- ✅ Task definition registrada
- ✅ Deploy iniciado

**Tempo esperado:** 10-20 minutos

---

### 5. ☐ Verificar Logs (se necessário)

Se algo der errado, acesse:

**CloudWatch Logs:**
https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/$252Fecs$252Fminerador-cotas

**ECS Service:**
https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/minerador-cotas-cluster/services/minerador-cotas-service

---

## Após o Deploy

### 6. ☐ Testar a Aplicação

```bash
# Testar health check
curl https://minerador.dobemtecnologia.com/management/health/readiness

# Deve retornar status UP
```

### 7. ☐ Verificar na Interface

Abra no navegador:

- https://minerador.dobemtecnologia.com/

Faça login e teste as funcionalidades principais.

---

## 🚨 Se Algo Der Errado

### Deploy falhou no step "Get database credentials"

→ Secret não configurado no GitHub  
→ Vá para o passo 2 deste checklist

### Deploy falhou no step "Wait for deployment to complete"

→ Verifique logs no CloudWatch  
→ Problema pode ser: conectividade com banco, memória insuficiente, erro na aplicação

### Aplicação iniciou mas health check falha

→ Problema de conectividade com o banco  
→ Verifique Security Groups e credenciais

### Erro "no password was provided"

→ Secret não está sendo passado corretamente  
→ Execute deploy novamente após configurar o secret

---

## 📚 Documentação Adicional

- **`RESUMO-CORRECOES.md`** - Visão geral de todas as correções
- **`DEPLOY-FIX.md`** - Detalhes sobre health check e timeout
- **`CONFIGURAR-SECRETS.md`** - Guia completo de configuração de secrets
- **`setup-secrets.sh`** - Script automatizado para AWS Secrets Manager

---

## ⚡ Atalho Rápido

```bash
# 1. Terraform
cd infra && terraform apply -auto-approve && cd ..

# 2. Configurar secret no GitHub manualmente
# (ou executar: ./setup-secrets.sh)

# 3. Deploy
git add . && \
git commit -m "fix: remover senha hardcoded e corrigir deploy ECS" && \
git push origin main

# 4. Monitorar
echo "Acompanhe em: https://github.com/[seu-usuario]/minerador-cotas-contemplada/actions"
```

---

## 🎯 Resultado Esperado

Ao final, você deve ver:

✅ **No GitHub Actions:**

```
✅ Deploy concluído com sucesso!
```

✅ **No navegador:**

- Aplicação acessível em https://minerador.dobemtecnologia.com/
- Login funcionando
- Funcionalidades operacionais

✅ **No CloudWatch:**

- Logs mostrando "Started MieradorcotascontempladaApp"
- Sem erros de conexão com banco

---

**Boa sorte! 🚀**

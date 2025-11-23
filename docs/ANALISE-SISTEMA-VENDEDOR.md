# 📋 ANÁLISE COMPLETA - Sistema de Vendedores v3.0

## 🎯 RESUMO EXECUTIVO

Sistema com **3 perfis de acesso** (ROLE_ADMIN, ROLE_VENDEDOR, ROLE_USER) para controle de cadastro de Pessoas Físicas e Jurídicas.

---

## 👥 PERFIS E PERMISSÕES

### 1. ROLE_ADMIN

- ✅ Acesso completo ao sistema
- ✅ Menu "Entidades" completo (todas as entidades)
- ✅ Menu "Administração" (gerenciar usuários, vendedores, métricas)
- ✅ Visualiza TODOS os cadastros (sem filtro)
- ✅ Pode criar/editar/excluir qualquer registro

### 2. ROLE_VENDEDOR

- ✅ Menu "Cadastros" (dropdown):
  - Nova Pessoa Física
  - Minhas Pessoas Físicas (listagem filtrada)
  - Nova Pessoa Jurídica
  - Minhas Pessoas Jurídicas (listagem filtrada)
- ✅ Cadastra Pessoa Física → vincula automaticamente ao vendedor
- ✅ Cadastra Pessoa Jurídica → vincula automaticamente ao vendedor
- ✅ Visualiza APENAS cadastros que ELE fez (filtro automático por vendedor_id)
- ✅ Pode editar APENAS cadastros que ELE fez
- ❌ NÃO vê menu "Entidades"
- ❌ NÃO vê menu "Administração"
- ❌ NÃO vê cadastros de outros vendedores

### 3. ROLE_USER (Futuro)

- ✅ Menu "Meus Dados" (link direto para editar seus dados)
- ✅ Autocadastro (PF ou PJ)
- ✅ Edita APENAS seus próprios dados
- ❌ NÃO vê menu "Entidades"
- ❌ NÃO vê menu "Cadastros"
- ❌ NÃO vê lista de outras pessoas

---

## 🏗️ ESTRUTURA DE ENTIDADES

### Diagrama de Relacionamento

```
┌─────────────────┐
│   JHI_USER      │
│  - id (PK)      │
│  - login        │
│  - password     │
│  - authorities  │ ← ROLE_ADMIN / ROLE_VENDEDOR / ROLE_USER
└─────┬───────────┘
      │
      │ OneToOne (required)
      │
┌─────▼──────────┐
│   VENDEDOR     │
│  - id (PK)     │
│  - cpf (UQ)    │
│  - nome        │
│  - rg          │
│  - telefone    │
│  - email       │
│  - user_id(FK) │
│  - ativo       │
└─────┬──────────┘
      │
      │ OneToMany
      │
      ├─────────────────────┬─────────────────────┐
      │                     │                     │
┌─────▼─────────┐    ┌─────▼─────────┐    ┌─────▼─────────┐
│ PESSOA_FISICA │    │PESSOA_JURIDICA│    │               │
│ - cpf (PK)    │    │ - cnpj (PK)   │    │  Outras PF/PJ │
│ - nome        │    │ - razao       │    │  cadastradas  │
│ - vendedor_id │◄───┤ - vendedor_id │◄───┤  pelo vendedor│
│ - user_id     │    │ - user_id     │    │               │
│   (nullable)  │    │   (nullable)  │    │               │
└───────────────┘    └───────────────┘    └───────────────┘
       │                     │
       │ (autocadastro)      │ (autocadastro)
       │                     │
       └──────┬──────────────┘
              │
              │ ManyToOne (nullable)
              │
     ┌────────▼────────┐
     │   JHI_USER      │
     │ (ROLE_USER)     │
     │ para autocad.   │
     └─────────────────┘
```

### Campos da Entidade Vendedor

```java
entity Vendedor {
  id: Long (PK, auto)
  cpf: String(14) unique required
  nomeCompleto: String(120) required
  rg: String(20)
  orgaoExpedidor: String(20)
  dataNascimento: LocalDate
  telefone: String(15)
  celular: String(15)
  email: String(100)
  ativo: Boolean
  dataAdmissao: LocalDate
  observacoes: String(500)
  user_id: Long (FK → jhi_user) required unique
}
```

### Campos Adicionados em PessoaFisica

```java
// NOVO
vendedor_id: Long (FK → vendedor) nullable
user_id: Long (FK → jhi_user) nullable
```

**Regras:**

- Se cadastrado por **VENDEDOR**: `vendedor_id` preenchido, `user_id` null ou preenchido
- Se **AUTOCADASTRO** (ROLE_USER): `user_id` preenchido, `vendedor_id` null

### Campos Adicionados em PessoaJuridica

```java
// NOVO
vendedor_id: Long (FK → vendedor) nullable
user_id: Long (FK → jhi_user) nullable
```

**Mesmas regras de PessoaFisica**

---

## 🔐 CONTROLE DE ACESSO - BACKEND

### Fluxo de Cadastro (POST /api/pessoa-fisicas)

```
1. Request chega no PessoaFisicaResource.createPessoaFisica()
   ↓
2. Verificar role do usuário logado (SecurityUtils)
   ↓
3. Se ROLE_VENDEDOR:
   - Buscar Vendedor vinculado ao login do usuário
   - Setar vendedorId no DTO automaticamente
   ↓
4. Se ROLE_USER (futuro):
   - Setar userId no DTO automaticamente
   ↓
5. Se ROLE_ADMIN:
   - Não aplica filtro, pode setar manualmente
   ↓
6. Salvar PessoaFisica com os relacionamentos
```

### Fluxo de Listagem (GET /api/pessoa-fisicas)

```
1. Request chega no PessoaFisicaResource.getAllPessoaFisicas()
   ↓
2. Verificar role do usuário logado
   ↓
3. Se ROLE_ADMIN:
   - Retornar TODOS os cadastros (sem filtro)
   ↓
4. Se ROLE_VENDEDOR:
   - Buscar Vendedor vinculado ao login
   - Aplicar filtro: WHERE vendedor_id = :vendedorId
   - Retornar apenas cadastros deste vendedor
   ↓
5. Se ROLE_USER (futuro):
   - Buscar User logado
   - Aplicar filtro: WHERE user_id = :userId
   - Retornar apenas cadastro dele mesmo
```

### Fluxo de Edição (PUT /api/pessoa-fisicas/:cpf)

```
1. Request chega no PessoaFisicaResource.updatePessoaFisica()
   ↓
2. Buscar PessoaFisica existente
   ↓
3. Verificar role do usuário logado
   ↓
4. Se ROLE_ADMIN:
   - Permitir edição (sem validação)
   ↓
5. Se ROLE_VENDEDOR:
   - Buscar Vendedor vinculado ao login
   - Validar: existing.vendedor_id == vendedor.id
   - Se NÃO: throw AccessDeniedException
   - Se SIM: permitir edição
   ↓
6. Se ROLE_USER (futuro):
   - Validar: existing.user_id == user.id
   - Se NÃO: throw AccessDeniedException
   - Se SIM: permitir edição
   ↓
7. Salvar alterações
```

---

## 🎨 CONTROLE DE ACESSO - FRONTEND

### Navbar - Estrutura de Menus

```html
┌──────────────────────────────────────────────────┐ │ Home | Cadastros ▼ | Entidades ▼ | Admin ▼ | Conta ▼ │
└──────────────────────────────────────────────────┘ ↑ ↑ ↑ │ │ │ VENDEDOR ADMIN ADMIN
```

### Menu por Perfil

| Menu                        | ADMIN | VENDEDOR | USER |
| --------------------------- | ----- | -------- | ---- |
| Home                        | ✅    | ✅       | ✅   |
| Cadastros (dropdown)        | ❌    | ✅       | ❌   |
| └─ Nova Pessoa Física       | ❌    | ✅       | ❌   |
| └─ Minhas Pessoas Físicas   | ❌    | ✅       | ❌   |
| └─ Nova Pessoa Jurídica     | ❌    | ✅       | ❌   |
| └─ Minhas Pessoas Jurídicas | ❌    | ✅       | ❌   |
| Meus Dados                  | ❌    | ❌       | ✅   |
| Entidades (dropdown)        | ✅    | ❌       | ❌   |
| Administração (dropdown)    | ✅    | ❌       | ❌   |
| Conta (dropdown)            | ✅    | ✅       | ✅   |

---

## 📂 ARQUIVOS MODIFICADOS/CRIADOS

### ✅ Já Criados (via JDL)

**Arquivo JDL:**

```
✅ projeto/diagrama.jdl (atualizado com entidade Vendedor e relacionamentos)
```

### 🔨 A Serem Criados Manualmente

**Backend:**

```
1. src/main/resources/config/liquibase/changelog/20251017100000_add_role_vendedor.xml
2. Atualizar: src/main/resources/config/liquibase/master.xml
3. Atualizar: src/main/java/com/dobemtecnologia/security/AuthoritiesConstants.java
4. Atualizar: src/main/java/com/dobemtecnologia/repository/VendedorRepository.java
5. Atualizar: src/main/java/com/dobemtecnologia/web/rest/PessoaFisicaResource.java
6. Atualizar: src/main/java/com/dobemtecnologia/web/rest/PessoaJuridicaResource.java
```

**Frontend:**

```
7. Atualizar: src/main/webapp/app/config/authority.constants.ts
8. Atualizar: src/main/webapp/app/layouts/navbar/navbar.component.html
```

**Documentação:**

```
9. ✅ docs/IMPLEMENTACAO-VENDEDOR.md (guia passo a passo)
10. ✅ docs/ANALISE-SISTEMA-VENDEDOR.md (este arquivo)
```

---

## 🚀 ORDEM DE EXECUÇÃO

### Passo 1: Gerar Código com JHipster

```bash
# Gera toda a estrutura da entidade Vendedor
# e atualiza PessoaFisica e PessoaJuridica
jhipster import-jdl projeto/diagrama.jdl --force
```

### Passo 2: Adicionar Role ROLE_VENDEDOR

- Criar migration Liquibase
- Atualizar constantes backend e frontend

### Passo 3: Implementar Lógica de Filtros

- Adicionar método no VendedorRepository
- Modificar PessoaFisicaResource (create, list, update)
- Modificar PessoaJuridicaResource (create, list, update)

### Passo 4: Atualizar Frontend

- Modificar navbar.component.html
- Adicionar controle de acesso aos menus

### Passo 5: Testar

- Compilar e executar
- Criar usuários de teste
- Validar fluxos

---

## ❓ QUESTÕES PENDENTES

### 1. Campos da Entidade Vendedor

Os campos atuais são suficientes?

```
✅ cpf
✅ nomeCompleto
✅ rg
✅ orgaoExpedidor
✅ dataNascimento
✅ telefone
✅ celular
✅ email
✅ ativo
✅ dataAdmissao
✅ observacoes
```

❓ Adicionar outros campos?

- [ ] Endereço completo?
- [ ] Dados bancários?
- [ ] Percentual de comissão?
- [ ] Foto/Avatar?

### 2. Autocadastro ROLE_USER

❓ Qual fluxo de autocadastro?

- [ ] **Opção A:** Duas etapas (criar login → preencher dados)
- [ ] **Opção B:** Tudo numa tela só
- [ ] **Opção C:** Vendedor cria o User

❓ ROLE_USER pode autocadastrar como:

- [ ] Apenas Pessoa Física
- [ ] Apenas Pessoa Jurídica
- [ ] Ambos (escolhe no cadastro)

### 3. Exclusão de Cadastros

❓ Vendedor pode excluir cadastros que fez?

- [ ] Sim, pode excluir (DELETE)
- [ ] Não, apenas admin pode excluir
- [ ] Marcar como inativo ao invés de excluir

### 4. Formulário Pessoa Jurídica

❓ Aguardando imagem do formulário para:

- [ ] Analisar campos necessários
- [ ] Verificar se entity atual é suficiente
- [ ] Criar/ajustar frontend

---

## ⏱️ ESTIMATIVA DE TEMPO

| Fase               | Descrição                      | Tempo      | Status               |
| ------------------ | ------------------------------ | ---------- | -------------------- |
| 1                  | Executar `jhipster import-jdl` | 5-10 min   | ⏳ Pendente          |
| 2                  | Adicionar ROLE_VENDEDOR        | 30 min     | ⏳ Pendente          |
| 3                  | Implementar filtros backend    | 3-4h       | ⏳ Pendente          |
| 4                  | Atualizar navbar frontend      | 1-2h       | ⏳ Pendente          |
| 5                  | Testes e ajustes               | 2-3h       | ⏳ Pendente          |
| **TOTAL BASE**     | **Sem autocadastro e form PJ** | **7-10h**  |                      |
| 6                  | Autocadastro ROLE_USER         | 4-5h       | 📅 Futuro            |
| 7                  | Formulário Pessoa Jurídica     | 4-6h       | 📅 Aguardando imagem |
| **TOTAL COMPLETO** |                                | **15-21h** |                      |

---

## ✅ PRÓXIMOS PASSOS - AGUARDANDO APROVAÇÃO

1. ✅ **Você confirma a estrutura proposta?**
2. ✅ **Posso executar `jhipster import-jdl` agora?**
3. ❓ **Responder questões pendentes (seção acima)**
4. ❓ **Enviar imagem do formulário Pessoa Jurídica**

---

**Documento criado em:** 17/10/2025
**Última atualização:** 17/10/2025  
**Status:** ⏳ Aguardando aprovação para iniciar implementação

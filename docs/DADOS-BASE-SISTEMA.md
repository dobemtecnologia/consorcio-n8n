# Dados Base do Sistema

Este documento lista os dados pré-carregados no sistema através do Liquibase.

## Estados Civis

Os estados civis são carregados automaticamente na inicialização do sistema.

### Tabela: `estado_civil`

| ID  | Descrição                 | Uso Comum                              |
| --- | ------------------------- | -------------------------------------- |
| 1   | Solteiro(a)               | Pessoa sem vínculo conjugal            |
| 2   | Casado(a)                 | Pessoa casada oficialmente             |
| 3   | Divorciado(a)             | Pessoa que teve o casamento dissolvido |
| 4   | Viúvo(a)                  | Pessoa cujo cônjuge faleceu            |
| 5   | União Estável             | Pessoa em união estável reconhecida    |
| 6   | Separado(a) Judicialmente | Pessoa legalmente separada             |

### Script SQL

Os dados são inseridos através de:

- **Migration Liquibase:** `20251021055500_load_data_estado_civil.xml`
- **Arquivo CSV:** `src/main/resources/config/liquibase/data/estado_civil.csv`
- **Script SQL manual:** `projeto/sql/6 - estados-civis.sql`

### Inserção Manual (SQL)

Se precisar inserir manualmente no banco:

```sql
INSERT INTO estado_civil (id_estado_civil, descricao) VALUES
(1, 'Solteiro(a)'),
(2, 'Casado(a)'),
(3, 'Divorciado(a)'),
(4, 'Viúvo(a)'),
(5, 'União Estável'),
(6, 'Separado(a) Judicialmente');
```

### Consulta

Para verificar os estados civis cadastrados:

```sql
SELECT * FROM estado_civil ORDER BY id_estado_civil;
```

## Como os Dados são Carregados

Os dados são carregados automaticamente pelo Liquibase quando a aplicação inicia pela primeira vez:

1. **Verificação de Pré-condição:** O Liquibase verifica se a tabela está vazia
2. **Carga de Dados:** Se estiver vazia, carrega os dados do arquivo CSV
3. **Validação:** Se a tabela já tiver dados, a migration é marcada como executada

### Ordem de Execução

1. `20251017061604_added_entity_EstadoCivil.xml` - Cria a tabela
2. `20251021055500_load_data_estado_civil.xml` - Carrega os dados

## Uso na API

### Endpoint de Cadastro

Ao cadastrar uma pessoa física, você deve informar o `estadoCivilId`:

```json
{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva",
  "dataNascimento": "1990-05-15",
  "sexo": "M",
  "estadoCivilId": 2
}
```

### Validação

- O campo `estadoCivilId` é **obrigatório**
- Se informar um ID que não existe, receberá o erro:
  ```
  "Estado Civil informado não existe no sistema"
  ```

## Dados do Cônjuge

Se o `estadoCivilId` for 2 (Casado) ou 5 (União Estável), é recomendado informar também:

- `cpfConjuge`
- `nomeCompletoConjuge`
- `sexoConjuge`
- `rgConjuge` (opcional)

Exemplo:

```json
{
  "cpf": "123.456.789-00",
  "nomeCompleto": "João da Silva",
  "estadoCivilId": 2,
  "cpfConjuge": "987.654.321-00",
  "nomeCompletoConjuge": "Maria da Silva",
  "sexoConjuge": "F"
}
```

## Outros Dados Base

### Profissões

A tabela `profissao` deve ser preenchida conforme necessidade do negócio.

### Bancos

A tabela `banco` pode ser preenchida com o script:

```
projeto/sql/5 - bancos.sql
```

### Estados e Cidades

As tabelas de localização podem ser preenchidas com:

- `projeto/sql/1 - estados.sql`
- `projeto/sql/2 - cidades.sql`
- Ou scripts específicos por estado

### Nacionalidades

A tabela `nacionalidade` pode ser preenchida com:

```
projeto/sql/3 - nacionalidades.sql
```

## Manutenção

### Adicionar Novo Estado Civil

Se precisar adicionar um novo estado civil:

1. Crie uma nova migration Liquibase:

   ```xml
   <changeSet id="YYYYMMDDHHMMSS-add-estado-civil-novo" author="seu-nome">
       <insert tableName="estado_civil">
           <column name="id_estado_civil" valueNumeric="7"/>
           <column name="descricao" value="Novo Estado Civil"/>
       </insert>
   </changeSet>
   ```

2. Ou execute diretamente no banco:
   ```sql
   INSERT INTO estado_civil (id_estado_civil, descricao)
   VALUES (7, 'Novo Estado Civil');
   ```

### Atualizar Descrição

Para atualizar a descrição de um estado civil:

```sql
UPDATE estado_civil
SET descricao = 'Nova Descrição'
WHERE id_estado_civil = 1;
```

## Troubleshooting

### Tabela Vazia Após Inicialização

Se a tabela `estado_civil` estiver vazia após iniciar a aplicação:

1. Verifique os logs do Liquibase
2. Execute manualmente o script: `projeto/sql/6 - estados-civis.sql`
3. Ou reinicie a aplicação com: `./mvnw clean spring-boot:run`

### Erro ao Cadastrar Pessoa Física

Se receber erro sobre estado civil não encontrado:

```sql
-- Verificar se os dados foram carregados
SELECT COUNT(*) FROM estado_civil;

-- Se retornar 0, carregar manualmente
\i projeto/sql/6 - estados-civis.sql
```

### Resetar Dados

Para resetar os dados de estado civil:

```sql
DELETE FROM estado_civil;
ALTER SEQUENCE estado_civil_id_seq RESTART WITH 1;

-- Depois execute o script novamente
\i projeto/sql/6 - estados-civis.sql
```

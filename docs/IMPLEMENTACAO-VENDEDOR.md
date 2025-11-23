# 🚀 Guia de Implementação - Sistema de Vendedores

## 📋 Visão Geral

Este guia detalha os passos para implementar o sistema de vendedores com controle de acesso baseado em 3 roles:

- **ROLE_ADMIN**: Acesso total ao sistema
- **ROLE_VENDEDOR**: Cadastra e gerencia pessoas físicas/jurídicas
- **ROLE_USER**: Autocadastro e edição dos próprios dados

---

## ⚙️ FASE 1: Gerar Entidades com JHipster JDL

### 1.1 Executar Import do JDL

```bash
# No diretório raiz do projeto
jhipster import-jdl projeto/diagrama.jdl --force
```

**⚠️ ATENÇÃO:**

- O flag `--force` sobrescreverá arquivos existentes
- Faça backup ou commit antes de executar
- Revise as mudanças geradas antes de fazer commit

### 1.2 O que será gerado automaticamente:

**Backend:**

```
✅ src/main/java/com/dobemtecnologia/domain/Vendedor.java
✅ src/main/java/com/dobemtecnologia/repository/VendedorRepository.java
✅ src/main/java/com/dobemtecnologia/service/VendedorService.java
✅ src/main/java/com/dobemtecnologia/service/impl/VendedorServiceImpl.java
✅ src/main/java/com/dobemtecnologia/service/dto/VendedorDTO.java
✅ src/main/java/com/dobemtecnologia/service/mapper/VendedorMapper.java
✅ src/main/java/com/dobemtecnologia/web/rest/VendedorResource.java
✅ src/main/java/com/dobemtecnologia/service/criteria/VendedorCriteria.java
✅ src/main/java/com/dobemtecnologia/service/VendedorQueryService.java
✅ src/main/resources/config/liquibase/changelog/YYYYMMDDHHMMSS_added_entity_Vendedor.xml
✅ Atualização em PessoaFisica (adiciona FK vendedor_id e user_id)
✅ Atualização em PessoaJuridica (adiciona FK vendedor_id e user_id)
```

**Frontend:**

```
✅ src/main/webapp/app/entities/vendedor/ (estrutura completa)
✅ Atualização em pessoa-fisica.model.ts
✅ Atualização em pessoa-juridica.model.ts
```

---

## ⚙️ FASE 2: Adicionar Role ROLE_VENDEDOR

### 2.1 Criar Migration Liquibase

Criar arquivo: `src/main/resources/config/liquibase/changelog/20251017100000_add_role_vendedor.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<databaseChangeLog
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-latest.xsd">

    <changeSet id="20251017100000-1" author="elton">
        <insert tableName="jhi_authority">
            <column name="name" value="ROLE_VENDEDOR"/>
        </insert>
    </changeSet>

</databaseChangeLog>
```

### 2.2 Adicionar no master.xml

Editar: `src/main/resources/config/liquibase/master.xml`

Adicionar antes do último `</databaseChangeLog>`:

```xml
<include file="config/liquibase/changelog/20251017100000_add_role_vendedor.xml" relativeToChangelogFile="false"/>
```

### 2.3 Atualizar Constantes Backend

Editar: `src/main/java/com/dobemtecnologia/security/AuthoritiesConstants.java`

```java
public final class AuthoritiesConstants {

  public static final String ADMIN = "ROLE_ADMIN";
  public static final String USER = "ROLE_USER";
  public static final String VENDEDOR = "ROLE_VENDEDOR"; // ← ADICIONAR
  public static final String ANONYMOUS = "ROLE_ANONYMOUS";

  private AuthoritiesConstants() {}
}

```

### 2.4 Atualizar Constantes Frontend

Editar: `src/main/webapp/app/config/authority.constants.ts`

```typescript
export enum Authority {
  ADMIN = 'ROLE_ADMIN',
  USER = 'ROLE_USER',
  VENDEDOR = 'ROLE_VENDEDOR', // ← ADICIONAR
}
```

---

## ⚙️ FASE 3: Implementar Controle de Acesso no Backend

### 3.1 Adicionar Método Helper no VendedorRepository

Editar: `src/main/java/com/dobemtecnologia/repository/VendedorRepository.java`

```java
package com.dobemtecnologia.repository;

import com.dobemtecnologia.domain.Vendedor;
import java.util.Optional;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface VendedorRepository extends JpaRepository<Vendedor, Long> {
  @Query("SELECT v FROM Vendedor v WHERE v.user.login = :login")
  Optional<Vendedor> findByUserLogin(@Param("login") String login);

  Optional<Vendedor> findByUserId(Long userId);
}

```

### 3.2 Atualizar PessoaFisicaResource

Editar: `src/main/java/com/dobemtecnologia/web/rest/PessoaFisicaResource.java`

**Adicionar injeção de dependências:**

```java
private final VendedorRepository vendedorRepository;

public PessoaFisicaResource(
    PessoaFisicaService pessoaFisicaService,
    PessoaFisicaRepository pessoaFisicaRepository,
    PessoaFisicaQueryService pessoaFisicaQueryService,
    VendedorRepository vendedorRepository  // ← ADICIONAR
) {
    this.pessoaFisicaService = pessoaFisicaService;
    this.pessoaFisicaRepository = pessoaFisicaRepository;
    this.pessoaFisicaQueryService = pessoaFisicaQueryService;
    this.vendedorRepository = vendedorRepository;  // ← ADICIONAR
}
```

**Modificar método createPessoaFisica:**

```java
@PostMapping("")
public ResponseEntity<PessoaFisicaDTO> createPessoaFisica(@Valid @RequestBody PessoaFisicaDTO pessoaFisicaDTO) throws URISyntaxException {
  LOG.debug("REST request to save PessoaFisica : {}", pessoaFisicaDTO);

  if (pessoaFisicaRepository.existsById(pessoaFisicaDTO.getCpf())) {
    throw new BadRequestAlertException("pessoaFisica already exists", ENTITY_NAME, "idexists");
  }

  // Se usuário tem role VENDEDOR, vincular ao vendedor automaticamente
  if (SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.VENDEDOR)) {
    String currentUserLogin = SecurityUtils.getCurrentUserLogin()
      .orElseThrow(() -> new BadRequestAlertException("Usuário não autenticado", ENTITY_NAME, "notauthenticated"));

    Vendedor vendedor = vendedorRepository
      .findByUserLogin(currentUserLogin)
      .orElseThrow(() -> new BadRequestAlertException("Vendedor não encontrado", ENTITY_NAME, "vendedornotfound"));

    pessoaFisicaDTO.setVendedorId(vendedor.getId());
  }

  pessoaFisicaDTO = pessoaFisicaService.save(pessoaFisicaDTO);
  return ResponseEntity.created(new URI("/api/pessoa-fisicas/" + pessoaFisicaDTO.getCpf()))
    .headers(HeaderUtil.createEntityCreationAlert(applicationName, true, ENTITY_NAME, pessoaFisicaDTO.getCpf()))
    .body(pessoaFisicaDTO);
}

```

**Modificar método getAllPessoaFisicas (aplicar filtro):**

```java
@GetMapping("")
public ResponseEntity<List<PessoaFisicaDTO>> getAllPessoaFisicas(
  PessoaFisicaCriteria criteria,
  @org.springdoc.core.annotations.ParameterObject Pageable pageable
) {
  LOG.debug("REST request to get PessoaFisicas by criteria: {}", criteria);

  // Aplicar filtro baseado na role
  if (
    SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.VENDEDOR) &&
    !SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.ADMIN)
  ) {
    String currentUserLogin = SecurityUtils.getCurrentUserLogin().orElseThrow();
    Vendedor vendedor = vendedorRepository.findByUserLogin(currentUserLogin).orElseThrow();

    // Filtrar apenas cadastros deste vendedor
    LongFilter vendedorFilter = new LongFilter();
    vendedorFilter.setEquals(vendedor.getId());
    criteria.setVendedorId(vendedorFilter);
  } else if (
    SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.USER) &&
    !SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.ADMIN) &&
    !SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.VENDEDOR)
  ) {
    String currentUserLogin = SecurityUtils.getCurrentUserLogin().orElseThrow();
    // Filtrar apenas cadastros vinculados a este usuário
    // TODO: Implementar filtro por user_id
  }

  Page<PessoaFisicaDTO> page = pessoaFisicaQueryService.findByCriteria(criteria, pageable);
  HttpHeaders headers = PaginationUtil.generatePaginationHttpHeaders(ServletUriComponentsBuilder.fromCurrentRequest(), page);
  return ResponseEntity.ok().headers(headers).body(page.getContent());
}

```

**Modificar método updatePessoaFisica (validação de permissão):**

```java
@PutMapping("/{cpf}")
public ResponseEntity<PessoaFisicaDTO> updatePessoaFisica(
  @PathVariable(value = "cpf", required = false) final String cpf,
  @Valid @RequestBody PessoaFisicaDTO pessoaFisicaDTO
) throws URISyntaxException {
  LOG.debug("REST request to update PessoaFisica : {}, {}", cpf, pessoaFisicaDTO);

  if (pessoaFisicaDTO.getCpf() == null) {
    throw new BadRequestAlertException("Invalid id", ENTITY_NAME, "idnull");
  }
  if (!Objects.equals(cpf, pessoaFisicaDTO.getCpf())) {
    throw new BadRequestAlertException("Invalid ID", ENTITY_NAME, "idinvalid");
  }
  if (!pessoaFisicaRepository.existsById(cpf)) {
    throw new BadRequestAlertException("Entity not found", ENTITY_NAME, "idnotfound");
  }

  // Validar permissão para editar
  if (
    SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.VENDEDOR) &&
    !SecurityUtils.hasCurrentUserThisAuthority(AuthoritiesConstants.ADMIN)
  ) {
    String currentUserLogin = SecurityUtils.getCurrentUserLogin().orElseThrow();
    Vendedor vendedor = vendedorRepository.findByUserLogin(currentUserLogin).orElseThrow();

    PessoaFisica existing = pessoaFisicaRepository.findById(cpf).orElseThrow();
    if (existing.getVendedor() == null || !existing.getVendedor().getId().equals(vendedor.getId())) {
      throw new BadRequestAlertException("Você não tem permissão para editar este cadastro", ENTITY_NAME, "accessdenied");
    }
  }

  pessoaFisicaDTO = pessoaFisicaService.update(pessoaFisicaDTO);
  return ResponseEntity.ok()
    .headers(HeaderUtil.createEntityUpdateAlert(applicationName, true, ENTITY_NAME, pessoaFisicaDTO.getCpf()))
    .body(pessoaFisicaDTO);
}

```

### 3.3 Repetir processo para PessoaJuridicaResource

Aplicar as mesmas modificações em `PessoaJuridicaResource.java`.

---

## ⚙️ FASE 4: Atualizar Navbar (Frontend)

### 4.1 Modificar Navbar Component

Editar: `src/main/webapp/app/layouts/navbar/navbar.component.html`

**Adicionar menu para ROLE_VENDEDOR:**

```html
<!-- MENU CADASTROS - Apenas ROLE_VENDEDOR -->
@if (account() !== null) {
<li
  *jhiHasAnyAuthority="'ROLE_VENDEDOR'"
  ngbDropdown
  class="nav-item dropdown pointer"
  display="dynamic"
  routerLinkActive="active"
  [routerLinkActiveOptions]="{ exact: true }"
>
  <a class="nav-link dropdown-toggle" ngbDropdownToggle href="javascript:void(0);">
    <span>
      <fa-icon icon="user-plus"></fa-icon>
      <span>Cadastros</span>
    </span>
  </a>
  <ul class="dropdown-menu" ngbDropdownMenu>
    <li>
      <a class="dropdown-item" routerLink="/cadastro-pessoa-fisica" (click)="collapseNavbar()">
        <fa-icon icon="user" [fixedWidth]="true"></fa-icon>
        <span>Nova Pessoa Física</span>
      </a>
    </li>
    <li>
      <a class="dropdown-item" routerLink="/pessoa-fisica" (click)="collapseNavbar()">
        <fa-icon icon="list" [fixedWidth]="true"></fa-icon>
        <span>Minhas Pessoas Físicas</span>
      </a>
    </li>
    <li><hr class="dropdown-divider" /></li>
    <li>
      <a class="dropdown-item" routerLink="/cadastro-pessoa-juridica" (click)="collapseNavbar()">
        <fa-icon icon="building" [fixedWidth]="true"></fa-icon>
        <span>Nova Pessoa Jurídica</span>
      </a>
    </li>
    <li>
      <a class="dropdown-item" routerLink="/pessoa-juridica" (click)="collapseNavbar()">
        <fa-icon icon="list" [fixedWidth]="true"></fa-icon>
        <span>Minhas Pessoas Jurídicas</span>
      </a>
    </li>
  </ul>
</li>
}
```

**Adicionar diretiva no menu Entidades (ocultar para não-admin):**

```html
<!-- MENU ENTIDADES - Apenas ROLE_ADMIN -->
@if (account() !== null) {
  <li *jhiHasAnyAuthority="'ROLE_ADMIN'"  <!-- ← ADICIONAR ESTA LINHA -->
      ngbDropdown
      class="nav-item dropdown pointer"
      display="dynamic"
      routerLinkActive="active"
      [routerLinkActiveOptions]="{ exact: true }">
    <a class="nav-link dropdown-toggle" ngbDropdownToggle href="javascript:void(0);" id="entity-menu" data-cy="entity">
      <span>
        <fa-icon icon="th-list"></fa-icon>
        <span jhiTranslate="global.menu.entities.main">Entidades</span>
      </span>
    </a>
    <!-- ... resto do menu ... -->
  </li>
}
```

---

## ⚙️ FASE 5: Compilar e Testar

### 5.1 Compilar Backend

```bash
./mvnw clean compile
```

### 5.2 Executar Liquibase

```bash
./mvnw liquibase:update
```

### 5.3 Iniciar Aplicação

```bash
./mvnw
```

### 5.4 Compilar Frontend (em outro terminal)

```bash
npm start
```

---

## ✅ CHECKLIST DE VERIFICAÇÃO

- [ ] JDL importado com sucesso
- [ ] Entidade Vendedor criada
- [ ] Role ROLE_VENDEDOR adicionada
- [ ] PessoaFisica possui FK vendedor_id e user_id
- [ ] PessoaJuridica possui FK vendedor_id e user_id
- [ ] Filtros implementados no backend
- [ ] Validações de permissão implementadas
- [ ] Navbar atualizada com controle de acesso
- [ ] Menu Entidades oculto para ROLE_VENDEDOR
- [ ] Menu Cadastros visível para ROLE_VENDEDOR
- [ ] Testes realizados com os 3 perfis

---

## 🧪 TESTES

### Criar Usuário Vendedor (via Admin)

```sql
-- 1. Criar usuário
INSERT INTO jhi_user (id, login, password_hash, first_name, last_name, email, activated, lang_key, created_by, created_date)
VALUES (nextval('jhi_user_seq'), 'vendedor1', '$2a$10$VEjxo0jq2YT9Zc1z7x1ILOYFc0V5DvWzJHxj0xY8c0Z1c0z1c0z1c', 'João', 'Vendedor', 'vendedor1@email.com', true, 'pt-br', 'system', now());

-- 2. Associar role ROLE_VENDEDOR
INSERT INTO jhi_user_authority (user_id, authority_name)
VALUES ((SELECT id FROM jhi_user WHERE login = 'vendedor1'), 'ROLE_VENDEDOR');

-- 3. Criar registro Vendedor
INSERT INTO vendedor (id, cpf, nome_completo, user_id, ativo)
VALUES (nextval('vendedor_seq'), '12345678901', 'João Vendedor', (SELECT id FROM jhi_user WHERE login = 'vendedor1'), true);
```

### Testar Fluxos

1. Login com admin → deve ver tudo
2. Login com vendedor1 → deve ver apenas menu Cadastros
3. Vendedor cadastra Pessoa Física → deve vincular automaticamente
4. Vendedor lista Pessoas Físicas → deve ver apenas as dele

---

## 📝 PRÓXIMOS PASSOS

Após completar essas fases:

1. Implementar autocadastro para ROLE_USER
2. Criar formulário de Pessoa Jurídica
3. Ajustes finos de UX
4. Documentação completa

---

**Última atualização:** 17/10/2025
**Autor:** Elton Gonçalves

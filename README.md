# Reportero
Projeto conduzido durante a disciplina de Engenharia de Software. Professor: Breno Bernard Nicolau de França, IC-UNICAMP.

Aplicaremos na prática os conceitos aprendidos em aula, incluindo modelagem, implementação e documentação de software. 

## Tema
Um app para que alunos e funcionários registrem problemas no campus de forma simples e rápida. Pelo celular, a pessoa pode tirar uma foto, adicionar a localização e enviar ocorrências como falhas de infraestrutura, segurança ou serviços — por exemplo poste caído, árvore danificada, banco quebrado, lâmpada queimada, acidente ou carro estacionado irregularmente. A proposta é centralizar essas reclamações em uma plataforma geolocalizada, com acompanhamento em tempo real, ajudando a universidade a identificar problemas que muitas vezes passam despercebidos e a responder com mais eficiência

## Arquitetura

### Estilo Arquitetural Adotado

- **No Cliente (Frontend):** padrão **MVVM (Model-View-ViewModel)** com Flutter, com separação estrita entre a interface de usuário (`lib/views/`), a lógica de estado e validação (`lib/viewmodels/`) e as entidades de dados (`lib/models/`).
- **No Sistema Geral:** arquitetura **Cliente-Servidor (Serverless / BaaS)**. O aplicativo Flutter consome o **Supabase** diretamente via requisições HTTP/REST (PostgREST) para o banco e via Supabase Storage para upload de fotos — não há servidor de aplicação intermediário.
- **Identidade e anonimato:** o projeto não usa Supabase Auth. Cada denúncia é opcionalmente anônima, e os apoios (upvotes) são vinculados a um identificador de dispositivo gerado e persistido localmente (`DispositivoService`), preservando o anonimato do usuário no feed.
- **Padrão de Projeto (Singleton):** `DenunciaService` e `DispositivoService` implementam Singleton (construtor privado + instância estática via `factory`), garantindo uma única instância de acesso ao cliente Supabase e ao identificador de dispositivo, evitando conexões redundantes e inconsistência de estado entre telas.

### Diagramas C4

#### Nível 1 — Contexto

```mermaid
graph TD
    U["Universitário / Cidadão<br/>(usuário do app)"] -->|Registra denúncias,<br/>visualiza feed, apoia| APP["Reportero<br/>(Aplicativo Flutter)"]
    APP -->|Lê e grava dados via<br/>HTTP/REST + Storage| SB["Supabase<br/>(Backend as a Service)"]
```

#### Nível 2 — Contêiner

```mermaid
graph TD
    subgraph Cliente
        FLT["Flutter Application<br/>(Android / iOS / Web)"]
    end
    subgraph "Supabase (BaaS)"
        PG["Postgres Database<br/>(tabelas denuncias, apoios — RLS habilitado)"]
        ST["Supabase Storage<br/>(fotos das denúncias)"]
    end
    FLT -->|REST via PostgREST| PG
    FLT -->|Upload/URL pública| ST
```

#### Nível 3 — Componentes (dentro do Flutter Application)

```mermaid
graph TD
    V1["Views<br/>FormularioDenunciaScreen, FeedScreen, DenunciaCard"]
    VM1["ViewModels<br/>DenunciaViewModel, FeedViewModel"]
    S1["Services (Singleton)<br/>DenunciaService, DispositivoService"]
    SDK["Supabase SDK<br/>(supabase_flutter)"]

    V1 -->|comandos do usuário| VM1
    VM1 -->|valida e delega| S1
    S1 -->|chamadas REST/Storage| SDK
    SDK -->|resposta| S1
    S1 -->|Denuncia / erros| VM1
    VM1 -->|estado atualizado| V1
```

## Testes

O projeto segue a pirâmide de testes: testes de unidade na base, testes de widget no meio e testes de integração no topo.

### Pré-requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) (stable)
- [Docker](https://docs.docker.com/get-docker/) — apenas para testes de integração
- [Supabase CLI](https://supabase.com/docs/guides/cli/getting-started) — apenas para testes de integração

### Testes de unidade e widget

Não exigem nenhuma infraestrutura além do Flutter:

```bash
cd app
flutter test test/models test/viewmodels test/services test/widget_test.dart
```

### Testes de integração

Requerem o Supabase rodando localmente via Docker. Execute na raiz do repositório:

```bash
supabase start                    # sobe PostgreSQL + PostgREST em Docker
                                  # as migrations são aplicadas automaticamente
cd app
flutter test test/integration     # roda os testes contra o banco local
cd ..
supabase stop                     # derruba os containers
```

### Todos os testes de uma vez (sem integração)

```bash
cd app
flutter test
```

### CI

O pipeline roda automaticamente no GitHub Actions a cada push ou pull request. Acesse a aba **Actions** no repositório para acompanhar as execuções.
# Reportero
Projeto conduzido durante a disciplina de Engenharia de Software. Professor: Breno Bernard Nicolau de França, IC-UNICAMP.

Aplicaremos na prática os conceitos aprendidos em aula, incluindo modelagem, implementação e documentação de software. 

## Tema
Um app para que alunos e funcionários registrem problemas no campus de forma simples e rápida. Pelo celular, a pessoa pode tirar uma foto, adicionar a localização e enviar ocorrências como falhas de infraestrutura, segurança ou serviços — por exemplo poste caído, árvore danificada, banco quebrado, lâmpada queimada, acidente ou carro estacionado irregularmente. A proposta é centralizar essas reclamações em uma plataforma geolocalizada, com acompanhamento em tempo real, ajudando a universidade a identificar problemas que muitas vezes passam despercebidos e a responder com mais eficiência

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
flutter test test/models test/viewmodels test/widget_test.dart
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

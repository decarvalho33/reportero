# Requisitos — Reportero Unicamp

## 1. Técnicas de Elicitação

### 1.1 Brainstorming

#### Execução

**Data:** 16 de junho de 2026, às 18h00  
**Formato:** Reunião remota via Google Meet  
**Participantes:** Álvaro, Axel, Gabriel, Gilberto e João

A sessão teve como objetivo identificar funcionalidades que
agregariam valor real ao usuário do Reportero Unicamp,
partindo do que já estava implementado (registro e feed de
denúncias) e explorando o que faria sentido como próximo
incremento.

#### Ideias geradas

As discussões partiram de duas funcionalidades concretas
levantadas pelo grupo:

- **Fotos nas denúncias:** permitir que o usuário anexe
  evidência visual ao registrar um problema.
- **Mapa de denúncias:** visualizar geograficamente onde
  os incidentes estão concentrados no campus.

O grupo discutiu as implicações técnicas de cada uma —
fotos exigiriam integração com Supabase Storage, mapa
exigiria coordenadas geográficas reais em vez de texto
livre no campo `localizacao`. Isso levou à percepção de
que ambas compartilham uma dependência comum: a necessidade
de localização estruturada e julgamento visual das
ocorrências.

A partir disso, o grupo identificou um segundo eixo
temático independente: a possibilidade de usuários
**interagirem com denúncias existentes** — seja confirmando
que também viram o problema, comentando ou acompanhando
atualizações.

Por fim, o grupo definiu um recorte de escopo: as
funcionalidades de interação serão restritas a **alunos
da Unicamp**, diferenciando o acesso entre o público geral
(que pode visualizar e registrar) e a comunidade acadêmica
autenticada (que pode interagir).

#### Resultado

A sessão convergiu em dois épicos:

- **Épico 1 — Localização e Visualização:** agrupa as
  funcionalidades de foto, mapa e localização estruturada,
  reconhecendo que compartilham a mesma base técnica.
- **Épico 2 — Interação com Denúncias:** agrupa as
  funcionalidades de engajamento da comunidade acadêmica
  com os registros existentes, com escopo restrito a
  alunos da Unicamp.
- O terceiro e último épico, conforme validado posterior com o Prof. Breno, seria uma documentação do trabalho feito previamente, para a entrega 1. Esse épico seria relativo à denúncia de anomalias, sendo o núcleo do aplicativo.

### 1.2 Entrevistas
(Alvaro irá conduzir.)

## 2. Épicos e Histórias de Usuário

### 2.1 Épico 1
### 2.2 Épico 2
### 2.3 Épico 3
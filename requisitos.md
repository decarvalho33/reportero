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

#### Introdução

Este relatório consolida os achados de quatro entrevistas semiestruturadas conduzidas com estudantes da UNICAMP e da USP, no contexto da elicitação de requisitos para um aplicativo voltado ao registro, à divulgação e ao encaminhamento de denúncias sobre problemas de infraestrutura e serviços no ambiente universitário.

O objetivo da elicitação foi compreender as vivências cotidianas dos estudantes, os problemas que enfrentam, as tentativas (em geral frustradas) de resolvê-los pelos canais existentes e a visão de cada participante sobre quais funcionalidades o aplicativo deveria priorizar.

#### Metodologia

Foram realizadas quatro entrevistas individuais com estudantes de graduação em fase final ou intermediária de curso. Cada entrevista percorreu três eixos:

1. **Vivência e contexto de uso** — quais espaços e serviços o estudante utiliza no campus.
2. **Problemas e tentativas de solução** — quais falhas enfrentou e o que tentou fazer a respeito.
3. **Foco desejado para o aplicativo** — quais funcionalidades considera essenciais.

A amostra contemplou duas instituições (UNICAMP e USP) e cursos de áreas distintas (engenharia de computação, geologia e design), o que permitiu observar tanto pontos de convergência quanto necessidades específicas de cada perfil.

#### Perfil dos entrevistados

| Participante | Curso | Instituição |
|---|---|---|
| P1 | Engenharia de Computação | UNICAMP |
| P2 | Geologia | UNICAMP |
| P3 | Engenharia de Computação | UNICAMP |
| P4 | Design | USP |

#### Síntese por entrevistado

**P1.** Usuário frequente de infraestrutura de mobilidade e do bandejão, P1 acionou canais institucionais e a empresa terceirizada responsável pelo serviço de alimentação sem obter resolução concreta. Sua contribuição mais relevante é a distinção entre dois modos de operação do aplicativo: um **modo social** (feed, visibilidade entre alunos) e um **modo formal** (encaminhamento categorizado às autoridades). Considera geolocalização automática pouco relevante — a comunidade reconhece os locais por descrição textual —, mas valoriza categorias como mecanismo de organização e roteamento de denúncias.

**P2.** Usuária de transporte, biblioteca, bandejão e moradia estudantil, P2 frequentemente relata problemas de terceiros (vizinhos, outros institutos), o que sugere que o aplicativo deve permitir registros de problemas observados ou ouvidos. Sua prioridade declarada é o **anonimato**, apontado como condição para que as denúncias sequer existam — especialmente em contextos de dependência direta da instituição, onde há risco percebido de retaliação.

**P3.** Dependente do transporte circular universitário, P3 enfatiza **eficiência e baixa fricção**: a ação principal deve ser completada em poucos cliques. Introduz o padrão de "apoiar uma denúncia existente em vez de criar uma nova", que funciona como mecanismo de agregação e deduplicação — ao iniciar um registro semelhante ao de outro já existente, o sistema deveria sugerir o existente para apoio ou comentário.

**P4.** Estudante de design em outra instituição (USP), usuário intenso de laboratórios e oficinas, reforça a importância das categorias e introduz um uso **proativo** delas: além de registrar problemas passados, o estudante poderia consultar a situação atual de um serviço (ex.: verificar se o ônibus está quebrado) para se planejar antes de sair. Isso expande o conceito de categoria de uma simples taxonomia para um painel consultável de status de serviços. Sua participação também sinaliza potencial **multi-instituição** do aplicativo.

#### Análise temática consolidada

As entrevistas convergem em torno de alguns temas centrais:

- **A falha dos canais existentes como motivação.** A experiência de P1 (canal institucional sem ação, fornecedor sem resposta) e o desejo de P2 de "atrair a atenção" da universidade apontam para a mesma lacuna: os canais oficiais são lentos, opacos ou inertes. A proposta de valor do aplicativo emerge desse vácuo — não substituir os canais, mas dar visibilidade coletiva e peso político às denúncias, de modo que problemas individuais e dispersos se transformem em sinais agregados difíceis de ignorar.
- **Convergências sobre funcionalidades.** Categorias foram apontadas como essenciais por P1 e P4; feed e engajamento foram valorizados por P1, P3 e P4; rapidez foi destacada por P3.
- **Tensões de projeto.** (1) Feed social × canal formal: o feed serve à comunidade de estudantes; o encaminhamento à universidade deve ser estruturado por categorias. (2) Anonimato × verificabilidade: a prioridade pelo anonimato favorece a existência das denúncias, mas pode reduzir a riqueza das informações necessárias para ação institucional. (3) Engajamento como força coletiva: o feed e os upvotes não são apenas recursos sociais — são o mecanismo que converte denúncias isoladas em pressão agregada.

#### Requisitos levantados nas entrevistas

**Funcionais**

- **RF01 — Categorização de denúncias.** O sistema deve permitir classificar denúncias por categoria (ex.: transporte, alimentação/bandejão, moradia, laboratórios/oficinas, infraestrutura física).
- **RF02 — Criação rápida de denúncia.** O sistema deve permitir registrar uma denúncia em poucos passos/cliques.
- **RF03 — Feed público de denúncias.** O sistema deve disponibilizar um feed visível à comunidade, com as denúncias registradas.
- **RF04 — Apoio (upvote) a denúncias.** O sistema deve permitir que usuários apoiem denúncias existentes.
- **RF05 — Comentários.** O sistema deve permitir comentar denúncias.
- **RF06 — Agregação/deduplicação.** Ao iniciar uma denúncia semelhante a uma existente, o sistema deve sugerir a denúncia existente para apoio ou comentário, evitando duplicatas.
- **RF07 — Denúncia anônima.** O sistema deve oferecer a opção de denunciar de forma anônima.
- **RF08 — Localização textual.** O sistema deve permitir descrever o local da ocorrência por texto, com geolocalização automática opcional.
- **RF09 — Encaminhamento formal por categoria.** O sistema deve estruturar e encaminhar denúncias ao órgão/empresa responsável a partir da categoria, em canal distinto do feed.
- **RF10 — Consulta de status de serviços.** O sistema deve permitir consultar a situação atual de serviços por categoria (ex.: verificar se um ônibus está fora de operação) para apoiar o planejamento do usuário.
- **RF11 — Relato de problemas de terceiros.** O sistema deve permitir registrar problemas observados ou relatados por outros, não apenas vividos diretamente.

**Não funcionais**

- **RNF01 — Privacidade e anonimato.** A proteção da identidade do denunciante deve ser tratada como prioridade de projeto.
- **RNF02 — Usabilidade e baixa fricção.** As ações principais (denunciar, apoiar, comentar) devem exigir o mínimo de passos possível.
- **RNF03 — Escalabilidade multi-instituição.** A arquitetura deve permitir o atendimento a múltiplas universidades/campi (ex.: UNICAMP e USP).
- **RNF04 — Confiabilidade do sinal coletivo.** Os mecanismos de engajamento (feed, upvotes) devem refletir de forma fidedigna a relevância e a recorrência dos problemas.

## 2. Épicos e Histórias de Usuário

### 2.1 Épico 1
### 2.2 Épico 2
### 2.3 Épico 3
# Requisitos — Reportero Unicamp

## 1. Técnicas de Elicitação

### 1.1 Brainstorming 1

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

### 1.3 Brainstorming 2

#### Execução

**Data:** 09 de julho de 2026, às 19h00  
**Formato:** Reunião remota via Google Meet  
**Participantes:** Álvaro, Axel, Gabriel, Gilberto e João

A sessão teve como objetivo planejar a entrega 3, definindo
quais funcionalidades novas deveriam ser incorporadas ao
Reportero Unicamp — já relativamente completo do ponto de
vista do usuário final — e organizando a divisão de tarefas
entre os membros do grupo.

#### Ideias geradas

O grupo já sabia, de antemão, que seria necessária uma
funcionalidade de **login**: trazer responsabilização para
os usuários, mantendo a possibilidade de denúncia anônima,
como forma de coibir o mau uso da plataforma por usuários
mal-intencionados (flooding, boicote a denúncias de
terceiros, etc.).

Em seguida, levantou-se a ideia de trazer uma segunda
interface para o aplicativo, representando o lado do
**administrador**. Entendeu-se que essa seria uma forma
vantajosa de agregar novas funcionalidades a um app já
relativamente completo do ponto de vista do usuário final.
A partir disso, arquitetou-se o conjunto de funcionalidades
que deveria compor a visão do administrador (vide Épico 6).

Por fim, o grupo optou por incluir uma terceira feature,
para trazer margem de segurança para a avaliação da entrega:
um **painel do usuário** com o histórico de denúncias
registradas, com funcionalidades de edição e de notificação
de atualização de status sobre as denúncias realizadas
(vide Épico 5).

#### Resultado

A sessão convergiu em três novos épicos:

- **Épico 4 — Autenticação institucional:** login com e-mail
  institucional da Unicamp, trazendo responsabilização ao
  usuário sem eliminar a possibilidade de denúncia anônima.
- **Épico 5 — Perfil do usuário e minhas denúncias:** painel
  pessoal com histórico, edição e notificações de status das
  denúncias do próprio usuário.
- **Épico 6 — Interface administrativa para a Unicamp:** área
  restrita para gestão, triagem e resposta às denúncias por
  parte da administração.

Além disso, foi discutida a divisão de tarefas e as demais
demandas da entrega 3:

1. Elaborar os épicos e histórias de usuário.
2. Refatoração do código existente.
3. Preparar a apresentação/demonstração.
4. Reforçar os testes automatizados.
5. Atualizar o processo.

Com as tarefas atribuídas aos membros do grupo, a sessão
foi dada por encerrada.

## 2. Épicos e Histórias de Usuário

### 2.1 Épico 1 — Criação e Registro de Denúncias

Permitir que os universitários registrem denúncias sobre problemas no campus de forma rápida, em poucos cliques, garantindo agilidade e organização.

- **US 1.1 — Preencher formulário de denúncia**:
  Como universitário, quero preencher um formulário de denúncia simplificado e rápido, para registrar um problema encontrado no campus com o mínimo de cliques possível.

- **US 1.2 — Classificar denúncia por categoria**:
  Como universitário, quero classificar o problema selecionando uma categoria (ex: infraestrutura, segurança, limpeza, etc.), para que a denúncia seja organizada e roteada corretamente.

- **US 1.3 — Informar localização no mapa**:
  Como universitário, quero informar a localização da ocorrência no mapa, para que o problema possa ser identificado e encontrado rapidamente.

- **US 1.4 — Adicionar descrição do incidente**:
  Como universitário, quero adicionar uma breve descrição do incidente, para fornecer contexto adicional sobre a denúncia.

- **US 1.5 — Anexar foto do incidente**:
  Como universitário, quero anexar uma foto do incidente de forma prática, para que outros estudantes e a administração visualizem a gravidade do problema.

- **US 1.6 — Registrar denúncia anônima ou identificada**:
  Como universitário, quero ter a opção clara de registrar a denúncia de forma anônima (ou me identificar, se preferir), para relatar problemas sem fricção e sem medo de exposição.

---

### 2.2 Épico 2 — Visualização e Consulta de Denúncias

Permitir que os universitários visualizem um feed de denúncias registradas na plataforma para acompanhar os problemas reportados pela comunidade acadêmica.

- **US 2.1 — Visualizar feed de denúncias**:
  Como universitário, quero visualizar um feed com uma lista de denúncias, para conhecer e me engajar com os problemas reportados no campus.

- **US 2.2 — Visualizar detalhes da denúncia**:
  Como universitário, quero visualizar o título, a categoria, a localização, o autor (ou indicação de anonimato) e a descrição de cada denúncia, para compreender melhor a ocorrência.

- **US 2.3 — Ordenar denúncias por mais recentes**:
  Como universitário, quero visualizar as denúncias ordenadas pelas mais recentes, para acompanhar os acontecimentos e problemas atuais da universidade.

- **US 2.4 — Filtrar denúncias por categoria**:
  Como universitário, quero filtrar as denúncias por categoria, para facilitar a busca, consulta e análise das ocorrências que mais me interessam.

---

### 2.3 Épico 3 — Priorização Comunitária de Denúncias e Engajamento

Permitir que a comunidade acadêmica apoie denúncias para dar visibilidade e peso coletivo aos problemas mais relevantes.

- **US 3.1 — Apoiar (upvote) uma denúncia**:
  Como universitário, quero apoiar (dar "upvote") uma denúncia, para demonstrar que também fui afetado pelo problema e ajudar a dar peso coletivo àquela questão.

- **US 3.2 — Visualizar quantidade de apoios**:
  Como universitário, quero visualizar a quantidade de apoios em uma denúncia, para identificar facilmente os problemas mais recorrentes e críticos do campus.

- **US 3.3 — Ordenar feed por quantidade de apoios**:
  Como universitário, quero ordenar o feed de denúncias pela quantidade de apoios, para visualizar as ocorrências consideradas mais relevantes pela comunidade.

- **US 3.4 — Remover apoio de uma denúncia**:
  Como universitário, quero remover meu apoio de uma denúncia, caso tenha cometido um erro ao clicar ou tenha mudado de opinião.

---

### 2.4 Épico 4 — Autenticação institucional

Cobre o cadastro, acesso e gestão de sessão dos usuários por meio
de e-mail institucional da Unicamp. É um épico-base: os Épicos 5 e
6 dependem dele.

- **US 4.1 — Cadastro com e-mail institucional**:
  Como membro da comunidade Unicamp, quero me cadastrar usando meu
  e-mail institucional, para garantir que apenas pessoas da
  universidade acessem a plataforma.

- **US 4.2 — Verificação de e-mail**:
  Como novo usuário, quero confirmar minha conta por um link enviado
  ao meu e-mail, para validar que o endereço informado é realmente meu.

- **US 4.3 — Login com e-mail e senha**:
  Como usuário cadastrado, quero entrar na plataforma com meu e-mail
  e senha, para acessar minhas funcionalidades pessoais.

- **US 4.4 — Recuperação de senha**:
  Como usuário que esqueceu a senha, quero solicitar a redefinição da
  senha por e-mail, para recuperar o acesso à minha conta.

- **US 4.5 — Logout**:
  Como usuário autenticado, quero encerrar minha sessão, para proteger
  minha conta em dispositivos compartilhados.

---

### 2.5 Épico 5 — Perfil do usuário e minhas denúncias

Cobre a área pessoal do usuário autenticado. Depende do Épico 4.

- **US 5.1 — Visualizar perfil**:
  Como usuário autenticado, quero visualizar meu perfil, para conferir
  os dados que tenho cadastrados na plataforma.

- **US 5.2 — Editar dados do perfil**:
  Como usuário autenticado, quero editar meus dados de perfil, para
  manter minhas informações atualizadas.

- **US 5.3 — Listar minhas denúncias**:
  Como usuário autenticado, quero ver a lista das denúncias que eu
  registrei, para acompanhar o que já reportei na plataforma.

- **US 5.4 — Filtrar e buscar minhas denúncias**:
  Como usuário autenticado, quero filtrar e buscar entre as minhas
  denúncias, para encontrar rapidamente um registro específico.

- **US 5.5 — Receber notificação de atualização de status**:
  Como autor de uma denúncia, quero ser notificado quando o status
  dela mudar, para acompanhar a resolução sem precisar verificar
  manualmente.

- **US 5.6 — Editar ou excluir uma denúncia própria**:
  Como autor de uma denúncia, quero editar ou excluir um registro meu,
  para corrigir informações erradas ou remover algo enviado por engano.

---

### 2.6 Épico 6 — Interface administrativa para a Unicamp

Cobre a área restrita destinada à administração da universidade.
Depende do Épico 4.

- **US 6.1 — Acesso restrito de administrador**:
  Como administrador da Unicamp, quero acessar uma área restrita com
  credenciais próprias, para gerenciar as denúncias com segurança.

- **US 6.2 — Painel geral de denúncias**:
  Como administrador, quero ver um painel geral com as denúncias
  registradas, para ter uma visão consolidada dos problemas do campus.

- **US 6.3 — Detalhar denúncia (visão admin)**:
  Como administrador, quero abrir os detalhes completos de uma denúncia,
  para compreender integralmente a ocorrência antes de agir.

- **US 6.4 — Atualizar status da denúncia**:
  Como administrador, quero atualizar o status de uma denúncia, para
  informar a comunidade sobre o andamento da resolução.

- **US 6.5 — Responder ao autor da denúncia**:
  Como administrador, quero comentar ou responder ao autor de uma
  denúncia, para dar retorno sobre o tratamento do problema.

- **US 6.6 — Atribuir denúncia a setor/responsável**:
  Como administrador, quero atribuir uma denúncia a um setor ou
  responsável, para direcionar o problema a quem pode resolvê-lo.

- **US 6.7 — Filtrar e buscar denúncias (admin)**:
  Como administrador, quero filtrar e buscar denúncias, para localizar
  ocorrências específicas em meio ao volume total.

- **US 6.8 — Exportar relatório de denúncias**:
  Como administrador, quero exportar um relatório das denúncias, para
  realizar análises e prestação de contas fora da plataforma.

- **US 6.9 — Gerenciar administradores**:
  Como administrador com permissão de gestão, quero gerenciar outros
  administradores, para controlar quem tem acesso à área restrita.
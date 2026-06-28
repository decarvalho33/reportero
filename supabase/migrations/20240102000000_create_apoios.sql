-- Tabela de apoios (upvotes) das denúncias — Épico 3 (priorização comunitária).
--
-- A identidade do usuário é um "device id" anônimo gerado e persistido no app
-- (sem login), enviado como usuario_id. Isso preserva o anonimato: o feed nunca
-- expõe quem apoiou. O UNIQUE garante no máximo um apoio por dispositivo por
-- denúncia (atende "apoiar uma vez" e viabiliza "remover meu apoio").
--
-- Limitação conhecida: por ser por dispositivo, o id é forjável e não resiste a
-- reinstalação do app — a contagem de apoios é um sinal coletivo, não um número
-- à prova de fraude (ataque Sybil).
CREATE TABLE apoios (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  denuncia_id UUID        NOT NULL REFERENCES denuncias(id) ON DELETE CASCADE,
  usuario_id  TEXT        NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CONSTRAINT apoios_unico_por_usuario UNIQUE (denuncia_id, usuario_id)
);

-- Índices para acelerar a contagem por denúncia e o lookup dos apoios do usuário.
CREATE INDEX idx_apoios_denuncia_id ON apoios (denuncia_id);
CREATE INDEX idx_apoios_usuario_id  ON apoios (usuario_id);

ALTER TABLE apoios ENABLE ROW LEVEL SECURITY;

-- Acesso público (sem autenticação), seguindo o mesmo modelo de `denuncias`.
-- A "posse" do apoio é convencionada pelo usuario_id (device id) enviado pelo app.
CREATE POLICY "Leitura pública de apoios"
ON apoios FOR SELECT
USING (true);

CREATE POLICY "Inserção pública de apoios"
ON apoios FOR INSERT
WITH CHECK (true);

CREATE POLICY "Deleção pública de apoios"
ON apoios FOR DELETE
USING (true);

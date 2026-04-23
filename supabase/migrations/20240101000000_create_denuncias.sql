CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE denuncias (
  id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  titulo      TEXT        NOT NULL,
  descricao   TEXT        NOT NULL,
  localizacao TEXT        NOT NULL,
  autor       TEXT        NOT NULL DEFAULT 'Anônimo',
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE denuncias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leitura pública de denuncias"
ON denuncias FOR SELECT
USING (true);

CREATE POLICY "Inserção pública de denuncias"
ON denuncias FOR INSERT
WITH CHECK (true);

CREATE POLICY "Deleção pública de denuncias"
ON denuncias FOR DELETE
USING (true);

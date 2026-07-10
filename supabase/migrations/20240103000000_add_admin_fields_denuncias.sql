-- Adiciona os campos de administração (Épico 6) à tabela denuncias
ALTER TABLE denuncias 
ADD COLUMN status TEXT NOT NULL DEFAULT 'Pendente',
ADD COLUMN setor_responsavel TEXT,
ADD COLUMN resposta_admin TEXT;
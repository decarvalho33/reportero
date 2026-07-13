-- Adiciona o status da denúncia — base do Épico 5 (US 5.5, notificação de mudança de status).
ALTER TABLE denuncias
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'Aberta';

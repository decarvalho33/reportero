-- Adiciona a URL da foto de perfil do usuário (Épico 5 — US 5.1/5.2).
--
-- Reaproveita o bucket de Storage `evidencias` (mesmo do Épico 1), sob o
-- prefixo `perfil/`, em vez de criar um bucket novo: não há bucket algum
-- versionado neste repositório (o `evidencias` foi criado manualmente no
-- dashboard do Supabase), então criar outro exigiria o mesmo passo manual.
--
-- Já é coberta pelas políticas de RLS existentes em `profiles`
-- (auth.uid() = id), sem necessidade de policy nova.
ALTER TABLE profiles ADD COLUMN foto_perfil_url TEXT;

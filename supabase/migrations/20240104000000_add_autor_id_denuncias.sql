-- Adiciona o vínculo real entre denúncia e usuário autenticado — base do Épico 5.
--
-- autor_id referencia auth.users(id) e é opcional: denúncias criadas antes desta
-- migration (ou enviadas anonimamente) continuam válidas, apenas sem dono.
ALTER TABLE denuncias
ADD COLUMN IF NOT EXISTS autor_id UUID REFERENCES auth.users(id);

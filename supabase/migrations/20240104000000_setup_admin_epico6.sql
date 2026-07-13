-- 1. Adiciona a flag de permissão na tabela profiles
ALTER TABLE profiles ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT false;

-- 2. Adiciona os campos de gestão na tabela denuncias
ALTER TABLE denuncias 
ADD COLUMN status TEXT NOT NULL DEFAULT 'Pendente',
ADD COLUMN setor_responsavel TEXT,
ADD COLUMN resposta_admin TEXT;

-- 3. Cria uma função segura para checar se o usuário logado é admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT is_admin FROM profiles WHERE id = auth.uid();
$$;

-- 4. Adiciona a política RLS real
CREATE POLICY "Admins podem atualizar denuncias"
ON denuncias FOR UPDATE
USING (public.is_admin());

-- 5. ATUALIZA O CACHE DO SUPABASE (A SOLUÇÃO PARA O CI)
NOTIFY pgrst, 'reload schema';
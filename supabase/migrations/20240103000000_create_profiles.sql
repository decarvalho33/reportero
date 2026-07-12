-- Tabela de perfis dos usuários — Épico 4 (autenticação institucional).
--
-- Cada perfil tem relação 1:1 com um usuário do Supabase Auth (auth.users) e
-- guarda dados de aplicação (nome) que o auth.users não expõe pela API REST.
-- Serve de base para os Épicos 5 (perfil e minhas denúncias) e 6 (interface
-- administrativa), que dependem da autenticação.
--
-- O preenchimento é automático: um trigger cria a linha do perfil assim que um
-- usuário nasce em auth.users, lendo o nome enviado no cadastro (user_metadata).
CREATE TABLE profiles (
  id         UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome       TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Cada usuário só enxerga e edita o próprio perfil. auth.uid() é extraído do JWT
-- da sessão pelo Supabase, então quem não está logado não acessa nada.
CREATE POLICY "Usuário lê o próprio perfil"
ON profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Usuário atualiza o próprio perfil"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- Função disparada quando um novo usuário é criado em auth.users. Roda com
-- SECURITY DEFINER (privilégio de administrador) para inserir o perfil mesmo
-- antes de existir sessão ativa — necessário quando a confirmação de email está
-- habilitada, pois nesse caso o usuário ainda não está autenticado no cadastro.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  INSERT INTO public.profiles (id, nome)
  VALUES (NEW.id, NEW.raw_user_meta_data ->> 'nome');
  RETURN NEW;
END;
$$;

-- Dispara a função acima após cada novo usuário registrado.
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

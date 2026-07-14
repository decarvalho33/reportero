-- Restringe edição e exclusão de denúncias ao próprio autor (US 5.6/5.7).
--
-- Antes desta migration não havia política de UPDATE (então nenhuma edição
-- era possível via API) e a política de DELETE era pública (USING (true)):
-- qualquer pessoa, autenticada ou não, podia excluir qualquer denúncia.
-- Isso é substituído por políticas que exigem auth.uid() = autor_id, para
-- que só o autor logado edite ou exclua a própria denúncia. Denúncias sem
-- autor_id (anônimas ou anteriores ao Épico 5) ficam órfãs e não podem ser
-- editadas/excluídas por ninguém via API.
DROP POLICY IF EXISTS "Deleção pública de denuncias" ON denuncias;

CREATE POLICY "Autor edita a própria denúncia"
ON denuncias FOR UPDATE
USING (auth.uid() = autor_id)
WITH CHECK (auth.uid() = autor_id);

CREATE POLICY "Autor exclui a própria denúncia"
ON denuncias FOR DELETE
USING (auth.uid() = autor_id);

-- Script de configuração do banco Supabase
-- Execute este script no SQL Editor do Supabase Dashboard
-- URL: https://[SEU_PROJETO].supabase.co

-- 1. Criar tabela jokes
CREATE TABLE IF NOT EXISTS jokes (
  id SERIAL PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  view_count INTEGER NOT NULL DEFAULT 0,
  deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- 2. Criar índices para otimização
CREATE INDEX IF NOT EXISTS idx_jokes_view_count ON jokes(view_count);
CREATE INDEX IF NOT EXISTS idx_jokes_deleted ON jokes(deleted);
CREATE INDEX IF NOT EXISTS idx_jokes_updated_at ON jokes(updated_at DESC);

-- 3. Habilitar Row Level Security (RLS)
ALTER TABLE jokes ENABLE ROW LEVEL SECURITY;

-- 4. Criar políticas de acesso público para CRUD completo

-- Remover policies antigas se existirem
DROP POLICY IF EXISTS "Permitir leitura pública" ON jokes;
DROP POLICY IF EXISTS "Permitir inserção pública" ON jokes;
DROP POLICY IF EXISTS "Permitir atualização pública" ON jokes;
DROP POLICY IF EXISTS "Permitir exclusão pública" ON jokes;

-- Política de SELECT (leitura) - todos podem ler
CREATE POLICY "Permitir leitura pública"
ON jokes FOR SELECT
USING (true);

-- Política de INSERT (criação) - todos podem criar
CREATE POLICY "Permitir inserção pública"
ON jokes FOR INSERT
WITH CHECK (true);

-- Política de UPDATE (atualização) - todos podem atualizar
CREATE POLICY "Permitir atualização pública"
ON jokes FOR UPDATE
USING (true)
WITH CHECK (true);

-- Política de DELETE (exclusão) - todos podem deletar
CREATE POLICY "Permitir exclusão pública"
ON jokes FOR DELETE
USING (true);

-- 5. Inserir piadas iniciais (sem especificar id, será auto-gerado)
INSERT INTO jokes (question, answer, view_count, deleted, created_at, updated_at) VALUES
  ('Tem coroa, mas não é rei, tem escama, mas não é peixe?', 'O abacaxi', 0, false, NOW(), NOW()),
  ('Cai em pé e corre deitado?', 'A chuva', 0, false, NOW(), NOW()),
  ('Tem dentes mas não morde?', 'O garfo', 0, false, NOW(), NOW()),
  ('Quanto mais se perde, maior fica?', 'O buraco', 0, false, NOW(), NOW()),
  ('É surdo e mudo, mas conta tudo?', 'O livro', 0, false, NOW(), NOW()),
  ('Tem pescoço mas não tem cabeça?', 'A garrafa', 0, false, NOW(), NOW()),
  ('Sobe quando a chuva desce?', 'O guarda-chuva', 0, false, NOW(), NOW()),
  ('Tem asa mas não voa?', 'A xícara', 0, false, NOW(), NOW()),
  ('Enche uma casa mas não enche uma mão?', 'O botão', 0, false, NOW(), NOW()),
  ('Tem cabeça mas não pensa?', 'O alho', 0, false, NOW(), NOW()),
  ('Quebra quando se fala?', 'O segredo', 0, false, NOW(), NOW()),
  ('Tem linha mas não é carretel?', 'O caderno', 0, false, NOW(), NOW()),
  ('Entre na água mas não se molha?', 'A sombra', 0, false, NOW(), NOW()),
  ('Vive batendo e nunca apanha?', 'O coração', 0, false, NOW(), NOW()),
  ('Tem pernas mas não anda?', 'A mesa', 0, false, NOW(), NOW()),
  ('Corre a casa toda e depois dorme num canto?', 'A vassoura', 0, false, NOW(), NOW()),
  ('Respira mas não tem pulmão?', 'O acordeon (sanfona)', 0, false, NOW(), NOW()),
  ('Tem cinco dedos mas não tem unha?', 'A luva', 0, false, NOW(), NOW()),
  ('Está sempre no meio da rua?', 'A letra U', 0, false, NOW(), NOW()),
  ('Tem chapéu mas não tem cabeça, tem boca mas não fala?', 'O cogumelo', 0, false, NOW(), NOW())
ON CONFLICT DO NOTHING;

-- 6. Verificar inserção
SELECT COUNT(*) as total_piadas FROM jokes WHERE deleted = false;

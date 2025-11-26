-- Script de configuração do banco Supabase
-- Execute este script no SQL Editor do Supabase Dashboard
-- URL: https://[SEU_PROJETO].supabase.co

-- 1. Criar tabela jokes
CREATE TABLE IF NOT EXISTS jokes (
  id INTEGER PRIMARY KEY,
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

-- 4. Criar policy para leitura pública
CREATE POLICY "Permitir leitura pública de piadas"
  ON jokes FOR SELECT
  USING (true);

-- 5. REMOVIDO: Não permitir atualização por usuários
-- view_count é local, apenas admin pode atualizar piadas no servidor

-- 6. Inserir piadas iniciais
INSERT INTO jokes (id, question, answer, view_count, deleted, created_at, updated_at) VALUES
  (1, 'O que é o que é?' || E'\n' || 'Tem coroa, mas não é rei, tem escama, mas não é peixe?', 'O abacaxi', 0, false, NOW(), NOW()),
  (2, 'O que é o que é?' || E'\n' || 'Cai em pé e corre deitado?', 'A chuva', 0, false, NOW(), NOW()),
  (3, 'O que é o que é?' || E'\n' || 'Tem dentes mas não morde?', 'O garfo', 0, false, NOW(), NOW()),
  (4, 'O que é o que é?' || E'\n' || 'Quanto mais se perde, maior fica?', 'O buraco', 0, false, NOW(), NOW()),
  (5, 'O que é o que é?' || E'\n' || 'É surdo e mudo, mas conta tudo?', 'O livro', 0, false, NOW(), NOW()),
  (6, 'O que é o que é?' || E'\n' || 'Tem pescoço mas não tem cabeça?', 'A garrafa', 0, false, NOW(), NOW()),
  (7, 'O que é o que é?' || E'\n' || 'Sobe quando a chuva desce?', 'O guarda-chuva', 0, false, NOW(), NOW()),
  (8, 'O que é o que é?' || E'\n' || 'Tem asa mas não voa?', 'A xícara', 0, false, NOW(), NOW()),
  (9, 'O que é o que é?' || E'\n' || 'Enche uma casa mas não enche uma mão?', 'O botão', 0, false, NOW(), NOW()),
  (10, 'O que é o que é?' || E'\n' || 'Tem cabeça mas não pensa?', 'O alho', 0, false, NOW(), NOW()),
  (11, 'O que é o que é?' || E'\n' || 'Quebra quando se fala?', 'O segredo', 0, false, NOW(), NOW()),
  (12, 'O que é o que é?' || E'\n' || 'Tem linha mas não é carretel?', 'O caderno', 0, false, NOW(), NOW()),
  (13, 'O que é o que é?' || E'\n' || 'Entre na água mas não se molha?', 'A sombra', 0, false, NOW(), NOW()),
  (14, 'O que é o que é?' || E'\n' || 'Vive batendo e nunca apanha?', 'O coração', 0, false, NOW(), NOW()),
  (15, 'O que é o que é?' || E'\n' || 'Tem pernas mas não anda?', 'A mesa', 0, false, NOW(), NOW()),
  (16, 'O que é o que é?' || E'\n' || 'Corre a casa toda e depois dorme num canto?', 'A vassoura', 0, false, NOW(), NOW()),
  (17, 'O que é o que é?' || E'\n' || 'Respira mas não tem pulmão?', 'O acordeon (sanfona)', 0, false, NOW(), NOW()),
  (18, 'O que é o que é?' || E'\n' || 'Tem cinco dedos mas não tem unha?', 'A luva', 0, false, NOW(), NOW()),
  (19, 'O que é o que é?' || E'\n' || 'Está sempre no meio da rua?', 'A letra U', 0, false, NOW(), NOW()),
  (20, 'O que é o que é?' || E'\n' || 'Tem chapéu mas não tem cabeça, tem boca mas não fala?', 'O cogumelo', 0, false, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- 7. Verificar inserção
SELECT COUNT(*) as total_piadas FROM jokes WHERE deleted = false;

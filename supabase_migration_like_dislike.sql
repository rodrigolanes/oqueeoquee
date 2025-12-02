-- Migração: Adiciona campos de like/dislike na tabela jokes
-- Execute este script no SQL Editor do Supabase Dashboard

-- 1. Adicionar campos like_count e dislike_count
ALTER TABLE jokes 
ADD COLUMN IF NOT EXISTS like_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN IF NOT EXISTS dislike_count INTEGER NOT NULL DEFAULT 0;

-- 2. Criar índices para otimização (opcional, útil para analytics futuros)
CREATE INDEX IF NOT EXISTS idx_jokes_like_count ON jokes(like_count DESC);
CREATE INDEX IF NOT EXISTS idx_jokes_dislike_count ON jokes(dislike_count DESC);

-- 3. Criar função RPC para incrementar like de forma atômica
CREATE OR REPLACE FUNCTION increment_like(joke_id INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE jokes
  SET like_count = like_count + 1,
      updated_at = NOW()
  WHERE id = joke_id;
END;
$$ LANGUAGE plpgsql;

-- 4. Criar função RPC para incrementar dislike de forma atômica
CREATE OR REPLACE FUNCTION increment_dislike(joke_id INTEGER)
RETURNS VOID AS $$
BEGIN
  UPDATE jokes
  SET dislike_count = dislike_count + 1,
      updated_at = NOW()
  WHERE id = joke_id;
END;
$$ LANGUAGE plpgsql;

-- 5. Verificar alteração
SELECT id, question, like_count, dislike_count 
FROM jokes 
LIMIT 5;

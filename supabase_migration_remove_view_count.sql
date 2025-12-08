-- Migração para remover view_count do Supabase
-- Execute este script no SQL Editor do Supabase Dashboard
-- 
-- ⚠️ IMPORTANTE: Esta migração remove a coluna view_count do Supabase
-- 
-- MOTIVO: view_count agora é gerenciado APENAS LOCALMENTE (SharedPreferences)
-- - Cada usuário tem seu próprio progresso no aparelho
-- - O app usa viewCount para controlar quais piadas já foram vistas
-- - Garante que todas as piadas sejam mostradas antes de repetir
-- - NÃO sincroniza com Supabase (permanece local)
--
-- Esta migração é segura: não afeta os dados existentes (question/answer)

-- 1. Remover índice de view_count
DROP INDEX IF EXISTS idx_jokes_view_count;

-- 2. Remover coluna view_count da tabela jokes
ALTER TABLE jokes DROP COLUMN IF EXISTS view_count;

-- 3. Verificar estrutura da tabela (deve não ter view_count)
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'jokes' 
ORDER BY ordinal_position;

-- 4. Confirmar que piadas não foram afetadas
SELECT COUNT(*) as total_piadas FROM jokes WHERE deleted = false;

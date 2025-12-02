# 📋 Instruções de Migração - Like/Dislike v5.4.0

## 🎯 Objetivo
Adicionar sistema de avaliação de piadas com like e dislike no banco de dados Supabase.

## ⚠️ PRÉ-REQUISITOS
- Acesso ao dashboard do Supabase
- Projeto "O que é o que é" ativo
- Permissões de administrador no banco de dados

## 📝 PASSO A PASSO

### 1. Acessar o SQL Editor do Supabase
1. Acesse https://supabase.com/dashboard
2. Selecione o projeto "oqueeoquee"
3. No menu lateral, clique em "SQL Editor"
4. Clique em "+ New query"

### 2. Executar Script de Migração
1. Abra o arquivo `supabase_migration_like_dislike.sql` na raiz do projeto
2. Copie todo o conteúdo do arquivo
3. Cole no SQL Editor do Supabase
4. Clique em "Run" (ou pressione Ctrl+Enter)

### 3. Verificar Migração
Execute a seguinte query para verificar:

```sql
-- Verificar se colunas foram criadas
SELECT column_name, data_type, column_default 
FROM information_schema.columns 
WHERE table_name = 'jokes' 
  AND column_name IN ('like_count', 'dislike_count');

-- Verificar se índices foram criados
SELECT indexname FROM pg_indexes 
WHERE tablename = 'jokes' 
  AND indexname IN ('idx_jokes_like_count', 'idx_jokes_dislike_count');

-- Verificar se RPC functions foram criadas
SELECT routine_name FROM information_schema.routines 
WHERE routine_type = 'FUNCTION' 
  AND routine_name IN ('increment_like', 'increment_dislike');
```

**Resultado esperado:**
- 2 colunas: `like_count` e `dislike_count` (INTEGER DEFAULT 0)
- 2 índices: `idx_jokes_like_count` e `idx_jokes_dislike_count`
- 2 funções: `increment_like` e `increment_dislike`

### 4. Testar RPC Functions
Execute os testes abaixo para garantir que as funções estão funcionando:

```sql
-- Testar increment_like
SELECT increment_like(1);  -- Deve incrementar like_count da piada com id=1

-- Verificar resultado
SELECT id, question, like_count, dislike_count FROM jokes WHERE id = 1;

-- Testar increment_dislike
SELECT increment_dislike(1);  -- Deve incrementar dislike_count da piada com id=1

-- Verificar resultado
SELECT id, question, like_count, dislike_count FROM jokes WHERE id = 1;
```

## 📊 Schema Alterado

### Tabela `jokes` - Novas Colunas
| Coluna | Tipo | Default | Descrição |
|--------|------|---------|-----------|
| `like_count` | INTEGER | 0 | Contador de likes |
| `dislike_count` | INTEGER | 0 | Contador de dislikes |

### Índices Criados
- `idx_jokes_like_count` - Índice descendente em `like_count` (para futuras queries de ranking)
- `idx_jokes_dislike_count` - Índice descendente em `dislike_count`

### RPC Functions
- `increment_like(joke_id INTEGER)` - Incrementa atomicamente `like_count` + atualiza `updated_at`
- `increment_dislike(joke_id INTEGER)` - Incrementa atomicamente `dislike_count` + atualiza `updated_at`

## 🔄 Rollback (se necessário)
Caso precise reverter a migração:

```sql
-- Remover RPC functions
DROP FUNCTION IF EXISTS increment_like(INTEGER);
DROP FUNCTION IF EXISTS increment_dislike(INTEGER);

-- Remover índices
DROP INDEX IF EXISTS idx_jokes_like_count;
DROP INDEX IF EXISTS idx_jokes_dislike_count;

-- Remover colunas
ALTER TABLE jokes DROP COLUMN IF EXISTS like_count;
ALTER TABLE jokes DROP COLUMN IF EXISTS dislike_count;
```

## ✅ Checklist de Conclusão
- [ ] Script de migração executado sem erros
- [ ] Colunas `like_count` e `dislike_count` criadas
- [ ] Índices `idx_jokes_like_count` e `idx_jokes_dislike_count` criados
- [ ] RPC functions `increment_like` e `increment_dislike` criadas
- [ ] Testes de RPC functions executados com sucesso
- [ ] Aplicação Flutter testada com novos botões de like/dislike

## 🚀 Próximos Passos
Após completar a migração:
1. Merge da branch `feature/like-dislike` na `main`
2. Build de release: `flutter build apk --release`
3. Deploy da versão 5.4.0+30

## 📞 Suporte
Em caso de dúvidas ou erros durante a migração, verifique:
- Logs do SQL Editor no Supabase
- Políticas RLS não estão bloqueando alterações
- Usuário tem permissões adequadas

---

**Data da Migração:** 1 de Dezembro de 2025  
**Versão:** 5.4.0 (Build 30)  
**Autor:** GitHub Copilot

# Configuração do Supabase

## 🔧 Passos de Configuração

### 1. Acessar o Dashboard do Supabase
Acesse: https://[SEU_PROJETO].supabase.co (ou encontre na página de projetos do Supabase)

### 2. Executar o Script SQL
1. No menu lateral, clique em **SQL Editor**
2. Clique em **New Query**
3. Copie todo o conteúdo do arquivo `supabase_setup.sql`
4. Cole no editor e clique em **RUN**

### 3. Verificar Tabela Criada
1. No menu lateral, clique em **Table Editor**
2. Verifique se a tabela `jokes` aparece
3. Clique na tabela e confirme que existem 20 registros

### 4. Testar o App
```bash
# Instalar dependências
flutter pub get

# Executar app
flutter run
```

## 📊 Estrutura da Tabela

```sql
CREATE TABLE jokes (
  id INTEGER PRIMARY KEY,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  view_count INTEGER NOT NULL DEFAULT 0,
  deleted BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL
);
```

## 🔐 Segurança (RLS - Row Level Security)

### Policies Configuradas:
- ✅ **Leitura pública**: Qualquer usuário pode ler piadas
- ❌ **Atualização**: Bloqueado (view_count é apenas local)
- ❌ **Inserção/Deleção**: Bloqueado para usuários anônimos (apenas admin)

### ⚠️ IMPORTANTE: view_count é LOCAL
- O contador de visualizações **NÃO é sincronizado** com Supabase
- Cada usuário tem seu próprio progresso no aparelho
- Apenas question/answer são sincronizados do servidor

## 🔄 Sincronização

O app usa uma estratégia híbrida com **view_count local**:

1. **Cache Local**: `SharedPreferences` armazena piadas e contadores localmente
2. **Sincronização**: Na inicialização, busca piadas do Supabase
3. **Merge Inteligente**: 
   - Atualiza question/answer se servidor estiver mais recente
   - **PRESERVA view_count local** (não sincroniza)
   - Cada usuário tem seu próprio progresso
4. **Offline-First**: Funciona sem internet, busca atualizações quando conectado

### Fluxo de Sincronização:
```
Inicialização
    ↓
Carrega cache local (SharedPreferences)
    ↓
Busca piadas remotas (Supabase)
    ↓
Mescla dados (atualiza apenas question/answer)
    ↓
PRESERVA view_count local de cada piada
    ↓
Salva localmente
    ↓
Exibe piada
```

### Fluxo de Atualização:
```
Usuário clica "Próxima"
    ↓
Incrementa view_count localmente
    ↓
Salva APENAS no SharedPreferences
    ↓
(NÃO sincroniza com Supabase)
    ↓
Cada usuário mantém seu próprio progresso
```

## 📝 Credenciais

**⚠️ IMPORTANTE**: As credenciais do Supabase estão em `lib/config/supabase_config.dart` (não commitado).

Para configurar em novo ambiente:
1. Copie `lib/config/supabase_config.example.dart` para `lib/config/supabase_config.dart`
2. Preencha com suas credenciais do Supabase
3. O arquivo já está no `.gitignore` e não será commitado

**Project URL**: `https://[SEU_PROJETO].supabase.co`
**API Key (anon)**: Disponível no dashboard do Supabase

## 🧪 Testando a Integração

### Verificar Sincronização de Piadas:
1. Abra o app e visualize algumas piadas
2. Verifique que novas piadas do servidor aparecem automaticamente
3. **Importante**: view_count permanece local, não aparece no Supabase

### Teste Offline:
1. Ative modo avião no celular
2. Abra o app (deve funcionar com cache local)
3. Visualize piadas (contador incrementa localmente)
4. Desative modo avião
5. Feche e abra o app (busca piadas novas, mantém contadores locais)

### Teste Multi-Usuário:
1. Instale o app em dois aparelhos diferentes
2. Visualize piadas no aparelho A
3. Verifique que o aparelho B tem contadores zerados (independentes)
4. Cada usuário tem seu próprio progresso local

## 🐛 Troubleshooting

### Erro: "Failed to fetch jokes"
- Verifique conexão com internet
- Confirme que o script SQL foi executado
- Verifique se RLS está habilitado com policies corretas

### Piadas não sincronizam
- **NORMAL**: view_count NÃO sincroniza (é local por design)
- Se piadas novas não aparecem:
  - Verifique logs: `debugPrint('Erro ao sincronizar com Supabase: $e')`
  - Confirme que a tabela existe e RLS está ativo
  - Teste query manual no SQL Editor:
    ```sql
    SELECT * FROM jokes WHERE deleted = false ORDER BY id;
    ```

### App não inicia
- Rode `flutter pub get`
- Limpe build: `flutter clean`
- Verifique se `WidgetsFlutterBinding.ensureInitialized()` está no main

## 📈 Próximos Passos

### Funcionalidades Futuras:
- [ ] Adicionar autenticação de usuários
- [ ] Piadas favoritas por usuário
- [ ] Categorias de piadas
- [ ] Sistema de rating/likes
- [ ] Adicionar novas piadas via app (admin)

### Melhorias de Sincronização:
- [ ] Implementar retry automático em caso de falha
- [ ] Fila de sincronização para operações offline
- [ ] Indicador visual de status de sincronização
- [ ] Resolver conflitos de merge mais sofisticados

---

**Última atualização**: 2025-11-25

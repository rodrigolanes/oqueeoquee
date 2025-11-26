# 🔒 Segurança - Arquivos Sensíveis

## ⚠️ IMPORTANTE: Arquivos que NÃO devem ser commitados

### ✅ Já estão protegidos no `.gitignore`:

1. **Keystore e Credenciais Android**
   - `android/key.properties`
   - `android/app/upload-keystore.jks`
   - Qualquer arquivo `.jks` ou `.keystore`

2. **Configuração do Supabase**
   - `lib/config/supabase_config.dart`

3. **Build e Cache**
   - `.gradle/`
   - `build/`
   - `.dart_tool/`
   - `android/local.properties`

### 📋 Arquivos de Template (podem ser commitados):
- `lib/config/supabase_config.example.dart` ✅
- Documentação em `play_store/` ✅
- Workflows do GitHub Actions ✅

### 🔐 Verificação antes de commit:

```bash
# Ver status incluindo arquivos ignorados
git status --ignored

# Verificar se não há senhas nos arquivos staged
git diff --cached | grep -i "password\|secret\|key"

# Ver o que será commitado
git diff --cached
```

### 🚀 Para novo desenvolvedor/máquina:

1. Clone o repositório
2. Copie `supabase_config.example.dart` → `supabase_config.dart`
3. Preencha com credenciais do Supabase
4. Configure keystore (se for buildar release):
   - Criar/copiar `android/key.properties`
   - Copiar `android/app/upload-keystore.jks`

### 📝 Credenciais no GitHub Actions:

As credenciais são armazenadas como **Secrets** no GitHub:
- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_PASSWORD`
- `KEY_ALIAS`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

Nunca commite esses valores!

### ✅ Checklist Antes de Commit:

- [ ] `git status --ignored` não mostra arquivos sensíveis não-ignorados
- [ ] Nenhum arquivo com senha/key/secret será commitado
- [ ] `supabase_config.dart` está no .gitignore
- [ ] `key.properties` está no .gitignore
- [ ] Keystore (.jks) está no .gitignore
- [ ] Documentação não contém credenciais reais

### 🔍 Se já commitou acidentalmente:

```bash
# Remover arquivo do histórico (cuidado!)
git rm --cached lib/config/supabase_config.dart

# Ou se já foi pushed, precisa reescrever histórico:
git filter-branch --tree-filter 'rm -f lib/config/supabase_config.dart' HEAD
git push --force

# Melhor: Rotacionar credenciais comprometidas!
```

---

**Regra de Ouro**: Se tem senha, key, token ou secret → NUNCA commitar!

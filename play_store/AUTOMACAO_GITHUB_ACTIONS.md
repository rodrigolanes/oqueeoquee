# Notas de Versão - Automação com GitHub Actions

## 📋 Estrutura de Arquivos para Notas de Versão

### Opção 1: Arquivo Único (Simples)
Crie: `RELEASE_NOTES.txt` na raiz do projeto

```txt
• Correções de bugs e melhorias de desempenho
• Nova interface mais moderna
• Adição de 5 novas piadas
• Sistema de sincronização com Supabase
```

### Opção 2: Diretório por Idioma (Recomendado pela Google)
Estrutura:
```
play_store/
  whatsnew/
    pt-BR.txt    # Português brasileiro
    en-US.txt    # Inglês (opcional)
    es-ES.txt    # Espanhol (opcional)
```

Conteúdo de `pt-BR.txt` (máximo 500 caracteres):
```txt
🎉 Novidades da versão 5.0.1

✨ Novo sistema de sincronização com nuvem
🎲 Seleção aleatória de piadas
📊 Barra de progresso melhorada
🐛 Correções de bugs
💾 Contador de visualizações agora é local

Divirta-se!
```

### Opção 3: Extrair do RELEASES.md (Automático)
O workflow já está configurado para ler do `RELEASES.md` automaticamente!

---

## 🔐 Configuração de Secrets no GitHub

Você precisa adicionar estes secrets no GitHub:

### 1. Keystore em Base64
```bash
# No PowerShell
$bytes = [System.IO.File]::ReadAllBytes("android\app\upload-keystore.jks")
[Convert]::ToBase64String($bytes) | Set-Clipboard
```

No GitHub: Settings → Secrets → Actions → New repository secret
- Nome: `KEYSTORE_BASE64`
- Valor: Cole do clipboard

### 2. Credenciais do Keystore
- `KEYSTORE_PASSWORD` = `[SUA_SENHA]`
- `KEY_PASSWORD` = `[SUA_SENHA]`
- `KEY_ALIAS` = `oqueeoquee`

**Nota**: Estas são suas credenciais reais que você configurou ao criar o keystore.

### 3. Credenciais do Supabase
- `SUPABASE_URL` = URL do seu projeto Supabase
- `SUPABASE_ANON_KEY` = Chave pública anon do Supabase

**Como encontrar**:
1. Acesse: https://supabase.com/dashboard
2. Selecione seu projeto
3. Settings → API
4. Project URL e anon/public key

### 4. Service Account da Google Play

#### Passo 1: Criar Service Account
1. Acesse: https://play.google.com/console
2. Setup → API access
3. Create new service account
4. Siga o link para Google Cloud Console
5. Create Service Account:
   - Nome: `github-actions-deploy`
   - Role: `Service Account User`
6. Create Key → JSON
7. Baixe o arquivo JSON

#### Passo 2: Adicionar ao GitHub
- Nome: `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- Valor: Cole o conteúdo do arquivo JSON

#### Passo 3: Conceder Permissões no Play Console

⚠️ **IMPORTANTE**: Você só pode fazer isso DEPOIS de criar o app na Play Console!

1. **Acesse Play Console**: https://play.google.com/console
2. **Selecione seu app** (ou crie um novo se ainda não existe)
3. **Navegue**: Menu lateral → **Setup** → **API access**
4. **Localize a service account** que você criou na lista
5. **Clique em "Grant access"** ou **"Manage Play Console permissions"**
6. **Aba "App permissions"**:
   - Selecione seu app na lista
   - Marque as permissões:
     - ✅ **Releases** → "View app information and download bulk reports (read-only)"
     - ✅ **Releases** → "Create and edit draft releases"
     - ✅ **Releases** → "Release to testing tracks"
     - ✅ **Releases** → "Release to production"
7. **Aba "Account permissions"** (opcional):
   - Deixe desmarcado se só quer deploy
8. **Clique em "Invite user"** ou **"Apply"**

**Se não aparecer a opção de Grant access:**
- Você precisa primeiro **criar o app** na Play Console
- Ir em "All apps" → "Create app"
- Preencher informações básicas
- Depois voltar para API access

---

## 🚀 Como Usar

### Método 1: Criar Tag (Automático)
```bash
# Atualizar versão no pubspec.yaml primeiro
# version: 5.0.1+16

# Commit e tag
git add .
git commit -m "Release v5.0.1"
git tag v5.0.1
git push origin main --tags
```

### Método 2: Manualmente no GitHub
1. Acesse: Actions → Deploy to Google Play Store
2. Clique em "Run workflow"
3. Selecione a branch
4. Run workflow

---

## 📝 Formatos Aceitos de Notas de Versão

### Formato Simples (500 caracteres max)
```txt
Nova versão com melhorias e correções de bugs.
```

### Formato com Emojis (Recomendado)
```txt
🎉 Versão 5.0.1

✨ Novidades:
• Sistema de sincronização
• Seleção aleatória
• Interface melhorada

🐛 Correções:
• Bug ao resetar contador
• Melhorias de desempenho
```

### Formato Detalhado
```txt
O que há de novo:

NOVIDADES
- Integração com Supabase para sincronização
- Algoritmo de seleção aleatória de piadas
- Nova tela de debug para desenvolvedores

MELHORIAS
- Interface mais fluida e moderna
- Animações suavizadas
- Barra de progresso mais precisa

CORREÇÕES
- Corrigido bug ao completar todas as piadas
- Ajustado contador de visualizações
- Melhorado tratamento de erros
```

---

## 📊 Trilhas de Distribuição

Configure no workflow qual trilha usar:

```yaml
track: internal   # Teste interno (100 testadores)
track: alpha      # Alpha (fechado)
track: beta       # Beta (aberto)
track: production # Produção (público)
```

### Estratégia Recomendada:
1. **Internal**: Teste você mesmo
2. **Alpha**: Família/amigos próximos
3. **Beta**: Testadores públicos voluntários
4. **Production**: Lançamento oficial

---

## 🔄 Fluxo Completo de Release

```bash
# 1. Atualizar código e versão
vim lib/main.dart
vim pubspec.yaml  # version: 5.0.1+16

# 2. Criar notas de versão
vim play_store/whatsnew/pt-BR.txt

# 3. Atualizar RELEASES.md
vim RELEASES.md

# 4. Commit e tag
git add .
git commit -m "Release v5.0.1 - Integração Supabase"
git tag v5.0.1
git push origin main --tags

# 5. GitHub Actions faz o resto:
#    - Build do app
#    - Upload para Play Store
#    - Publica notas de versão
#    - Cria release no GitHub
```

---

## ✅ Checklist de Setup

- [ ] Criar `play_store/whatsnew/pt-BR.txt`
- [ ] Adicionar `KEYSTORE_BASE64` nos secrets
- [ ] Adicionar `KEYSTORE_PASSWORD` nos secrets
- [ ] Adicionar `KEY_PASSWORD` nos secrets
- [ ] Adicionar `KEY_ALIAS` nos secrets
- [ ] Adicionar `SUPABASE_URL` nos secrets
- [ ] Adicionar `SUPABASE_ANON_KEY` nos secrets
- [ ] Criar Service Account no Google Cloud
- [ ] Adicionar `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` nos secrets
- [ ] Conceder permissões no Play Console
- [ ] Testar workflow manualmente
- [ ] Criar primeira tag e fazer push

---

## 🐛 Troubleshooting

### Erro: "Keystore not found"
- Verifique se `KEYSTORE_BASE64` está correto
- Teste localmente: `echo $KEYSTORE_BASE64 | base64 -d > test.jks`

### Erro: "Service account not authorized"
- Verifique permissões no Play Console
- Aguarde até 24h para propagação

### Erro: "Version code already exists"
- Incremente o build number no `pubspec.yaml`
- Exemplo: `5.0.1+16` → `5.0.1+17`

---

**Pronto!** Agora toda vez que criar uma tag, o app é automaticamente publicado na Play Store com as notas de versão! 🚀

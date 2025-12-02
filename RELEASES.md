# Histórico de Releases - O que é o que é?

## 📋 Versões

### [5.4.0] - 2025-12-01 (Build 30)
#### 👍👎 Sistema de Avaliação de Piadas

**Implementação de like/dislike com rastreamento de engajamento**

#### ✨ Novidades
- Botões de "Gostei" 👍 e "Não gostei" 👎 após revelar resposta
- Sistema de votação mutualmente exclusivo (like OU dislike)
- Botões desaparecem automaticamente após votação
- Botões reaparecem ao ver a mesma piada novamente
- Feedback visual com animação de escala ao clicar
- Dados de engajamento enviados ao Supabase

#### 🛠️ Melhorias Técnicas
- `google_mobile_ads` atualizado de v5.1.0 para v6.0.0
- Campos `like_count` e `dislike_count` adicionados ao banco de dados
- RPC functions `increment_like` e `increment_dislike` no Supabase (atomicidade)
- Use cases `LikeJoke` e `DislikeJoke` seguindo Clean Architecture
- Rastreamento de votos em memória via `Set<int> _votedJokes` (session-based)
- Fallback de incremento se RPC não disponível
- Widget `_VoteButton` reutilizável com animações
- Testes unitários atualizados para novos use cases

#### 📊 Dados
- Contadores de like/dislike armazenados remotamente
- Incrementos atômicos via PostgreSQL RPC
- Índices em `like_count` e `dislike_count` para futuras queries
- Nenhuma persistência local (usuário pode votar novamente após reiniciar app)

#### 🎨 UX
- Botões aparecem apenas após resposta revelada
- UI limpa sem contadores visíveis
- Animação suave de feedback ao votar
- Cores semânticas (verde para like, vermelho para dislike)

---

### [5.3.0] - 2025-11-29 (Build 29)
#### 💰 Monetização com Google AdMob

**Integração de anúncios publicitários**

#### ✨ Novidades
- Banner publicitário na parte inferior da tela principal
- Integração completa com Google AdMob SDK
- Anúncios exibidos de forma não intrusiva
- Carregamento assíncrono dos banners

#### 🛠️ Melhorias Técnicas
- Dependência `google_mobile_ads: ^5.1.0` adicionada
- Configuração centralizada em `AdMobConfig`
- Auto-switch entre test/production ad units via `kDebugMode`
- Graceful degradation (app funciona mesmo se ad falhar)
- Dispose automático de ads ao sair da tela
- Workflow CI/CD atualizado para criar `admob_config.dart`
- Configuração de Java 17 para suprimir warnings de build

#### 📱 UX
- Banner 320x50 posicionado na parte inferior
- Não interfere na navegação ou interação com piadas
- Feedback visual de carregamento via logs

---

### [5.2.2] - 2025-11-28 (Build 28)
#### 🐛 Correção Crítica

**Correção de bug que impedia criação de piadas**

#### 🐛 Correções
- Corrigido erro "id não pode ser nulo" ao criar novas piadas
- Ajustado schema do banco de dados para usar auto-incremento (SERIAL)
- Melhorado tratamento de erros com logs detalhados

#### 🛠️ Melhorias Técnicas
- Script de setup do Supabase atualizado com SERIAL PRIMARY KEY
- Políticas RLS com DROP IF EXISTS para evitar duplicação
- INSERT de piadas sem especificar ID (auto-gerado pelo banco)

---

### [5.2.0] - 2025-11-28 (Build 26)
#### 🔒 Segurança e Nova Identidade Visual

**Controle de acesso e design renovado**

#### ✨ Novidades
- Sistema de autorização baseado em dispositivo para funções administrativas
- Apenas dispositivos autorizados podem criar/editar piadas
- Menu administrativo oculto para usuários não autorizados
- Nova paleta de cores verde (substituindo amarelo)

#### 🛠️ Melhorias
- Interface mais agradável com tons de verde
- AppBar com visual modernizado
- Gradiente verde suave no background
- Tela de debug acessível a todos via 3 toques no título

#### 🔒 Segurança
- DeviceUtils com whitelist de dispositivos autorizados
- Verificação de permissão em múltiplas camadas (menu, tela, ação)
- Proteção contra acesso não autorizado às funcionalidades CRUD

#### 📱 UX
- Menu drawer visível apenas para administradores
- Feedback claro sobre restrições de acesso
- Design mais harmonioso e agradável aos olhos

---

### [5.1.1] - 2025-11-27 (Build 22)
#### 🔧 Correções e Melhorias

**Ajustes de estabilidade e usabilidade**

#### 🛠️ Melhorias
- Tela de debug agora acessível por toque triplo no título (easter egg)
- Removido botão de debug visível na AppBar
- Migração automática com reset completo do banco local na primeira execução
- Padronização do campo view_count (removido condicional de compatibilidade)

#### 🐛 Correções
- Garantido reset completo ao atualizar da versão anterior
- Melhorada compatibilidade entre versões
- Campo view_count agora usa apenas snake_case consistentemente

#### 📦 Arquitetura
- Database migration versão 2 com limpeza total de dados locais
- Simplificação do código de deserialização de piadas
- UI mais limpa sem elementos de debug visíveis

---

### [5.1.0] - 2025-11-27 (Build 21)
#### 🌟 Sincronização na Nuvem

**Piadas agora vêm direto da nuvem!**

#### ✨ Novidades
- Sistema de sincronização com Supabase
- Piadas atualizadas automaticamente do servidor
- Novas piadas adicionadas sem precisar atualizar o app
- Contador de progresso aprimorado (começa em 1)
- Sistema de migração de dados robusto

#### 🛠️ Melhorias
- Sincronização em background mais confiável
- Detecção e atualização automática de piadas modificadas
- Melhor tratamento de erros de rede
- Performance otimizada na sincronização

#### 🐛 Correções
- Resolvido crash ao atualizar da versão anterior
- Corrigido problema de dados corrompidos após update
- Melhorada estabilidade geral do app
- Sincronização de status de piadas (ativas/deletadas)

#### 📦 Arquitetura
- Integração completa com Supabase
- Sistema offline-first (funciona sem internet)
- Migração automática de estrutura de dados
- Remoção de piadas hardcoded (agora 100% na nuvem)

---

### [5.0.0] - 2025-11-15 (Build 14)
#### 🎉 Renovação Completa

**Nova versão com modernização total do código e interface!**

#### ✨ Novidades
- Migração completa para Flutter 3.35.6
- Nova interface com Material Design 3
- Animações fluidas e modernas
- Barra de progresso visual
- Código refatorado e otimizado
- Arquitetura MVC limpa

#### 🛠️ Melhorias
- Performance otimizada
- Compatibilidade com Android 14
- Gradle 8.7 e AGP 8.6.0
- Kotlin 2.1.0
- Suporte a Java 21

#### 📦 Estrutura
- Separação clara de Models, Controllers e Views
- Persistência com SharedPreferences
- Sistema de contadores inteligente aprimorado

---

### [4.0.0] - 2011-07-12 (Build 13)
#### Última versão anterior

**Versão clássica do aplicativo**

#### Características
- 20 piadas de "O que é o que é?"
- Sistema básico de visualização
- Interface simples
- Compatibilidade com Android mais antigos

---

## 📝 Notas de Migração 4.0 → 5.0

### Melhorias na Experiência do Usuário
- **Antes**: Interface básica sem feedback visual
- **Agora**: Animações suaves, feedback tátil e visual imediato

### Melhorias Técnicas
- **Antes**: Código legado sem separação de responsabilidades
- **Agora**: Arquitetura MVC moderna, código limpo e manutenível

### Performance
- **Antes**: Carregamento sem otimização
- **Agora**: Carregamento otimizado, transições instantâneas

### Persistência
- **Antes**: Dados básicos salvos
- **Agora**: Sistema completo de contadores com estado persistente

---

## 🔮 Próximas Versões Planejadas

### [5.4.0] - Em Planejamento
- Modo escuro
- Compartilhamento de piadas
- Mais categorias de piadas

### [6.0.0] - Visão de Longo Prazo
- Suporte a múltiplos idiomas
- Sistema de conquistas
- Ranking de usuários

---

## 📊 Estatísticas

| Versão | Build | Data       | Downloads | Nota Média |
|--------|-------|------------|-----------|------------|
| 5.3.0  | 29    | 2025-11-29 | -         | -          |
| 5.2.2  | 28    | 2025-11-28 | -         | -          |
| 5.2.0  | 26    | 2025-11-28 | -         | -          |
| 5.1.1  | 22    | 2025-11-27 | -         | -          |
| 5.1.0  | 21    | 2025-11-27 | -         | -          |
| 5.0.0  | 14    | 2025-11-15 | -         | -          |
| 4.0.0  | 13    | 2011-07-12 | -         | -          |

---

## 🐛 Correções de Bugs

### Versão 5.2.2
- Corrigido erro de criação de piadas no banco de dados
- Melhorado tratamento de erros de backend
- Schema do banco atualizado com auto-incremento

### Versão 5.1.1
- Reset automático de dados locais ao atualizar
- Removido condicional desnecessário em view_count
- Easter egg para debug (toque triplo no título)
- Interface mais limpa sem elementos de debug visíveis

### Versão 5.1.0
- Corrigido crash ao atualizar app da Play Store
- Corrigido dados corrompidos entre versões
- Melhorada sincronização com servidor
- Corrigido campo deleted não sincronizando
- Tratamento robusto de erros de parsing JSON

### Versão 5.0.0
- Corrigido problema de compatibilidade com Android 14
- Corrigido crash ao rotacionar tela
- Corrigido persistência de dados em segundo plano
- Melhorado gerenciamento de memória

---

## 🙏 Agradecimentos

Obrigado a todos que usaram as versões anteriores do app! 

Esta nova versão é uma renovação completa pensada para trazer a melhor experiência possível.

---

**Desenvolvido com ❤️ por Arnapio**

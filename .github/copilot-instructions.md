# Copilot Instructions - O que é o que é?

## 📱 Contexto do Projeto

Este é um aplicativo Flutter de piadas "O que é o que é?" (adivinhas brasileiras). É uma renovação de um app clássico de 2011, agora modernizado para Flutter 3.x.

## 🎯 Objetivo

Fornecer uma experiência divertida e simples de piadas, com um sistema inteligente que garante que o usuário veja todas as piadas antes de repetir.

## 🏗️ Arquitetura

### Clean Architecture (3 Camadas)
- **Domain** (`lib/features/jokes/domain/`): Entidades e contratos (Joke, JokeRepository)
- **Data** (`lib/features/jokes/data/`): Implementações e fontes de dados (JokeRepositoryImpl, Supabase, Local)
- **Presentation** (`lib/features/jokes/presentation/`): UI e providers (JokeProvider, HomeScreen)
- **Utils** (`lib/utils/`): Utilitários (DeviceUtils para autorização)

### Princípios de Código (SOLID)
1. **Single Responsibility**: Cada classe tem uma única responsabilidade
2. **Open/Closed**: Aberto para extensão, fechado para modificação
3. **Liskov Substitution**: Interfaces bem definidas (repositories)
4. **Interface Segregation**: Contratos específicos
5. **Dependency Inversion**: Dependências através de abstrações
6. **Imutabilidade**: Use `final` sempre que possível
7. **Estado gerenciado**: Provider com ChangeNotifier

## 🔧 Padrões de Código

### Nomenclatura
- Classes: PascalCase (ex: `JokeController`)
- Arquivos: snake_case (ex: `joke_controller.dart`)
- Variáveis/Métodos: camelCase (ex: `currentJoke`)
- Constantes: lowerCamelCase (ex: `const defaultPadding`)
- Privados: prefixo `_` (ex: `_initialize()`)

### Formatação
- Use `const` construtores sempre que possível
- Prefira `final` sobre `var`
- Evite `dynamic`, especifique tipos
- Use trailing commas para melhor formatação

### Estado e Lifecycle
- Controllers estendem `ChangeNotifier`
- Use `notifyListeners()` após mudanças de estado
- Dispose controllers em `dispose()`
- Inicialize dados assíncronos no construtor ou `initState`

## 📦 Dependências

### Principais
- `flutter`: SDK principal
- `supabase_flutter`: Backend e sincronização na nuvem
- `shared_preferences`: Cache local
- `device_info_plus`: Identificação de dispositivo
- `provider`: Gerenciamento de estado
- `get_it`: Service locator (DI)
- `dartz`: Programação funcional (Either)
- `equatable`: Comparação de objetos

### Dev Dependencies
- `flutter_lints`: Análise estática
- `flutter_test`: Testes unitários
- `mockito`: Mocks para testes
- `build_runner`: Geração de código

## 🎨 UI/UX Guidelines

### Cores
- **Primary**: Green (`Colors.green`)
- **Accent**: Blue (`Colors.blue`)
- **Background**: Gradiente verde (green.shade400 → green.shade50)
- **Cards**: Branco com elevação
- **Error**: Orange (`Colors.orange`)

### Componentes
- Use Material Design 3
- Preferir componentes nativos do Flutter
- Animações suaves (300-500ms)
- Feedback visual imediato

### Responsividade
- Use `MediaQuery` para tamanhos de tela
- Padding responsivo com porcentagens
- Tamanhos de fonte escaláveis

## 💾 Persistência

### Supabase (Remoto)
- Tabela: `jokes`
- Sincronização automática
- CRUD completo para admins autorizados
- Campos: `id`, `question`, `answer`, `view_count`, `is_active`, `created_at`, `updated_at`

### SharedPreferences (Cache Local)
- Chave principal: `'jokes'`
- Formato: JSON serializado
- Modelo: `List<Joke>` com contadores
- Sincronização com remoto no carregamento

### Estrutura de Dados
```dart
{
  "id": int,
  "question": String,
  "answer": String,
  "viewCount": int
}
```

## 🧪 Testing

### Ao adicionar features
1. Teste no emulador Android
2. Teste rotação de tela
3. Teste persistência (fechar/abrir app)
4. Teste todos os estados (carregando, vazio, erro)

## 🚀 Build e Deploy

### Debug
```bash
flutter run
```

### Release
```bash
flutter build apk --release
flutter build appbundle --release
```

### Versioning
- Siga Semantic Versioning (MAJOR.MINOR.PATCH)
- Atualize `pubspec.yaml` e `RELEASES.md`
- Build number sempre incrementa

## 🔒 Segurança

### Autorização por Dispositivo
- **DeviceUtils**: Gerencia whitelist de dispositivos autorizados
- **allowedDeviceIds**: Lista de IDs Android permitidos para admin
- **Funções admin**: Criar, editar e deletar piadas
- **Menu oculto**: Drawer só aparece para dispositivos autorizados
- **Verificação em camadas**: Menu → Tela → Ação

### Arquivos Sensíveis (NÃO COMMITAR)
- `android/key.properties`
- `android/app/*.jks`
- `android/app/*.keystore`
- `android/local.properties`
- `.env` (credenciais Supabase)

### Verificar antes de commit
```bash
git status
# Verificar se não há arquivos sensíveis
```

## 📝 Convenções de Commit

### Formato
```
tipo(escopo): descrição curta

Descrição detalhada (opcional)
```

### Tipos
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Tarefas gerais

### Exemplos
```
feat(jokes): adiciona 10 novas piadas
fix(persistence): corrige bug ao salvar contadores
docs(readme): atualiza instruções de instalação
```

## 🐛 Debugging

### Comum
- Use `print()` para debug rápido
- Use `debugPrint()` para outputs grandes
- Use `assert()` para validações em debug
- Use Flutter DevTools para profiling

### SharedPreferences
Para verificar dados salvos:
```dart
final prefs = await SharedPreferences.getInstance();
print(prefs.getString('jokes'));
```

## 🎯 Quando Adicionar Novas Piadas

1. Adicione em `lib/data/jokes_data.dart`
2. Mantenha formato consistente
3. ID único e sequencial
4. Pergunta clara, resposta curta
5. Teste persistência após adicionar

## 🔄 Workflow de Desenvolvimento

1. **Feature Branch**: Crie branch da `main`
2. **Desenvolvimento**: Implemente a feature
3. **Teste**: Teste manualmente
4. **Commit**: Commit com mensagem descritiva
5. **Push**: Push para GitHub
6. **PR**: Crie Pull Request se trabalho em equipe

## 📱 Plataformas

### Atual
- ✅ Android

### Futuro
- [ ] iOS
- [ ] Web
- [ ] Desktop

## 🎓 Boas Práticas Flutter

1. **Widget Tree**: Mantenha hierarquia clara
2. **Build Methods**: Extraia widgets grandes em métodos/classes
3. **Keys**: Use quando necessário para otimização
4. **Async**: Use `async/await` corretamente
5. **Error Handling**: Sempre trate erros assíncronos

## 💡 Dicas para Copilot

- Este é um app **simples e focado** - não over-engineer
- Priorize **legibilidade** sobre performance prematura
- Mantenha a **experiência do usuário** fluida
- **Persistência** é crítica - teste sempre
- Código deve ser **auto-explicativo** com comentários mínimos

## 🎨 Design Tokens (Futuro)

Quando adicionar features complexas, considere:
- Theme customizado
- Tokens de cor centralizados
- Espaçamentos consistentes
- Tipografia padronizada

---

**Última atualização**: 2025-11-28
**Versão do app**: 5.2.0 (Build 26)

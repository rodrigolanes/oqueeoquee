# O que é o que é? 🤔😄

[![Flutter](https://img.shields.io/badge/Flutter-5.2.0-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build](https://img.shields.io/badge/Build-26-brightgreen.svg)]()

Aplicação Flutter de piadas "O que é o que é?" com sistema inteligente de contadores para garantir que você veja todas as piadas antes de repetir!

## 📱 Sobre o App

"O que é o que é?" é uma aplicação divertida que traz as clássicas adivinhas brasileiras. Com um sistema inteligente de contadores, o app garante que você verá todas as piadas antes de repetir qualquer uma.

### ✨ Funcionalidades

- 🎭 **Piadas na nuvem** - sincronização automática com Supabase
- 🎯 **Sistema inteligente de contadores** - nunca repete uma piada não vista
- 💾 **Persistência híbrida** - cache local + sincronização remota
- 📊 **Barra de progresso** - veja quantas piadas já foram vistas
- 🎨 **Interface moderna** - design verde limpo e intuitivo com Material Design 3
- ✨ **Animações suaves** - transições fluidas entre piadas
- 🔄 **Reset de contadores** - comece do zero quando quiser
- 📱 **Responsivo** - funciona em diferentes tamanhos de tela
- 🔒 **Sistema de autorização** - controle de acesso por dispositivo para funções admin
- ➕ **CRUD completo** - criar, editar e deletar piadas (apenas admins)
- 🐛 **Tela de debug** - acessível via 3 toques no título

### 🎮 Como Funciona

1. **Abertura**: O app carrega automaticamente com uma piada na tela
2. **Interação**: Toque na piada para revelar a resposta
3. **Navegação**: Clique em "Próxima Piada" para avançar
4. **Algoritmo inteligente**: 
   - O sistema incrementa o contador da piada atual
   - Busca automaticamente a próxima piada com menor contador
   - Quando todas tiverem contador >= 1, continua priorizando as menos vistas
5. **Progresso**: Acompanhe quantas piadas já foram vistas na barra superior

## 🛠️ Tecnologias

- **Flutter 3.x** - Framework multiplataforma
- **Dart 3.x** - Linguagem de programação
- **Supabase** - Backend as a Service (PostgreSQL)
- **Provider** - Gerenciamento de estado
- **GetIt** - Service Locator (Dependency Injection)
- **Dartz** - Programação funcional (Either monad)
- **SharedPreferences** - Cache local
- **Device Info Plus** - Identificação de dispositivo
- **Material Design 3** - Design moderno e responsivo
- **Clean Architecture** - Separação em camadas (Domain/Data/Presentation)

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                                    # Ponto de entrada + DI
├── features/
│   └── jokes/
│       ├── domain/
│       │   ├── entities/
│       │   │   └── joke.dart                   # Entidade Joke
│       │   └── repositories/
│       │       └── joke_repository.dart        # Contrato do repositório
│       ├── data/
│       │   ├── models/
│       │   │   └── joke_model.dart            # Modelo para serialização
│       │   ├── datasources/
│       │   │   ├── joke_remote_datasource.dart # Supabase
│       │   │   └── joke_local_datasource.dart  # SharedPreferences
│       │   └── repositories/
│       │       └── joke_repository_impl.dart   # Implementação
│       └── presentation/
│           ├── providers/
│           │   ├── joke_provider.dart          # Estado de piadas
│           │   └── admin_provider.dart         # Estado admin
│           └── screens/
│               ├── home_screen.dart            # Tela principal
│               ├── create_joke_screen.dart     # Criar piada
│               ├── edit_joke_screen.dart       # Editar piada
│               └── debug_screen.dart           # Debug
├── utils/
│   └── device_utils.dart                       # Autorização por dispositivo
└── core/
    └── error/
        └── failures.dart                       # Tratamento de erros
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK instalado (versão 3.0+)
- Android Studio ou VS Code
- Emulador Android ou dispositivo físico

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/oqueeoquee.git

# Entre no diretório
cd oqueeoquee

# Instale as dependências
flutter pub get

# Execute o app
flutter run
```

### Build de Produção

```bash
# APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release
```

## 📋 Exemplo de Piadas

- "Tem coroa, mas não é rei, tem escama, mas não é peixe?" → **O abacaxi**
- "Cai em pé e corre deitado?" → **A chuva**
- "Tem dentes mas não morde?" → **O garfo**
- E muitas mais!

## 🎯 Roadmap Futuro

- [ ] Adicionar mais piadas
- [ ] Categorias de piadas
- [ ] Modo de quiz/desafio
- [ ] Compartilhamento de piadas
- [ ] Piadas favoritas
- [ ] Modo escuro
- [ ] Suporte a múltiplos idiomas

## 📝 Versão Atual

**Versão 5.2.0 (Build 26)**

Esta é uma renovação completa da aplicação original, trazendo:
- Código modernizado para Flutter 3.x com Clean Architecture
- Backend Supabase com sincronização na nuvem
- Sistema de autorização por dispositivo
- Nova interface verde com Material Design 3
- Melhorias na experiência do usuário
- Performance otimizada
- CRUD completo de piadas (apenas admins)
- 105 testes unitários

Veja o [histórico completo de releases](RELEASES.md).

## 👨‍💻 Desenvolvimento

### Arquitetura

O app utiliza **Clean Architecture** com 3 camadas:
- **Domain**: Entidades puras e contratos (Joke, JokeRepository)
- **Data**: Implementações e fontes de dados (Supabase + SharedPreferences)
- **Presentation**: UI e gerenciamento de estado (Provider + Screens)

Princípios SOLID aplicados em todo o código.

### Persistência

Utiliza arquitetura híbrida:

**Supabase (Remoto)**:
- Fonte única da verdade
- Piadas sincronizadas automaticamente
- CRUD completo para admins
- PostgreSQL robusto

**SharedPreferences (Cache Local)**:
- Armazena piadas localmente
- Contador de visualizações
- Funciona offline
- Sincroniza com remoto quando online

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para:
1. Fazer um Fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abrir um Pull Request

## 📧 Contato

**Arnapio** - [br.com.arnapio](https://br.com.arnapio)

---

Feito com ❤️ e Flutter

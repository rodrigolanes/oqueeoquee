# O que é o que é? 🤔😄

[![Flutter](https://img.shields.io/badge/Flutter-5.0.0-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://www.android.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Aplicação Flutter de piadas "O que é o que é?" com sistema inteligente de contadores para garantir que você veja todas as piadas antes de repetir!

## 📱 Sobre o App

"O que é o que é?" é uma aplicação divertida que traz as clássicas adivinhas brasileiras. Com um sistema inteligente de contadores, o app garante que você verá todas as piadas antes de repetir qualquer uma.

### ✨ Funcionalidades

- 🎭 **20 piadas clássicas** de "O que é o que é?"
- 🎯 **Sistema inteligente de contadores** - nunca repete uma piada não vista
- 💾 **Persistência de dados** - mantém seu progresso entre sessões
- 📊 **Barra de progresso** - veja quantas piadas já foram vistas
- 🎨 **Interface moderna** - design limpo e intuitivo com Material Design
- ✨ **Animações suaves** - transições fluidas entre piadas
- 🔄 **Reset de contadores** - comece do zero quando quiser
- 📱 **Responsivo** - funciona em diferentes tamanhos de tela

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

- **Flutter 3.35.6** - Framework multiplataforma
- **Dart 3.9.2** - Linguagem de programação
- **SharedPreferences** - Persistência local de dados
- **Material Design 3** - Design moderno e responsivo

## 📦 Estrutura do Projeto

```
lib/
├── main.dart                    # Ponto de entrada
├── models/
│   └── joke.dart               # Modelo de dados da piada
├── data/
│   └── jokes_data.dart         # Lista de 20 piadas fixas
├── controllers/
│   └── joke_controller.dart    # Lógica de negócio e persistência
└── screens/
    └── home_screen.dart        # Tela principal
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

**Versão 5.0.0 (Build 14)**

Esta é uma renovação completa da aplicação original, trazendo:
- Código modernizado para Flutter 3.x
- Nova interface com Material Design 3
- Melhorias na experiência do usuário
- Performance otimizada

Veja o [histórico completo de releases](RELEASES.md).

## 👨‍💻 Desenvolvimento

### Arquitetura

O app utiliza uma arquitetura simples e eficiente:
- **Model**: Representação dos dados (Joke)
- **Controller**: Lógica de negócio (JokeController)
- **View**: Interface do usuário (HomeScreen)

### Persistência

Utiliza `SharedPreferences` para armazenar:
- Lista completa de piadas
- Contador de visualizações de cada piada
- Estado atual da aplicação

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

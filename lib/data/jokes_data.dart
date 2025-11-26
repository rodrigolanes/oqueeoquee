import '../models/joke.dart';

class JokesData {
  static List<Joke> getInitialJokes() {
    final now = DateTime.now();
    return [
      Joke(
        id: 1,
        question:
            "O que é o que é?\nTem coroa, mas não é rei, tem escama, mas não é peixe?",
        answer: "O abacaxi",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 2,
        question: "O que é o que é?\nCai em pé e corre deitado?",
        answer: "A chuva",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 3,
        question: "O que é o que é?\nTem dentes mas não morde?",
        answer: "O garfo",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 4,
        question: "O que é o que é?\nQuanto mais se perde, maior fica?",
        answer: "O buraco",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 5,
        question: "O que é o que é?\nÉ surdo e mudo, mas conta tudo?",
        answer: "O livro",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 6,
        question: "O que é o que é?\nTem pescoço mas não tem cabeça?",
        answer: "A garrafa",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 7,
        question: "O que é o que é?\nSobe quando a chuva desce?",
        answer: "O guarda-chuva",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 8,
        question: "O que é o que é?\nTem asa mas não voa?",
        answer: "A xícara",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 9,
        question: "O que é o que é?\nEnche uma casa mas não enche uma mão?",
        answer: "O botão",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 10,
        question: "O que é o que é?\nTem cabeça mas não pensa?",
        answer: "O alho",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 11,
        question: "O que é o que é?\nQuebra quando se fala?",
        answer: "O segredo",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 12,
        question: "O que é o que é?\nTem linha mas não é carretel?",
        answer: "O caderno",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 13,
        question: "O que é o que é?\nEntra na água mas não se molha?",
        answer: "A sombra",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 14,
        question: "O que é o que é?\nVive batendo e nunca apanha?",
        answer: "O coração",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 15,
        question: "O que é o que é?\nTem pernas mas não anda?",
        answer: "A mesa",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 16,
        question:
            "O que é o que é?\nCorre a casa toda e depois dorme num canto?",
        answer: "A vassoura",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 17,
        question: "O que é o que é?\nRespira mas não tem pulmão?",
        answer: "O acordeon (sanfona)",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 18,
        question: "O que é o que é?\nTem cinco dedos mas não tem unha?",
        answer: "A luva",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 19,
        question: "O que é o que é?\nEstá sempre no meio da rua?",
        answer: "A letra U",
        createdAt: now,
        updatedAt: now,
      ),
      Joke(
        id: 20,
        question:
            "O que é o que é?\nTem chapéu mas não tem cabeça, tem boca mas não fala?",
        answer: "O cogumelo",
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

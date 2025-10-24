import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart' as words; // import s aliasom
import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  // Generátor náhodných čísel (pre výber cieľového slova)
  final random = Random.secure();

  // Zoznam všetkých slov dĺžky 5 znakov
  List<String> totalWords = [];

  // Dočasné vstupy používateľa (aktuálny riadok v mriežke)
  List<String> rowInputs = [];

  // Zoznam vyradených písmen (písmená, ktoré nie sú v cieľovom slove)
  List<String> excludedLetters = [];

  // Herný panel – obsahuje 30 prvkov typu Wordle (6 riadkov × 5 písmen)
  List<Wordle> hurdleBoard = [];

  // Cieľové (náhodne vybrané) slovo
  String targetWord = '';

  int count = 0;
  int index = 0; // sleduje pozíciu v mriežke
  final lettersPerRow = 5;

  bool get isValidWord => totalWords.contains(rowInputs.join('').toLowerCase());

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool wins = false;

  void checkAnswer() {
    final input = rowInputs.join('');
    if (targetWord == input) {
      wins = true;
    } else {
      _markLettersOnBoard();
      if (attempts < totalAttempts) {
        _goToNextRow();
      }
    }
  }

  // Pridanie písmena do aktuálneho vstupu
  inputLetter(String letter) {
    if (count < lettersPerRow) {
      rowInputs.add(letter);
      // vloženie písmena do príslušnej pozície v hernej doske
      hurdleBoard[index] = Wordle(letter: letter);

      // inkrementácia počítadiel
      count++;
      index++;

      // aktualizácia UI
      notifyListeners();
    }
  }

  void deleteLetter() {
    // odstránenie písmena z listu rowInputs
    if (rowInputs.isNotEmpty) {
      rowInputs.removeAt(rowInputs.length - 1);
    }

    // odstránenie písmena z hurdleBoard
    if (count > 0) {
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
    }
    notifyListeners(); // aktualizácia UI
  }

  void _markLettersOnBoard() {
    for (int i = 0; i < hurdleBoard.length; i++) {
      if (hurdleBoard[i].letter.isNotEmpty &&
          targetWord.contains(hurdleBoard[i].letter)) {
        hurdleBoard[i].existsInTarget = true;
      } else if (hurdleBoard[i].letter.isNotEmpty &&
          !targetWord.contains(hurdleBoard[i].letter)) {
        hurdleBoard[i].doesNotExistInTarget = true;
        excludedLetters.add(hurdleBoard[i].letter);
      }
    }
    notifyListeners();
  }

  final int totalAttempts = 6;
  int attempts = 0;

  bool get noAttemptsLeft => totalAttempts == attempts;

  void _goToNextRow() {
    attempts++;
    count = 0;
    rowInputs.clear();
  }

  void reset() {
    count = 0;
    index = 0;
    rowInputs.clear();
    hurdleBoard.clear();
    excludedLetters.clear();
    attempts = 0;
    wins = false;
    targetWord = '';
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }


  init() {
    // Získame všetky slová z balíčka english_words a vyfiltrujeme len tie, ktoré majú 5 znakov
    totalWords = words.all.where((element) => element.length == 5).toList();

    // Vygenerujeme herný panel (30 prázdnych políčok)
    generateBoard();

    // Vyberieme náhodné cieľové slovo
    generateRandomWord();
  }

  // ------------------------- GENEROVANIE MRIEŽKY -------------------------
  generateBoard() {
    hurdleBoard = List.generate(30, (index) => Wordle(letter: ''));
  }

  // ------------------------- GENEROVANIE CIEĽOVÉHO SLOVA -------------------------
  generateRandomWord() {
    // Získame cieľové slovo a uložíme ho vo veľkých písmenách
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
    print(targetWord);
  }
}
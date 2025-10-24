import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'hurdle_provider.dart';
import 'wordle_view.dart';
import 'keyboard_view.dart';
import 'helper_functions.dart';
import 'package:flutter/services.dart'; // needed for LogicalKeyboardKey

class WordHurdlePage extends StatefulWidget {
  const WordHurdlePage({super.key});

  @override
  State<WordHurdlePage> createState() => _WordHurdlePageState();
}

class _WordHurdlePageState extends State<WordHurdlePage> {

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  // 3️⃣ Dispose it in dispose
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  _handleInput(HurdleProvider provider) {
    // Overenie platnosti slova
    if (!provider.isValidWord) {
      showMsg(context, 'Not a word in my dictionary');
      return;
    }

    // Kontrola, či je slovo kompletné (5 písmen)
    if (provider.shouldCheckForAnswer) {
      provider.checkAnswer();
    }

    // Výhra – zhoduje sa s targetWord
    if (provider.wins) {
      showResult(
        context: context,
        title: 'You Win!!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () {
          Navigator.pop(context);
          provider.reset();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );

      // Prehra – pokusy sú vyčerpané
    } else if (provider.noAttemptsLeft) {
      showResult(
        context: context,
        title: 'You lost!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () {
          Navigator.pop(context);
          provider.reset();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    // Získame inštanciu provideru a spustíme inicializáciu
    Provider.of<HurdleProvider>(context, listen: false).init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HurdleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Word Hurdle'), centerTitle: true),
      body:  KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            final key = event.logicalKey.keyLabel.toUpperCase();

            // Only letters
            if (RegExp(r'^[A-Z]$').hasMatch(key)) {
              provider.inputLetter(key);
            }
            // Backspace
            else if (event.logicalKey == LogicalKeyboardKey.backspace) {
              provider.deleteLetter();
            }
            // Enter
            else if (event.logicalKey == LogicalKeyboardKey.enter) {
              _handleInput(provider);
            }
          }
        },
        child: Center(
          child: Column(
            children: [
              // Expanded zabezpečí, že GridView zaberie dostupný priestor
              Expanded(
                child: SizedBox(
                  width:
                  MediaQuery.of(context).size.width *
                      0.70, // 70 % šírky obrazovky
                  child: Consumer<HurdleProvider>(
                    builder: (context, provider, child) => GridView.builder(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5, // 5 stĺpcov = 5 písmen v riadku
                        mainAxisSpacing: 4, // vertikálne medzery
                        crossAxisSpacing: 4, // horizontálne medzery
                      ),
                      itemCount: provider.hurdleBoard.length,
                      itemBuilder: (context, index) {
                        // Každý prvok v mriežke = jeden objekt Wordle
                        final wordle = provider.hurdleBoard[index];
                        return WordleView(wordle: wordle);
                      },
                    ),
                  ),
                ),
              ),
              Consumer<HurdleProvider>(
                builder: (context, provider, child) => KeyboardView(
                  excludedLetters: provider.excludedLetters,
                  onPressed: (value) {
                    provider.inputLetter(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<HurdleProvider>(
                  builder: (context, provider, child) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          provider.deleteLetter();
                        },
                        child: const Text('DELETE'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _handleInput(provider);
                        },
                        child: const Text('SUBMIT'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}




// Tento model reprezentuje jedno políčko v mriežke (jedno písmeno).
// Každé písmeno má svoje vlastnosti – napr. či sa nachádza v cieľovom slove.

class Wordle {
  String letter; // samotné písmeno
  bool existsInTarget; // či sa nachádza v cieľovom slove
  bool doesNotExistInTarget;    // či sa v cieľovom slove nenachádza

  // Konštruktor – letter je povinné, ostatné majú predvolené hodnoty false
  Wordle({
    required this.letter,
    this.existsInTarget = false,
    this.doesNotExistInTarget = false,
  });
}
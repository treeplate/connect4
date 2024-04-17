import 'ais.dart';
import 'core.dart';

void main() {
  playTwoPlayerGame(Game.connect4);
}

GameState playTwoPlayerGame(Game g) {
  print("Playing ${g.name}");
  Ai a = Ai(g);
  Ai b = Ai(g);
  RunningGame g2 = initializeGame(g, [a, b]);
  while (g2.isActive) {
    a.play(g2);
    if (g2.isActive) b.play(g2);
  }
  print("Result of playing ${g.name}:\n${g2.state}");
  return g2.state;
}

RunningGame initializeGame(Game g, List<Ai> ais) {
  return RunningGame(g, ais);
}

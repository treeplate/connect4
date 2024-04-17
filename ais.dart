import 'core.dart';

class Ai {
  final Game g;

  Ai(this.g);

  String toString() => '${g.name} player';

  void play(RunningGame g2) {
    assert(g == Game.connect4);
    var column = (g2.state as Connect4GameState)
        .columns
        .lastIndexWhere((element) => element.length < 6);
    assert(column != -1, 'there is no empty column');
    Connect4Move move = Connect4Move(column);
    print('Playing \'$move\'');
    g2.move(this, move);
  }
}

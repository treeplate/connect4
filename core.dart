import 'ais.dart';

enum Game { connect4 }

class RunningGame {
  RunningGame(this.game, this._ais)
      : _state = generateStartingGameState(game, _ais);

  final Game game;

  bool get isActive => !state.gameOver;
  GameState _state;
  GameState get state => _state;

  final List<Ai> _ais;
  int _player = 0;

  void move(Ai ai, Move move) {
    if (_ais[_player] != ai) {
      throw StateError("$ai played when it was not their turn!");
    }
    if (move.game != game) {
      throw FormatException(
          "$ai played $move, which is not a ${game.name[0].toUpperCase() + game.name.substring(1)}Move!");
    }
    switch (game) {
      case Game.connect4:
        _state = (_state as Connect4GameState).goInColumn(
            (move as Connect4Move).column, _player == 0 ? true : false);
        break;
    }
    _player = (_player + 1) % 2;
  }
}

GameState generateStartingGameState(Game game, List<Ai> ais) {
  switch (game) {
    case Game.connect4:
      return Connect4GameState(
          {true: ais.first, false: ais.last}, List.generate(7, (index) => []));
  }
}

abstract class Move {
  Game get game;
}

class Connect4Move extends Move {
  Connect4Move(this.column);
  String toString() => "go in column $column";
  @override
  Game get game => Game.connect4;
  final int column;
}

abstract class GameState {
  Ai? get winner;
  bool get gameOver;
}

enum Direction {
  horizontal,
  vertical,
  diagonal1,
  diagonal2,
}

final class Connect4GameState extends GameState {
  Connect4GameState(this._players, this._columns,
      [this.winner = null, this.gameOver = false]);

  @override
  final Ai? winner;
  final bool gameOver;
  final Map<bool, Ai> _players;
  late final List<List<bool>> _columns;
  List<List<bool>> get columns => _columns.map((x) => x.toList()).toList();

  GameState goInColumn(int column, bool player) {
    assert(!gameOver);
    if (column < 0 || column > 6) {
      throw FormatException(
          "${_players[player]} tried to insert piece into nonexistent column $column\n$this");
    }
    if (columns[column].length > 5) {
      throw StateError(
          "${_players[player]}'s piece cannot fit in column $column");
    }
    List<List<bool>> c = columns;
    int row = c[column].length;
    c[column].add(player);
    bool gameOver2 = false;
    Ai? winner2 = null;
    winCheck:
    {
      bool checkWin(Direction dir, bool negate) {
        int tempRow = row;
        int tempColumn = column;
        int i = 0;
        while (true) {
          i++;
          switch (dir) {
            case Direction.horizontal:
              negate ? tempRow-- : tempRow++;
            case Direction.vertical:
              negate ? tempColumn-- : tempColumn++;
            case Direction.diagonal1:
              negate ? tempRow-- : tempRow++;
              negate ? tempColumn-- : tempColumn++;
            case Direction.diagonal2:
              negate ? tempRow-- : tempRow++;
              negate ? tempColumn++ : tempColumn--;
          }
          if (i > 3) {
            gameOver2 = true;
            winner2 = _players[player];
            return true;
          }
          if (tempRow < 0 || tempColumn < 0 || tempRow > 5 || tempColumn > 6)
            break;
          if(c[tempColumn].length <= tempRow) break;
          if (c[tempColumn][tempRow] != player) break;
        }
        return false;
      }
      for (Direction dir in Direction.values) {
        if(checkWin(dir, true)) break winCheck;
        if(checkWin(dir, false)) break winCheck;
      }
      if (c.expand((e) => e).length == 6 * 7) {
        gameOver2 = true;
      } else {
        assert(c.expand((e) => e).length < 6 * 7);
      }
    }
    return Connect4GameState(_players, c, winner2, gameOver2);
  }

  String toString() {
    StringBuffer buf = StringBuffer();
    int i = 5;
    while (i >= 0) {
      for (List<bool> col in columns) {
        if (col.length <= i) {
          buf.write('.');
        } else {
          buf.write(col[i] ? 'O' : 'X');
        }
      }
      buf.writeln();
      i--;
    }
    return buf.toString();
  }
}

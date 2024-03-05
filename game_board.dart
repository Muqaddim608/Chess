import 'package:flutter/material.dart';
import 'package:semproject/components/piece.dart';
import 'package:semproject/components/square.dart';
import 'package:semproject/values/colors.dart';

import 'components/dead_piece.dart';
import 'helper/helpers_methods.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});


  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
{
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesTaken = [];

  List<ChessPiece> blackPiecesTaken = [];

  bool isWhiteTurn = true;

  List<int> whiteKingPosition = [7,4];

  List<int> blackKingPosition = [0,4];

  bool checkStatus = false;

  void pieceSelected(int row, int col)
  {
    setState(()
    {
      if(selectedPiece == null && board[row][col] != null){
        if(board[row][col]!.isWhite == isWhiteTurn)
        {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      }else if(selectedPiece == null ||
          (board[row][col] != null && board[row][col]!.isWhite == selectedPiece!.isWhite) )
      {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if(selectedPiece !=null && validMoves.any((element) => element[0]==row && element[1]==col))
        {
          movePiece(row, col);
        }
      validMoves = calculateRealValidMoves(selectedRow,selectedCol,selectedPiece,true);
    });
  }

  List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation)
  {
    List<List<int>> realValidMove = [];
    List<List<int>> candidateMove = calculateRawValidMoves(row, col, piece);


    if(piece!.type == ChessPieceType.king) {
      if (checkSimulation) {
        for (var move in candidateMove) {
          int endRow = move[0];
          int endCol = move[1];
          if (simulatedMoveIsSafe(piece!, row, col, endRow, endCol)) {
            realValidMove.add(move);
          }
        }
      } else {
        realValidMove = candidateMove;
      }
    }else {
      realValidMove = candidateMove;
    }
    return realValidMove;
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece)
  {
    List<List<int>> candidateMoves = [];
    if(piece == null)
      {
        return [];
      }


    int direction = piece!.isWhite? -1:1;

    switch (piece.type)
    {
      case ChessPieceType.pawn:
        if(isInBoard(row+direction, col)&& board[row+direction][col]==null)
        {
          candidateMoves.add([row+direction,col]);
        }
        if((row==1 && !piece.isWhite)||(row==6 && piece.isWhite))
        {
          if(isInBoard(row+2 * direction, col)&& board[row+2*direction][col]==null && board[row+direction][col]==null)
          {
            candidateMoves.add([row+2*direction,col]);
          }
        }
        if(isInBoard(row+direction, col-1) &&
            board[row+direction][col-1]!=null &&
            board[row+direction][col-1]!.isWhite != piece.isWhite)
        {
          candidateMoves.add([row+direction,col-1]);
        }
        if(isInBoard(row+direction, col+1) &&
            board[row+direction][col+1]!=null &&
            board[row+direction][col+1]!.isWhite != piece.isWhite)
        {
          candidateMoves.add([row+direction,col+1]);
        }
        break;
      case ChessPieceType.rock:
        var directions = [
          [1,0],
          [-1,0],
          [0,1],
          [0,-1]
        ];
        for(var direction in directions)
        {
          var i = 1;
          while(true)
          {
            var newRow = row +i * direction[0];
            var newCol = col+ i * direction[1];
            if(!isInBoard(newRow, newCol))
              {
                break;
              }
            if(board[newRow][newCol]!=null)
            {
              if(board[newRow][newCol]!.isWhite != piece.isWhite)
              {
                candidateMoves.add([newRow,newCol]);
              }
              break;
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }
        }

        break;
      case ChessPieceType.knight:
        var knightMoves =
        [
          [-2,-1],
          [-2,1],
          [-1,-2],
          [-1,2],
          [1,-2],
          [1,2],
          [2,-1],
          [2,1]
        ];
        for (var move in knightMoves)
        {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if(!isInBoard(newRow, newCol)){
            continue;
          }
          if(board[newRow][newCol]!=null)
          {
            if(board[newRow][newCol]!.isWhite != piece.isWhite)
            {
              candidateMoves.add([newRow,newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow,newCol]);
        }
        break;
      case ChessPieceType.bishop:
        var directions =
        [
          [1,1],
          [-1,1],
          [1,-1],
          [-1,-1],

        ];
        for (var direction in directions)
          {
            var i = 1;
            while(true)
              {
                var newRow = row + i * direction[0];
                var newCol = col + i * direction[1];
                if(!isInBoard(newRow, newCol))
                {
                  break;
                }
                if(board[newRow][newCol]!=null)
                {
                  if(board[newRow][newCol]!.isWhite != piece.isWhite)
                  {
                    candidateMoves.add([newRow,newCol]);
                  }
                  break;
                }
                candidateMoves.add([newRow,newCol]);
                i++;
              }
          }
        break;
      case ChessPieceType.queen:
        var directions =
        [
          [1,1],
          [-1,1],
          [1,-1],
          [-1,-1],
          [1,0],
          [-1,0],
          [0,1],
          [0,-1]
        ];
        for (var direction in directions)
        {
          var i = 1;
          while(true)
          {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if(!isInBoard(newRow, newCol))
            {
              break;
            }
            if(board[newRow][newCol]!=null)
            {
              if(board[newRow][newCol]!.isWhite != piece.isWhite)
              {
                candidateMoves.add([newRow,newCol]);
              }
              break;
            }
            candidateMoves.add([newRow,newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [1, 1],
          [-1, 1],
          [1, -1],
          [-1, -1],
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1]
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (isInBoard(newRow, newCol) &&
              (board[newRow][newCol] == null ||
                  board[newRow][newCol]!.isWhite != piece.isWhite)) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;
      default:
    }
    return candidateMoves;
  }

  bool isKingIncheck(bool isWhiteKing)
  {
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;
    for(int i = 0; i< 8 ; i++)
      {
        for(int j = 0; j<8;j++)
          {
            if(board[i][j]==null||board[i][j]!.isWhite == isWhiteKing)
            {
              continue;
            }

            List<List<int>> pieceValidMove = calculateRealValidMoves(i, j, board[i][j],false);
            if(pieceValidMove.any((move) => move[0]== kingPosition[0] && move[1]==kingPosition[1]))
              {
                return true;
              }

          }
      }
    return false;
  }

  void movePiece(int newRow, int newCol)
  {
    if(board[newRow][newCol]!=null)
    {
      var capturedPiece = board[newRow][newCol];
      if(capturedPiece!.isWhite)
      {
        whitePiecesTaken.add(capturedPiece);
      }else {
        blackPiecesTaken.add(capturedPiece);
      }
    }
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if(selectedPiece!.isWhite)
      {
        whiteKingPosition = [newRow,newCol];
      }
    else
      {
        blackKingPosition = [newRow,newCol];
      }

    if(isKingIncheck(!isWhiteTurn))
    {
      checkStatus = true;
    }else
      {
        checkStatus = false;
      }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if(isCheckMate(!isWhiteTurn))
    {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: const Text("Check Mate"),
        actions: [
          TextButton(onPressed: resetGame, child: const Text("Play Again!!")),
        ],
      ));
    }

    isWhiteTurn = !isWhiteTurn;
  }

  bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol, int endRow, int endCol)
  {
    ChessPiece? orignalDestinationPiece = board[endRow][endCol];
    List<int>? originalKingPosition;
    if(piece.type == ChessPieceType.king)
      {
        originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
      }

    if(piece.isWhite)
      {
        whiteKingPosition = [endRow,endCol];
      }else
      {
        blackKingPosition = [endRow,endCol];
      }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingIncheck = isKingIncheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = orignalDestinationPiece;

    if(piece.type == ChessPieceType.king)
      {
        if(piece.isWhite)
          {
            whiteKingPosition = originalKingPosition!;
          }else
            {
              blackKingPosition = originalKingPosition!;
            }
      }
    return !kingIncheck;
  }

  bool isCheckMate(bool isWhiteKing)
  {
    if(!isKingIncheck(isWhiteKing))
      {
        return false;
      }
    for (int i = 0; i<8;i++)
      {
        for(int j=0;j<8;j++)
          {
            if(board[i][j] == null || board[i][j]!.isWhite != isWhiteKing)
            {
              continue;
            }

            List<List<int>> pieceValidMoves = calculateRealValidMoves(i, j, board[i][j], true);
            if(pieceValidMoves.isNotEmpty)
              {
                return false;
              }
          }
      }
    return true;
  }


  @override
  void initState(){
    super.initState();
    _initalizeBoard();
  }

  void _initalizeBoard()
  {
    List<List<ChessPiece?>> newBoard = List.generate(8, (index) => List.generate(8,(index) => null));




    //pawn
    for(int i=0;i<8;i++)
      {
        newBoard[1][i] = ChessPiece(
            type: ChessPieceType.pawn,
            isWhite: false,
            imagePath: 'lib/assets/pawn.png'
        );
      }
    for(int i=0;i<8;i++)
    {
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'lib/assets/pawn.png'
      );
    }
    //rock
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rock,
        isWhite: false,
        imagePath: 'lib/assets/rock.png'
    );
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rock,
        isWhite: false,
        imagePath: 'lib/assets/rock.png'
    );
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rock,
        isWhite: true,
        imagePath: 'lib/assets/rock.png'
    );
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rock,
        isWhite: true,
        imagePath: 'lib/assets/rock.png'
    );
    //knight
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/assets/knight.png'
    );
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'lib/assets/knight.png'
    );
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/assets/knight.png'
    );
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'lib/assets/knight.png'
    );
    //bishop
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/assets/bishop.png'
    );
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'lib/assets/bishop.png'
    );
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/assets/bishop.png'
    );
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'lib/assets/bishop.png'
    );
    //queen
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'lib/assets/queen.png'
    );
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'lib/assets/queen.png'
    );
    //king
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'lib/assets/king.png'
    );
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'lib/assets/king.png'
    );

    board = newBoard;
  }

  void resetGame()
  {
    Navigator.pop(context);
    _GameBoardState();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition = [7,4];
    blackKingPosition = [0,4];
    setState(() {

    });
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [

          Expanded(child: GridView.builder(
              itemCount: whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,index)=> DeadPiece(imagePath: whitePiecesTaken[index].imagePath,isWhite: true,))),
          Expanded(
            flex: 3,
            child: GridView.builder(itemCount: 8*8 ,physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8)
                , itemBuilder: (context, index)
                {
                  int row = index ~/8;
                  int col = index %8;
            
                  bool isSelected = selectedRow == row && selectedCol == col;
            
                  bool isValidMove = false;
                  for (var position in validMoves)
                  {
                    if (position[0]==row && position[1] == col){
                      isValidMove = true;
                    }
                  }
            
                  return Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row,col),
                  );
                }
            ),
          ),
          Expanded(child: GridView.builder(
              itemCount: blackPiecesTaken.length,
    physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
              itemBuilder: (context,index)=> DeadPiece(imagePath: blackPiecesTaken[index].imagePath,isWhite: false,))),
        ],
      ),
    );
  }
}


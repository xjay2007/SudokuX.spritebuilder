@class GameBoard, ControlBoard;
@class PuzzleState, Game;

@interface MainScene : CCNode {
    // board to display numbers
    GameBoard       *   _gameBoard;
    
    // board to control, e.g. input number, undo, reset etc.
    ControlBoard    *   _controlBoard;
    
    // game model
    Game            *   _game;
}

+ (CCScene *)sceneWithGame:(Game *)game;

@end

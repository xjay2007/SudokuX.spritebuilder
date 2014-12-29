@class GameBoard, ControlBoard;
@class PuzzleState;

@interface MainScene : CCNode {
    // board to display numbers
    GameBoard       *   _gameBoard;
    
    // board to control, e.g. input number, undo, reset etc.
    ControlBoard    *   _controlBoard;
    
    // The state currently being displayed in the grid.
    PuzzleState     *   _state;
    
    // The original state of a newly generated puzzle, used for comparison.
    PuzzleState     *   _originalState;
    
    // The original state of a newly generated puzzle, used for comparison.
    PuzzleState     *   _solvedOriginalState;
    
    // Whether to highlight cells that can only be a specific number.
    BOOL                _isShowSuggestedCells;
    
    // Whether to show where incorrect numbers have been added to the grid.
    BOOL                _isShowIncorrectNumbers;
    
    // The puzzle difficulty level used for showing hints.
    PuzzleDifficulty    _difficutyLevel;
    
    // Maintains a history of undo information.
    NSMutableArray  *   _undoStatesStack;
    
    // Currently selected cell in the grid.
    CGPoint             _selectedCell;
    
    // Color
    CCColor         *   _userValueColor;
    CCColor         *   _originalValueColor;
    CCColor         *   _incorrectValueColor;
}

+ (CCScene *)sceneWithDifficutyLevel:(PuzzleDifficulty)level;

+ (CCScene *)sceneWithState:(PuzzleState *)state;

@end

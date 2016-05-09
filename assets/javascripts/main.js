window.app = {
  pieces: [
    ['♙', '♘', '♗', '♖', '♕', '♔', ''],
    ['♟', '♞', '♝', '♜', '♛', '♚', '']
  ],
  files: ['a', 'b','c','d','e','f','g','h'],
  ranks: ['1','2','3','4','5','6','7','8'],
  selected: null,
  loading: false,
  log: [],
  logShowing: false,
  
  initialize: function() {
    this.board = {};
    this.createBoard();
    this.logger = new Logger($('#log'));
    this.$board = $('#board');
    var self = this;
    $('#new-game').on('click', function(e) { 
      e.preventDefault();
      self.fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w';
      self.fetch(); 
    });
  },
  
  loader: function() {
    if(this.loading) {
      this.$board.removeClass('loading');
      this.loading = false;
    } else {
      this.$board.addClass('loading');
      this.loading = true;
    }
  },
  
  createBoard: function() {
    for(var i = 0; i < 8; i++) {
      for(var j = 0; j < 8; j++) {
        var sq = this.files[i] + this.ranks[j];
        this.board[sq] = new Square(sq);
      }
    }
  },
  
  fetch: function() {
    var self = this;
    this.loader();
    $.ajax({
      url: '/positions',
      type: 'post',
      data: { fen: self.fen },
      success: function(data) {
        self.data = JSON.parse(data);
        console.log(self.data);
        self.logger.log(self.data.log);
        self.render();
      }
    });
  },
  
  render: function() {
    for(var sq in this.board) {
      this.board[sq].update();
    }
    this.loader();
  }
};


$(function() {
  app.initialize();
});  

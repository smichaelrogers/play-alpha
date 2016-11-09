window.App = {};

App.pieces = [
  ['♙', '♘', '♗', '♖', '♕', '♔', ''],
  ['♟', '♞', '♝', '♜', '♛', '♚', '']
];

App.initialize = function() {
  this.$el = $('#game');
  this.$log = $('#log');
  this.$board = $('#board');
  this.logEntries = [];
  this.game = [];
  this.gameIndex = -1;
  this.board = {};
  this.selected = null;

  $('.square').each(function() {
    var $sq = $(this);
    App.board[$sq.attr('id')] = new App.Square($sq);
  });

  $('#new-game').on('click', function(e) {
    e.preventDefault();
    App.queryEngine({
      fen: 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w'
    });
  });

  $('#undo').on('click', function(e) {
    e.preventDefault();
    if(App.gameIndex > 0) {
      App.undo();
    }
  });

  $('#toggle-log').on('click', function(e) {
    e.preventDefault();
    App.$log.toggleClass('collapsed');
  });
};

App.queryEngine = function(pos) {
  this.$board.removeClass('ready').addClass('waiting');
  $.ajax({
    url: '/api/search',
    type: 'post',
    data: pos,
    success: function(data) {
      App.loadPosition(JSON.parse(data));
    }
  });

  this.updateLog();
};

App.loadPosition = function(data) {
  this.$board.removeClass('waiting').addClass('loading');
  console.log(data);
  this.gameIndex++;
  this.game[this.gameIndex] = data;
  if(this.gameIndex === 1) {
    this.$el.find('#undo').removeClass('disabled');
  }

  this.logEntries.push(data.log);
  this.updateLog();
  this.updatePosition();
};

App.undo = function() {
  this.logEntries.pop();
  this.gameIndex--;
  this.updateLog();
  this.updatePosition();
  if(this.gameIndex === 0) {
    this.$el.find('#undo').addClass('disabled');
  }
};

App.updatePosition = function() {
  var data = this.game[this.gameIndex];
  for(sq in this.board) {
    this.board[sq].update(data.board[sq]);
  }
  setTimeout(function() {
    this.$board.removeClass('loading').addClass('ready');
  }.bind(this), 500);
};

App.updateLog = function() {
  var entries = [];
  this.logEntries.forEach(function(entry) {
    entries.push(entry.join('<br>'));
  }.bind(this));

  this.$log.html(entries.join('<hr>'));

  setTimeout(function() {
    this.$log.scrollTop(999999);
  }.bind(this), 400);
};

App.makeMove = function(square) {
  square.$el.html(this.selected.$el.html());
  this.selected.$el.html('');
  this.queryEngine({ fen: square.targetedBy.fen });
  this.selected.deselect();
};

App.Square = function($el) {
  this.$el = $el;
  this.id = this.$el.attr('id');
  this.moves = [];
  this.targetedBy = null;
  this.$el.on('click', function() {
    if(App.selected) {
      if(this.targetedBy) {
        App.makeMove(this);
      } else {
        App.selected.deselect();
      }
    } else if(this.moves.length > 0) {
      this.select();
    }
  }.bind(this));
};

App.Square.prototype.deselect = function() {
  this.$el.removeClass('selected');
  App.selected = null;
  this.moves.forEach(function(move) {
    App.board[move.to].$el.removeClass('valid');
    App.board[move.to].targetedBy = null;
  });
};

App.Square.prototype.select = function() {
  this.$el.addClass('selected');
  App.selected = this;
  this.moves.forEach(function(move) {
    App.board[move.to].$el.addClass('valid');
    App.board[move.to].targetedBy = move;
  });
};

App.Square.prototype.update = function(data) {
  this.moves = data.moves;
  this.$el.html('<div class="piece">' + App.pieces[data.color % 6][data.piece] + '</div>');
};

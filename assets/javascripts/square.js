function Square(id) {
  this.id = id;
  this.moves = [];
  this.html = '';
  this.$el = $('.square[data-square="' + id +'"]');
  this.targetedBy = null;
  this.bindEvents();
}

Square.prototype.bindEvents = function() {
  this.$el.on('click', function() {
    if(this.targetedBy) {
      app.fen = this.targetedBy.fen;
      app.board[this.targetedBy.from].$el.html('');
      this.$el.html(app.board[this.targetedBy.from].html);
      this.removeTarget();
      if(app.selected) { 
        app.selected.deselect();
      }
      app.fetch();
    } else if(this.moves.length > 0) {
        if(app.selected === this) { 
          this.deselect();
        } else { 
          this.select();
        }
    } else if(app.selected) {
      app.selected.deselect();
    }
  }.bind(this));
  return this;
};

Square.prototype.target = function(move) {
  this.targetedBy = move;
  this.$el.addClass('valid');
};

Square.prototype.removeTarget = function() {
  this.targetedBy = null;
  this.$el.removeClass('valid');
};

Square.prototype.deselect = function() {
  if(app.selected === this) {
    this.$el.removeClass('selected');
    app.selected = null;
    this.moves.forEach(function(move) {
      app.board[move.to].removeTarget();
    });
  }
};

Square.prototype.select = function() {
  this.$el.addClass('selected');
  if(app.selected) { app.selected.deselect(); }
  app.selected = this;
  this.moves.forEach(function(move) {
    app.board[move.to].target(move);
  });
};

Square.prototype.update = function() {
  var data = app.data.board[this.id];
  this.html = '';
  if(data.piece !== 6) {
    this.html = '<div class="piece">' + app.pieces[data.color][data.piece] + '</div>';
  }
  this.$el.html(this.html);
  this.moves = data.moves;
};

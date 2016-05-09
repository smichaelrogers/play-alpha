function Logger($el) {
  this.$el = $el;
  this.$content = this.$el.find('#log-content');
  this.entries = [];
  this.intvId = null;
  var self = this;
  this.$el.find('#log-toggle').on('click', function(e) {
    e.preventDefault();
    self.$content.toggleClass('collapsed');
    if(!self.$content.hasClass('collapsed')) {
      setTimeout(function() {
        self.$content.scrollTop(999999);
      }, 300);
    }
  });
};

Logger.prototype.log = function(entries) {
  this.$content.append('<br>==============================================<br><br>' + entries.join('<br>'));
  setTimeout(function() {
    this.$content.scrollTop(999999);
  }.bind(this), 300);
};
//= require jquery.min
//= require_tree ../templates
//= require_tree .


// 
// function startGame() {
//   $.ajax({
//     url: '/positions',
//     type: 'get',
//     dataType: 'json',
//     success: function(data) {
//       console.log(JSON.parse(data));
//       $('.content').html(JST['view'](JSON.parse(data)));
//     }
//   });
// };
// 
// function makeMove() {
//   $.ajax({
//     url: '/positions',
//     type: 'post',
//     dataType: 'json',
//     data: { fen: $(e.currentTarget).data('fen') },
//     success: function(data) {
//       console.log(JSON.parse(data));
//       $('.content').html(JST['view'](JSON.parse(data)));
//     }
//   });
// };
// 
// window.app = {
//   init: function() {
//     $('#start').on('click', startGame);
//     $('.move').on('click', makeMove);
//   }
// }
// 
// 
// 
// $(function() {
//   app.init();
// });
$(document).ready(function() {
  terms = $('#hn-graph').data('names');
  colors = []
  len = terms.length
  for (var i = 0; i < len; i++) {
    colors.push('#'+Math.floor(Math.random()*16777215).toString(16));
  }
  Morris.Line({
    element: 'hn-graph',
    data: $('#hn-graph').data('keywords'),
    xkey: 'date',
    ykeys: $('#hn-graph').data('names'),
    labels: $('#hn-graph').data('names'),
    lineColors: colors
  });
});

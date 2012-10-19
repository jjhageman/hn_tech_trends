$(document).ready(function() {
  terms = $('#hn-graph').data('names');
  colors = []
  len = terms.length
  for (var i = 0; i < len; i++) {
    colors.push("#"+(function(a,b){while(a--){b+=""+(~~(Math.random()*16)).toString(16);} return b;})(6,""));
  }
  Morris.Line({
    element: 'hn-graph',
    data: $('#hn-graph').data('snapshots'),
    xkey: 'date',
    ykeys: $('#hn-graph').data('names'),
    labels: $('#hn-graph').data('names'),
    lineColors: colors,
    lineWidth: 2,
    pointSize: 2,
    hideHover: true,
    xLabels: 'day'
  });
});

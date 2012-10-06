$(document).ready(function() {
  Morris.Line({
    element: 'hn-graph',
    data: $('#hn-graph').data('keywords'),
    xkey: 'created_at',
    ykeys: ['count'],
    labels: ['Mentions'],
    lineColors: ['#167f39','#044c29'],
    lineWidth: 2
  });
});

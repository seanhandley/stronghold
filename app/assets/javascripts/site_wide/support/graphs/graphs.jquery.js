$(document).ready(function () {
  if(document.getElementById("graph-tabs") != null) {
    $.ajax({
      type: "GET",
      contentType: "application/json;",
      url: '/account/graph/data.json',
      dataType: 'json',
      success: function (data) {
        StrongholdGraphs.createCharts(StrongholdGraphs.buildSeries(data));
        $(document).on( 'shown.bs.tab', 'a[data-toggle="tab"]', function (e) {
          $( ".individual-graph").each(function() {
            var chart = $(this).highcharts();
            chart.reflow()
          });
        })
        capacityUsed = data.overall.capacity.used_percent;
        if(capacityUsed >= 70 && capacityUsed < 90) {
          $('#capacity-used div:first-child').removeClass("progress-bar-success");
          $('#capacity-used div:first-child').addClass("progress-bar-warning");
        } else if(capacityUsed >= 90) {
          $('#capacity-used div:first-child').removeClass("progress-bar-success");
          $('#capacity-used div:first-child').addClass("progress-bar-danger");
        }

        $('#capacity-used div:first-child').css('width', capacityUsed + "%");
        $('.progress-caption#capacity-used em span#percent').text(capacityUsed + "%");
      },
      error: function (result) {
        console.log('There was an error:' + JSON.stringify(result));
      }
    });
  };
});


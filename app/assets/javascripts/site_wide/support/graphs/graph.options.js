var StrongholdGraphOptions = {
  defaultOptions: {
    credits: {
      enabled: false
    },
    exporting: {
      enabled: false
    }
  },
  semiPieChartOptions: function(seriesData) {
    return $.extend(true, {
      chart: {
        plotBackgroundColor: null,
        plotBorderWidth: 0,
        plotShadow: false,
        spacingBottom: 0,
        spacingTop: 0,
        spacingLeft: 0,
        spacingRight: 0,
        height: 350
      },
      title: {
        text: ''
      },
      tooltip: {
        pointFormat: '<b>{point.percentage:.1f}%</b>'
      },
      plotOptions: {
        pie: {
          dataLabels: {
            enabled: false
          },
          startAngle: -90,
          endAngle: 90,
          center: ['50%', '75%'],
          size: '70%'
        }
      },
      legend: {
        align: 'center',
        verticalAlign: 'bottom',
        floating: true,
        layout: 'vertical',
        // x: 0,
        y: -15,
        backgroundColor: null
      },
      series: [{
        showInLegend: true,
        type: 'pie',
        name: '',
        innerSize: '59%',
        data: seriesData
      }]
    }, StrongholdGraphOptions.defaultOptions);
  },
  pieChartOptions: function(unit, seriesData) {
    return $.extend(true, {
      chart: {
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        type: 'pie',
        height: 350
      },
      title: {
        text: ''
      },
      tooltip: {
        pointFormat: '<b>{point.y:.0f}</b> ' + unit
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          size: 190,
          dataLabels: {
            enabled: true,
            format: '<b>{point.name}</b>: {point.y:.0f}',
            distance: 10,
            reserveSpace: false,
            style: {
                color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
            }
          }
        }
      },
      series: [{
        name: '',
        data: seriesData
      }],
      series: [{
        colorByPoint: true,
        data: seriesData
      }]
    }, StrongholdGraphOptions.defaultOptions);
  }
}

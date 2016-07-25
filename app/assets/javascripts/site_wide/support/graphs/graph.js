var StrongholdGraphs = {
  buildSeries: function(data) {
    var instancesUsed = data.compute.instances.used;
    var instancesAvailable = data.compute.instances.available;
    var flavorsUsed = data.compute.flavors;
    var coresUsed = data.compute.cores.used;
    var coresAvailable = data.compute.cores.available;
    var memoryUsed = data.compute.memory.used;
    var memoryAvailable = data.compute.memory.available;
    var volumesUsed = data.volume.volumes.used;
    var volumesAvailable = data.volume.volumes.available;
    var storageUsed = data.volume.storage.used;
    var storageAvailable = data.volume.storage.available;
    var floatingIpUsed = data.network.floatingip.used;
    var floatingIpAvailable = data.network.floatingip.available;
    var poolsUsed = data.network.lbpools.used;
    var poolsAvailable = data.network.lbpools.available;

    return {
      instancesSeries: [
        [instancesUsed + ' active', instancesUsed],
        [instancesAvailable + ' available', instancesAvailable],
      ],
      flavorsSeries: $.map(flavorsUsed, function(e) {
        return {
          name: e.name,
          y: e.count
        }
      }),
      coresSeries: [
        [coresUsed + ' cores active', coresUsed],
        [coresAvailable + ' cores available', coresAvailable],
      ],
      memorySeries: [
        [memoryUsed + ' MB Used', memoryUsed],
        [memoryAvailable + ' MB Available', memoryAvailable],
      ],
      volumesSeries: [
        [volumesUsed + ' volumes active', volumesUsed],
        [volumesAvailable + ' volumes available', volumesAvailable],
      ],
      storageSeries: [
        [storageUsed + ' GB storage used', storageUsed],
        [storageAvailable + ' GB storage available', storageAvailable],
      ],
      floatingIpSeries: [
        [floatingIpUsed + ' IPs active', floatingIpUsed],
        [floatingIpAvailable + ' IPs available', floatingIpAvailable],
      ],
      poolsSeries: [
        [poolsUsed + ' pools used',    poolsUsed],
        [poolsAvailable + ' pools available', poolsAvailable]
    ]}
  },
  createCharts: function(series) {
    Highcharts.setOptions(Highcharts.theme1);
    $('#container-instance').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.instancesSeries));
    $('#container-flavor').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.flavorsSeries));

    Highcharts.setOptions(Highcharts.theme3);
    $('#container-cores').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.coresSeries));
    $('#container-memory').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.memorySeries));

    Highcharts.setOptions(Highcharts.theme2);
    $('#container-volume').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.volumesSeries));
    $('#container-storage').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.storageSeries));

    Highcharts.setOptions(Highcharts.theme4);
    $('#container-floating-ip').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.floatingIpSeries));
    $('#container-pools').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.poolsSeries));
  }
}

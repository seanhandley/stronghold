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
        [instancesUsed + ' instances active', instancesUsed],
        [instancesAvailable + ' instances available', instancesAvailable],
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
        [memoryUsed + ' MB RAM Used', memoryUsed],
        [memoryAvailable + ' MB RAM Available', memoryAvailable],
      ],
      volumesSeries: [
        [volumesUsed + ' volumes active', volumesUsed],
        [volumesAvailable + ' volumes available', volumesAvailable],
      ],
      storageSeries: [
        [storageUsed + ' GB block storage used', storageUsed],
        [storageAvailable + ' GB block storage available', storageAvailable],
      ],
      floatingIpSeries: [
        ['Active IPs', floatingIpUsed],
        ['Available IPs', floatingIpAvailable],
      ],
      poolsSeries: [
        [poolsUsed + ' load balancer pools used',    poolsUsed],
        [poolsAvailable + ' load balancer pools available', poolsAvailable]
      ]}
  },
  createCharts: function(series) {
    Highcharts.setOptions(Highcharts.theme1);
    $('#container-instance').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.instancesSeries));
    $('#container-flavor').highcharts(StrongholdGraphOptions.pieChartOptions("active instances", series.flavorsSeries));

    Highcharts.setOptions(Highcharts.theme2);
    $('#container-cores').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.coresSeries));
    $('#container-memory').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.memorySeries));

    Highcharts.setOptions(Highcharts.theme3);
    $('#container-volume').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.volumesSeries));
    $('#container-storage').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.storageSeries));

    Highcharts.setOptions(Highcharts.theme4);
    $('#container-floating-ip').highcharts(StrongholdGraphOptions.pieChartOptions('Floating IPs', series.floatingIpSeries));
    $('#container-pools').highcharts(StrongholdGraphOptions.semiPieChartOptions(series.poolsSeries));
  }
}

local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("locationtech.geotrellis", "LocationTech GeoTrellis") {
  "config.json"+: {
    sbt+: {
      generate: true,
    }
  }
}

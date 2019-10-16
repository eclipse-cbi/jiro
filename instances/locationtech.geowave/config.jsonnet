local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "locationtech.geowave",
    shortName: "geowave",
    displayName: "Eclipse GeoWave"
  }
}

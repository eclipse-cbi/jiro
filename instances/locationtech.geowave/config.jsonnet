local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "locationtech.geowave",
    shortName: "geowave",
    displayName: "Eclipse GeoWave"
  }
}

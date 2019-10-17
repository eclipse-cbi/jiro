local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    "fullName": "iot.packages",
    "shortName": "packages",
    "displayName": "Eclipse IoT Packages"
  }
}

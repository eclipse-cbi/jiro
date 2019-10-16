local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "eclipse.equinox",
    shortName: "equinox",
    displayName: "Eclipse Equinox"
  }
}

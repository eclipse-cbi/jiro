local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.packager",
    shortName: "packager",
    displayName: "Eclipse Packager"
  }
}

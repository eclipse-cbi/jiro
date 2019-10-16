local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.thym",
    shortName: "thym",
    displayName: "Eclipse Thym"
  }
}

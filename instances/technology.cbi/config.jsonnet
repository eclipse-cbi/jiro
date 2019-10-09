local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.cbi",
    shortName: "cbi",
    displayName: "Eclipse CBI"
  },
  jenkins: {
    "version": "2.190.1"
  }
}
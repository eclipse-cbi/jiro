local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.osee",
    shortName: "osee",
    displayName: "Eclipse OSEE"
  },
  jenkins: {
    maxConcurrency: 1
  }
}

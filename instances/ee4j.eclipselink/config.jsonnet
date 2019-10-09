local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.eclipselink",
    shortName: "eclipselink",
    displayName: "EclipseLink",
    resourcePacks: 3,
  },
}

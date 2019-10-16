local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.eclipselink",
    shortName: "eclipselink",
    displayName: "EclipseLink",
    resourcePacks: 3,
  },
}

local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "webtools.glassfish-tools",
    shortName: "glassfish-tools",
    displayName: "Eclipse GlassFish Tools"
  }
}

local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "webtools.glassfish-tools",
    shortName: "glassfish-tools",
    displayName: "Eclipse GlassFish Tools"
  }
}

local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "eclipse.jdt",
    shortName: "jdt",
    displayName: "Eclipse Java Development Tools (JDT)"
  }
}

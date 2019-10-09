local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "eclipse.jdt",
    shortName: "jdt",
    displayName: "Eclipse Java Development Tools (JDT)"
  }
}

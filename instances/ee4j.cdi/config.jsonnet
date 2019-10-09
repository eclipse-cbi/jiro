local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.cdi",
    shortName: "cdi",
    displayName: "Jakarta Contexts and Dependency Injection"
  }
}

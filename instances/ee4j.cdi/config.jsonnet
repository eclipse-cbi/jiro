local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.cdi",
    shortName: "cdi",
    displayName: "Jakarta Contexts and Dependency Injection"
  }
}

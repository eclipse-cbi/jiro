local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.bean-validation",
    shortName: "bean-validation",
    displayName: "Jakarta Bean Validation"
  }
}

local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.emfservices",
    shortName: "emfservices",
    displayName: "Eclipse EMF Services"
  }
}

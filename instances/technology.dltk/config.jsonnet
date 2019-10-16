local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.dltk",
    shortName: "dltk",
    displayName: "Eclipse Dynamic Languages Toolkit"
  }
}

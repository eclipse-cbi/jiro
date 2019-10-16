local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.gendoc",
    shortName: "gendoc",
    displayName: "Eclipse Gendoc"
  }
}

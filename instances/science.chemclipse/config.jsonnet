local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "science.chemclipse",
    shortName: "chemclipse",
    displayName: "Eclipse ChemClipse"
  }
}

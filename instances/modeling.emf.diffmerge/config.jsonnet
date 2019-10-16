local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.emf.diffmerge",
    shortName: "diffmerge",
    displayName: "Eclipse EMF Diff/Merge"
  }
}

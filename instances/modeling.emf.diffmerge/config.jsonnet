local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "modeling.emf.diffmerge",
    shortName: "diffmerge",
    displayName: "Eclipse EMF Diff/Merge"
  }
}

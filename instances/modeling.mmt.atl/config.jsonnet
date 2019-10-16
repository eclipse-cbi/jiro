local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mmt.atl",
    shortName: "atl",
    displayName: "Eclipse ATL"
  }
}

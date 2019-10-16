local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.basyx",
    shortName: "basyx",
    displayName: "Eclipse BaSyx",
  },
}

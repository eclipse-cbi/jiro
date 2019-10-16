local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "soa.bpel",
    shortName: "bpel",
    displayName: "Eclipse BPEL Designer"
  }
}

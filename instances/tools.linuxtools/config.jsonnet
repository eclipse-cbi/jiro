local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.linuxtools",
    shortName: "linuxtools",
    displayName: "Eclipse Linux Tools"
  }
}

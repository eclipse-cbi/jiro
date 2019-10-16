local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "tools.shellwax",
    shortName: "shellwax",
    displayName: "Eclipse ShellWax"
  }
}

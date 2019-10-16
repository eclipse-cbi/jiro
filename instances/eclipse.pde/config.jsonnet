local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "eclipse.pde",
    shortName: "pde",
    displayName: "Eclipse Plugin Development Environment (PDE)"
  }
}

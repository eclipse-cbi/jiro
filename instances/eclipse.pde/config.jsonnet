local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "eclipse.pde",
    shortName: "pde",
    displayName: "Eclipse Plugin Development Environment (PDE)"
  }
}

local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.gemoc",
    shortName: "gemoc",
    displayName: "Eclipse GEMOC Studio"
<<<<<<< HEAD
=======
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
>>>>>>> Fixed deployment jsonnet extension
  }
}

local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.sirius",
    shortName: "sirius",
    displayName: "Eclipse Sirius",
    sponsorshipLevel: "S1",
    resourcePacks: 2,
  },
}

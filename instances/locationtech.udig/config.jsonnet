local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "locationtech.udig",
    shortName: "udig",
    displayName: "LocationTech uDig"
  }
}

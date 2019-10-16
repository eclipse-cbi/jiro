local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "technology.swtbot",
    shortName: "swtbot",
    displayName: "Eclipse SWTBot"
  }
}

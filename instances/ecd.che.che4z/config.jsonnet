local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ecd.che.che4z",
    shortName: "che4z",
    displayName: "Eclipse Che4z"
  },
    jenkins: {
    permissions: [
      {
        principal: config.project.fullName,
        withheldPermissions: [
          "Gerrit/ManualTrigger",
          "Gerrit/Retrigger"
        ]
      }
    ]
  }
}

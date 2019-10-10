local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "tools.wildwebdeveloper",
    shortName: "wildwebdeveloper",
    displayName: "Eclipse Wild Web Developer"
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

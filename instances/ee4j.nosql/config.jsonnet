local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.nosql",
    shortName: "nosql",
    displayName: "Jakarta NoSQL"
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

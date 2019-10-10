local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.openj9",
    shortName: "openj9",
    displayName: "Eclipse OpenJ9",
    sponsorshipLevel: "SP2",
    
  },
  jenkins+: {
    staticAgentCount: 50,
    permissions: [
      {
        principal: config.project.fullName,
        withheldPermissions: [
          "Gerrit/ManualTrigger",
          "Gerrit/Retrigger"
        ]
      },
      {
        principal: config.project.fullName,
        "grantedPermissions": [
          "Agent/Connect",
          "Agent/Disconnect"
        ]
      }
    ]
  },
}

local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "technology.openj9",
    shortName: "openj9",
    displayName: "Eclipse OpenJ9",
    "sponsorshipLevel": "SP2"
  },
    jenkins: {
    permissions: [
      {
        principal: "technology.openj9",
        withheldPermissions: [
          "Gerrit/ManualTrigger",
          "Gerrit/Retrigger"
        ]
      },
      {
        principal: "technology.openj9",
        "grantedPermissions": [
          "Agent/Connect",
          "Agent/Disconnect"
        ]
      }
    ]
  },
  "kubernetes": {
    "master": {
      "namespace": "{{project.shortName}}",
      "stsName": "{{project.shortName}}",
      "resources": {
        "cpu": {
          "request": "4000m",
          "limit": "8000m"
        },
        "memory": {
          "limit": "8Gi"
        }
      }
    }
  }
}

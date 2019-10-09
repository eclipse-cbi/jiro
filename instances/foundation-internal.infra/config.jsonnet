local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "foundation-internal.infra",
    shortName: "infra",
    displayName: "Eclipse Foundation Infra"
  },
  deployment: {
    host: "foundation.eclipse.org",
    "prefix": "/ci/{{project.shortName}}"
  },
  jenkins: {
    permissions: [
      {
        principal: "anonymous",
        withheldPermissions: [
          "Overall/Read",
          "Job/Read"
        ]
      },
      {
        principal: "common",
        withheldPermissions: [
          "Job/ExtendedRead"
        ]
      },
      {
        principal: "{{project.fullName}}",
        withheldPermissions: [
          "Credentials/View",
          "Gerrit/ManualTrigger",
          "Gerrit/Retrigger",
          "Agent/Build",
          "Job/Build",
          "Job/Cancel",
          "Job/Configure",
          "Job/Create",
          "Job/Delete",
          "Job/Move",
          "Job/Read",
          "Job/Workspace",
          "Run/Delete",
          "Run/Replay",
          "Run/Update",
          "View/Configure",
          "View/Create",
          "View/Delete",
          "View/Read",
          "SCM/Tag"
        ]
      }
    ]
  },
  "kubernetes": {
    "master": {
      "namespace": "foundation-internal-infra"
    }
  },
  "secrets": {
    "gerrit-trigger-plugin": {
      "username": ""
    }
  }
}

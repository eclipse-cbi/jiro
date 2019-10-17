local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "foundation-internal.webdev",
    shortName: "webdev",
    displayName: "Eclipse Foundation WebDev"
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/{{project.shortName}}"
  },
  jenkins+: {
    staticAgentCount: 1,
    permissions: [
      {
        grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
        principal: principal
      } for principal in [
        "chris.guindon@eclipse-foundation.org", 
        "eric.poirier@eclipse-foundation.org", 
        "martin.lowe@eclipse-foundation.org"
      ]
    ] + [
      {
        principal: "admins",
        grantedPermissions: [
          "Overall/Administer"
        ]
      }
    ],
  },
  kubernetes+: {
    master+: {
      namespace: "foundation-internal-webdev"
    }
  },
  secrets+: {
    "gerrit-trigger-plugin"+: {
      username: ""
    }
  }
}

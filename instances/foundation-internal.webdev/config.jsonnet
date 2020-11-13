local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "foundation-internal.webdev",
    displayName: "Eclipse Foundation WebDev",
    resourcePacks: 5,
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/"+ $.project.shortName
  },
  jenkins+: {
    version: "2.222.4",
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
    "gerrit-trigger-plugin": {},
  },
}

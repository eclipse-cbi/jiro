local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.omr",
    displayName: "Eclipse OMR",
  },
  jenkins+: {
    staticAgentCount: 40,
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"]) + [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
        principal: "adam.brousseau88@gmail.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel", "Overall/SystemRead"],
      },
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
        principal: "joe_dekoning@ca.ibm.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel"],
      },
      {
        // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1364
        principal: "vsebe@ca.ibm.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel"],
      },
    ],
    plugins+: [
      "embeddable-build-status",
      "envinject",
      "generic-webhook-trigger",
      "gradle",
    ],
  },
}

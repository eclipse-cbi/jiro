local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.omr",
    displayName: "Eclipse OMR",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  jenkins+: {
    staticAgentCount: 40,
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"]) + [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
        principal: "adam.brousseau88@gmail.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Configure", "Job/Build", "Job/Cancel", "Overall/SystemRead"],
      },
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
        principal: "joe_dekoning@ca.ibm.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Configure", "Job/Build", "Job/Cancel"],
      },
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
        principal: "rajdeep.singh@ibm.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure"],
      },
    ],
    plugins+: [
      "envinject",
      "generic-webhook-trigger",
      "gradle",
    ],
  },
}

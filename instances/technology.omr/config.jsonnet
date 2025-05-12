local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.omr",
    displayName: "Eclipse OMR",
  },
  jenkins+: {
    staticAgentCount: 40,
    mountPrivateKey: true,
    permissions:
      permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
      permissionsTemplates.user("adam.brousseau88@gmail.com", ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel", "Overall/SystemRead"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
      permissionsTemplates.user("joe_dekoning@ca.ibm.com", ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel"]) +
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2042
      permissionsTemplates.user("sarah_jackson@uk.ibm.com", ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel"]) +
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/3319
      permissionsTemplates.user("mahdi@ibm.com", ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel"]) +
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/5344
      permissionsTemplates.user("aswinkr77@gmail.com", ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Create", "Job/Configure", "Job/Build", "Job/Cancel", "Overall/SystemRead"])
    ,
    plugins+: [
      "docker-plugin",
      "docker-workflow",
      "embeddable-build-status",
      "envinject",
      "generic-webhook-trigger",
      "gradle",
    ],
  },
  seLinuxLevel: "s0:c49,c39",
  storage: {
    storageClassName: "managed-nfs-storage-barney-retain-policy",
  }
}

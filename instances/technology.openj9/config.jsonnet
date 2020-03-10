local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.openj9",
    shortName: "openj9",
    displayName: "Eclipse OpenJ9",
  },
  jenkins+: {
    staticAgentCount: 50,
    permissions: 
      permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"]) + 
      permissionsTemplates.projectPermissions("adam.brousseau88@gmail.com", ["Agent/Connect", "Agent/Disconnect"]) +
      permissionsTemplates.projectPermissions("joe_dekoning@ca.ibm.com", ["Agent/Connect", "Agent/Disconnect"]) +
      permissionsTemplates.projectPermissions("peter_shipton@ca.ibm.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("daniel_heidinga@ca.ibm.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("adam.brousseau88@gmail.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("joe_dekoning@ca.ibm.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("adam.brousseau88@gmail.com", ["Job/Configure"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=559384
      permissionsTemplates.projectPermissions("adam.brousseau88@gmail.com", ["Job/Configure"]) +
      permissionsTemplates.projectPermissions("joe_dekoning@ca.ibm.com", ["Job/Configure"]) +
      permissionsTemplates.projectPermissions("vsebe@ca.ibm.com", ["Job/Configure"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=553268
      permissionsTemplates.projectPermissions("rajdeep.singh@ibm.com", ["Agent/Configure", "Agent/Connect", "Agent/Disconnect"]) +
      // https://bugs.eclipse.org/bugs/show_bug.cgi?id=559384#c3
      permissionsTemplates.projectPermissions("vsebe@ca.ibm.com", ["Agent/Configure", "Agent/Connect", "Agent/Disconnect"])
  },
}

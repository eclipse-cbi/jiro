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
      permissionsTemplates.projectPermissions("peter_shipton@ca.ibm.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("daniel_heidinga@ca.ibm.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("adam.brousseau88@gmail.com", ["Agent/Configure"]) +
      permissionsTemplates.projectPermissions("joe_dekoning@ca.ibm.com", ["Agent/Configure"]) 
  },
}

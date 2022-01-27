
local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "automotive.sumo",
    displayName: "Eclipse SUMO",
    resourcePacks: 2,
  },
  jenkins+: {
    permissions:
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList)
  }
}

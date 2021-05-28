{
  project+: {
    fullName: "iot.hono",
    displayName: "Eclipse Hono",
  },
  jenkins+: {
    permissions:
      // workaround to avoid errors, when the Gerrit plugin is disabled
      permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  }
}

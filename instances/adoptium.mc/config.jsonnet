local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "adoptium.mc",
    displayName: "Eclipse Mission Control",
  },
  jenkins+: {
    // workaround to avoid errors, when the Gerrit plugin is disabled
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList),
    plugins+: [
      "badge",
      "build-with-parameters",
      "embeddable-build-status",
      "groovy-postbuild",
      "http_request",
      "slack",
      "xvfb",
    ],
  },
}
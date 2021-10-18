local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("webtools", "Eclipse Web Tools Platform Project") {
  "config.json"+: {
    jenkins+: {
      permissions+:
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=568553#c23
        permissionsTemplates.projectPermissions("nboldt@redhat.com", permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"]),
      plugins+: [
        "ansicolor",
        "dashboard-view",
        "description-setter",
        "log-parser",
        "show-build-parameters",
      ],
    },
  },
}

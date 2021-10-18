local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("rt.ecf", "Eclipse Communication Framework") {
  "config.json"+: {
    jenkins+: {
      permissions+: [
        {
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=546758
          principal: "mat.booth@redhat.com",
          grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
        }
      ],
      plugins+: [
        "envinject",
      ],
    }
  },
}

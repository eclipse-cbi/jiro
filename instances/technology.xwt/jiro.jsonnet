local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("technology.xwt", "Eclipse XWT") {
  "config.json"+: {
    jenkins+: {
      permissions+: [
        {
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=547567
          principal: "patrick.tessier@cea.fr",
          grantedPermissions: permissionsTemplates.committerPermissionsList + ["Gerrit/ManualTrigger", "Gerrit/Retrigger"],
        }
      ]
    }
  },
}

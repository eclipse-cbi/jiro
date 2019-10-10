local default = import '../../templates/default.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

default+ {
  project+: {
    fullName: "rt.ecf",
    shortName: "ecf",
    displayName: "Eclipse Communication Framework"
  },
  jenkins+: {
    permissions+: [
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=546758
        principal: "mat.booth@redhat.com", 
        grantedPermissions: permissionsTemplates.projectPermissionsWithGerrit
      }
    ]
  }
}

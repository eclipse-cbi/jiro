local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "rt.jetty",
    displayName: "Eclipse Jetty",
  },
  jenkins+: {
    // https://bugs.eclipse.org/bugs/show_bug.cgi?id=562090
    // https://bugs.eclipse.org/bugs/show_bug.cgi?id=572882
    permissions+: [
      {
        principal: "akurtako@redhat.com",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
      },
      {
        principal: "rgrunber@redhat.com",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
      },
      {
        principal: "matthias.sohn@sap.com",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
      },
      {
        principal: "sravankumarl@in.ibm.com",
        grantedPermissions: permissionsTemplates.committerPermissionsList,
      },
    ],
  },
}

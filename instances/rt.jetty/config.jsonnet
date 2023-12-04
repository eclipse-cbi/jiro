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
        user: "akurtako@redhat.com",
        permissions: permissionsTemplates.committerPermissionsList,
      },
      {
        user: "rgrunber@redhat.com",
        permissions: permissionsTemplates.committerPermissionsList,
      },
      {
        user: "matthias.sohn@sap.com",
        permissions: permissionsTemplates.committerPermissionsList,
      },
      {
        user: "sravankumarl@in.ibm.com",
        permissions: permissionsTemplates.committerPermissionsList,
      },
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2996
      {
        user: "gpunathi@in.ibm.com",
        permissions: permissionsTemplates.committerPermissionsList,
      },
    ],
  },
}

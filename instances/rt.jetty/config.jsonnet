local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "rt.jetty",
    displayName: "Eclipse Jetty",
  },
  jenkins+: {
    // https://bugs.eclipse.org/bugs/show_bug.cgi?id=562090
    // https://bugs.eclipse.org/bugs/show_bug.cgi?id=572882
    permissions+:
      permissionsTemplates.user("akurtakov@redhat.com", permissionsTemplates.committerPermissionsList) +
      permissionsTemplates.user("rgrunber@redhat.com", permissionsTemplates.committerPermissionsList) +
      permissionsTemplates.user("matthias.sohn@sap.com", permissionsTemplates.committerPermissionsList) +
      permissionsTemplates.user("sravankumarl@in.ibm.com", permissionsTemplates.committerPermissionsList) +
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2996
      permissionsTemplates.user("gpunathi@in.ibm.com", permissionsTemplates.committerPermissionsList)
  },
}

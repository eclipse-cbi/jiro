local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.packaging",
    displayName: "Eclipse Packaging Project",
  },
  jenkins+: {
      permissions+:
        // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2481
        permissionsTemplates.user("ed.merks@gmail.com", ["Overall/Read", "Job/Build", "Job/Read", "Job/ExtendedRead", "Job/Cancel", "Agent/Build"])
  },
}

{
  project+: {
    fullName: "technology.packaging",
    displayName: "Eclipse Packaging Project",
  },
  jenkins+: {
      version: "2.361.4",
      permissions+: [
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2481
      {
        principal: "ed.merks@gmail.com",
        grantedPermissions: ["Overall/Read", "Job/Build", "Job/Read", "Job/ExtendedRead", "Job/Cancel"],
      },
      ],
  },
}

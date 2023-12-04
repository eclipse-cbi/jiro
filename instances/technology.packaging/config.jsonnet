{
  project+: {
    fullName: "technology.packaging",
    displayName: "Eclipse Packaging Project",
  },
  jenkins+: {
      permissions+: [
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/2481
      {
        user: "ed.merks@gmail.com",
        permissions: ["Overall/Read", "Job/Build", "Job/Read", "Job/ExtendedRead", "Job/Cancel", "Agent/Build"],
      },
      ],
  },
}

{
  project+: {
    fullName: "tools.orbit",
    displayName: "Eclipse Orbit"
  },
  jenkins+: {
    plugins+: [
      "oidc-provider", // https://gitlab.eclipse.org/eclipsefdn/infrazilla/-/work_items/2633
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c50,c25",
}

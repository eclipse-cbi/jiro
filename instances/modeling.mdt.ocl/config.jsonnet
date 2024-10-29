{
  project+: {
    fullName: "modeling.mdt.ocl",
    displayName: "Eclipse OCL"
  },
  jenkins+: {
    theme: "quicksilver-light",
    plugins+: [
      "gerrit-trigger",
    ],
  },
  seLinuxLevel: "s0:c49,c34",
}

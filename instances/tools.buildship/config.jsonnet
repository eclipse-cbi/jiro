{
  project+: {
    fullName: "tools.buildship",
    displayName: "Eclipse Buildship",
  },  
  jenkins+: {
    plugins+: [
      "envinject",
      "gradle",
    ],
  },
  seLinuxLevel: "s0:c64,c39",
}

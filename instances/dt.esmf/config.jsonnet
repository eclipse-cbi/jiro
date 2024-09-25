{
  project+: {
    fullName: "dt.esmf",
    displayName: "Eclipse Semantic Modeling Framework (ESMF)",
  }, 
  jenkins+: {
    plugins+: [
      "nodejs"
    ],
  },
  seLinuxLevel: "s0:c45,c20",
}

{
  project+: {
    fullName: "modeling.emfcompare",
    displayName: "Eclipse EMF Compare",
  },
  jenkins+: {
    plugins+: [
      "jacoco",
    ],
  },
  seLinuxLevel: "s0:c38,c22",
}

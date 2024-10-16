{
  project+: {
    fullName: "modeling.gendoc",
    displayName: "Eclipse Gendoc"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c40,c15",
}

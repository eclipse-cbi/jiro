{
  project+: {
    fullName: "technology.osee",
    displayName: "Eclipse OSEE"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
      "nodejs",
    ],
  },
}

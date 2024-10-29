{
  project+: {
    fullName: "technology.swtbot",
    displayName: "Eclipse SWTBot"
  },
  jenkins+: {
    plugins+: [
      "gerrit-trigger",
    ]
  },
  seLinuxLevel: "s0:c54,c49",
}

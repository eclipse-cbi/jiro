{
  project+: {
    fullName: "eclipse.jdt.ls",
    displayName: "Eclipse JDT Language Server"
  },
  jenkins+: {
    plugins+: [
      "build-timestamp",
      "copyartifact",
      "envinject",
      "issue-link",
      "mattermost",
    ],
  },
}

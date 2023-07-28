{
  project+: {
    fullName: "automotive.mdmbl",
    displayName: "Eclipse MDM|BL",
  },
  jenkins+: {
    plugins+: [
      "gradle",
      "gerrit-trigger"
    ]
  },
  secrets+: {
    "gerrit-trigger-plugin": {
      username: "genie." + $.project.shortName,
      identityFile: "/run/secrets/jenkins/ssh/id_rsa",
    },
  }
}

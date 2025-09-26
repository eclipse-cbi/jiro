{
  project+: {
    fullName: "tools.mylyn",
    displayName: "Eclipse Mylyn",
  },
  jenkins+: {
    plugins+: [
      "xunit",
      "warnings-ng",
      "gradle"
    ]
  },
  develocity+: {
    generate: true,
  },
  maven+: {
    local superSettings = super.files["settings.xml"],
    files+: {
      "settings-deploy-ossrh-docs.xml": {
        servers: {
          "repo.eclipse.org": superSettings.servers["repo.eclipse.org"],
          central: {
            username: {
              pass: "bots/mylyn.docs/central.sonatype.org/token-username",
            },
            password: {
              pass: "bots/mylyn.docs/central.sonatype.org/token-password",
            }
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/mylyn.docs/gpg/passphrase"
            }
          }
        },
        mirrors: superSettings.mirrors,
      },
    },
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c49,c4",
}

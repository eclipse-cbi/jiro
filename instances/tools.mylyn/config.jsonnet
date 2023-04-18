{
  project+: {
    fullName: "tools.mylyn",
    displayName: "Eclipse Mylyn",
  },
  jenkins+: {
    plugins+: [
      "xunit",
      "warnings-ng",
    ]
  },
  maven+: {
    local superSettings = super.files["settings.xml"],
    files+: {
      "settings-deploy-ossrh-docs.xml": {
        servers: {
          "repo.eclipse.org": superSettings.servers["repo.eclipse.org"],
          ossrh: {
            nexusProUrl: superSettings.servers.ossrh.nexusProUrl,
            username: {
              pass: "bots/mylyn.docs/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/mylyn.docs/oss.sonatype.org/password",
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
}

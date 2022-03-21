{
  spec+: {
    template+: {
      spec+: {
        containers: [
          x + {
            volumeMounts+: [
              {
                mountPath: "/var/jenkins/.ssh",
                name: "master-known-hosts",
              }
            ],
            env: [
              # Required for gerrit-code-review https://github.com/jenkinsci/gerrit-code-review-plugin/releases/tag/gerrit-code-review-0.4.6,
              if (env.name == "JAVA_OPTS") then
                env + {
                  value: env.value + " -Dhudson.remoting.ClassFilter=com.google.gerrit.extensions.common.AvatarInfo,com.google.gerrit.extensions.common.ReviewerUpdateInfo,com.google.gerrit.extensions.common.ActionInfo,com.google.gerrit.extensions.common.TrackingIdInfo,com.google.gerrit.extensions.common.LabelInfo,com.google.gerrit.extensions.common.ApprovalInfo,com.google.gerrit.extensions.common.RevisionInfo,com.google.gerrit.extensions.common.ChangeInfo,com.google.gerrit.extensions.common.FetchInfo,com.google.gerrit.extensions.common.CommitInfo,com.google.gerrit.extensions.common.WebLinkInfo,com.google.gerrit.extensions.common.GitPerson,com.google.gerrit.extensions.common.FileInfo,com.google.gerrit.extensions.common.VotingRangeInfo"
                } else
                env
              for env in super.env
            ],
          } for x in super.containers
        ],
        volumes+: [
          {
            name: "master-known-hosts",
            configMap: {
              name: "master-known-hosts",
            },
          },
        ],
      },
    },
  },
}

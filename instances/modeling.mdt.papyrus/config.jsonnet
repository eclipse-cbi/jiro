{
  project+: {
    fullName: "modeling.mdt.papyrus",
    displayName: "Eclipse Papyrus",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "centos-7-agent-6gb": currentCloud.templates["centos-7"] {
          labels: ["centos-7-6gb"],
          kubernetes+: {
            resources+: {
              memory: {
                limit: "6144Mi",
                request: "6144Mi",
              },
            },
          },
        },
      },
    },
  },
}
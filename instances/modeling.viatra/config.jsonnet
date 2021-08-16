{
  project+: {
    fullName: "modeling.viatra",
    displayName: "Eclipse VIATRA",
  },
  clouds+: {
    kubernetes+: { 
      local currentCloud = self,
      templates+: {
        "jipp-centos-7-6gb": currentCloud.templates["centos-7"] {
          labels: ["centos7-6gb"],
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

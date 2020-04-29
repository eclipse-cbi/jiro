{
  project+: {
    fullName: "polarsys.kitalpha",
    shortName: "kitalpha",
    displayName: "Eclipse Kitalpha",
  },
  deployment+: {
    host: "ci-staging.eclipse.org"
  },
  clouds: [
    c + { 
      templates: [ 
        t for t in super.templates
      ] + [
        super.templates[1] + {                  // FIXME: relies on the fact that "jipp-migration-agent" is at index 1
          name: "jipp-migration-agent-6gb",
          labels: ["migration-6gb"],
          docker: {
            image: {
              name: "jipp-migration-agent",
              tag: "4.2"
            },
            repository: "eclipsecbijenkins"
          },
          kubernetes+: {
            resources: {
              cpu: {
                limit: "2000m",
                request: "1000m",
              },
              memory: {
                limit: "6144Mi",
                request: "6144Mi",
              },
            },
          },
        },
      ],
    }, for c in super.clouds
  ],
}

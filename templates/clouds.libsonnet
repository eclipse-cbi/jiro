{
  kubernetes(cloudName, config, agents): {
    [cloudName]: {
      kind: "kubernetes",
      namespace: config.kubernetes.agents.namespace, # should be changed to something agent-specific to fix #5
      podRetention: "never",
      templates: {
        [agentName]: agents[agentName].spec + agents[agentName].variants[config.jiroMaster.remoting.version] + {
          kubernetes: {
            resources: config.kubernetes.agents.defaultResources,
            local dot_m2 = agents[agentName].spec.home + "/.m2",
            volumes: (if config.maven.generate then [
              {
                name: "m2-secret-dir",
                secret: { name: "m2-secret-dir", },
                mounts: [
                  {
                    mountPath: dot_m2 + "/" + self.subPath,
                    subPath: settingsFile,
                  } for settingsFile in std.objectFields(config.maven.files)
                ],
              },
              {
                name: "m2-dir",
                configMap: { name: "m2-dir", },
                mounts: [
                  {
                    mountPath: dot_m2 + "/" + self.subPath,
                    subPath: "toolchains.xml"
                  },
                  {
                    mountPath: agents[agentName].spec.home + "/" + self.subPath,
                    subPath: ".mavenrc"
                  },
                ],
              },
            ] else []) + (if config.gradle.generate then [
              {
                local dot_gradle = agents[agentName].spec.home + "/.gradle",
                name: "gradle-secret-dir",
                secret: { name: "gradle-secret-dir", },
                mounts: [
                  {
                    mountPath: dot_gradle + "/" + self.subPath,
                    subPath: propertiesFile,
                  } for propertiesFile in std.objectFields(config.gradle.files)
                ],
              },
            ] else []),
          },
        } for agentName in std.objectFields(agents) 
      },
    },
  },
}
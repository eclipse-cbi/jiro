{
  kubernetes(config, agents): {
    kind: "kubernetes",
    namespace: config.kubernetes.agents.namespace, # should be changed to something agent-specific to fix #5
    podRetention: "never",
    templates: {
      local agent = agents[agentName], 
      [agentName]: agent.spec + agent.variants[config.jiroMaster.remoting.version] + {
        kubernetes: {
          resources: config.kubernetes.agents.defaultResources,
          local agentHome = agent.spec.home,
          volumes:  config.maven.Kube.volumes(agentHome) + (if config.gradle.generate then [
            {
              local dot_gradle = agentHome + "/.gradle",
              name: "gradle-secret-dir",
              configMap: { name: "gradle-secret-dir", },
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
}
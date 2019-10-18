local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Service("jenkins-discovery", config) {
    spec: {
      ports: [
        {
          name: "jnlp",
          port: config.deployment.jnlpPort,
          protocol: "TCP",
          targetPort: config.deployment.jnlpPort,
        },
      ],
      selector: {
        "org.eclipse.cbi.jiro/project.fullName": config.project.fullName
      },
    },
  },
}

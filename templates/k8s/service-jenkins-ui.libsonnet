local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Service("jenkins-ui", config) {
    spec: {
      ports: [
        {
          name: "http",
          port: 80,
          protocol: "TCP",
          targetPort: config.deployment.uiPort,
        },
      ],
      selector: {
        "org.eclipse.cbi.jiro/project.fullName": config.project.fullName
      },
    },
  },
}

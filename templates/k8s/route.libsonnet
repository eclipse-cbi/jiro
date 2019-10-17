local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Route(config.project.shortName, config) {
    metadata+: {
      annotations+: {
        "haproxy.router.openshift.io/timeout": "60s",
      },
    },
    spec: {
      host: config.deployment.host,
      path: config.deployment.prefix,
      port: {
        targetPort: "http"
      },
      tls: {
        insecureEdgeTerminationPolicy: "Redirect",
        termination: "edge",
      },
      to: {
        kind: "Service",
        name: "jenkins-ui",
        weight: 100,
      },
    },
  }
}



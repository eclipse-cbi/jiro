local Kube = import "kube.libsonnet";
{
  gen(config): Kube.RoleBinding(config.project.shortName, config) {
    roleRef: {
      kind: "Role",
      name: "jenkins-master-owner",
      namespace: config.kubernetes.master.namespace,
    },
    subjects: [
      {
        kind: "ServiceAccount",
        name: config.project.shortName,
        namespace: config.kubernetes.master.namespace,
      },
    ],
  },
}
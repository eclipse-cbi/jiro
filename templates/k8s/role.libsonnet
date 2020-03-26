local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Role("jenkins-master-owner", config) {
    rules: [
      {
        apiGroups: [""],
        resources: ["pods", "pods/exec"],
        verbs: ["create","delete","get","list","patch","update","watch"],
      },
      {
        apiGroups: [""],
        resources: ["pods/log", "events"],
        verbs: ["get","list","watch"],
      },
    ],
  }
}

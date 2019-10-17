local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Role("jenkins-master-owner", config) {
    rules: [
      {
        apiGroups: [""],
        resources: ["pods"],
        verbs: ["create","delete","get","list","patch","update","watch"],
      },
      {
        apiGroups: [""],
        resources: ["pods/exec"],
        verbs: ["create","delete","get","list","patch","update","watch"],
      },
      {
        apiGroups: [""],
        resources: ["pods/log"],
        verbs: ["get","list","watch"],
      },
    ],
  }
}

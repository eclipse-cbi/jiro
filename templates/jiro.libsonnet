local Kube = import "k8s/kube.libsonnet";
{
  "config.json": import "config.libsonnet",
  // Kubernetes files
  "k8s/resource-quotas.json": (import "k8s/resource-quotas.libsonnet").gen($["config.json"]),
  "k8s/limit-range.json": (import "k8s/limit-range.libsonnet").gen($["config.json"]),
  "k8s/role.json": (import "k8s/role.libsonnet").gen($["config.json"]),
  "k8s/role-binding.json": (import "k8s/role-binding.libsonnet").gen($["config.json"]),
  "k8s/namespace.json": (import "k8s/namespace.libsonnet").gen($["config.json"]),
  "k8s/route.json": (import "k8s/route.libsonnet").gen($["config.json"]),
  "k8s/service-account.json": (import "k8s/service-account.libsonnet").gen($["config.json"]),
  "k8s/service-jenkins-ui.json": (import "k8s/service-jenkins-ui.libsonnet").gen($["config.json"]),
  "k8s/service-jenkins-discovery.json": (import "k8s/service-jenkins-discovery.libsonnet").gen($["config.json"]),
  "k8s/known-hosts.json": (import "k8s/known-hosts.libsonnet").gen($["config.json"]),
  "k8s/m2-dir.json": (import "k8s/m2-dir.libsonnet").gen($["config.json"]),
  "k8s/tools-pv.json": Kube.List([ 
      (import "k8s/tools-pv.libsonnet").gen_pv($["config.json"]), 
      (import "k8s/tools-pv.libsonnet").gen_pvc($["config.json"]) 
  ]),
}
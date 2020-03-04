local Kube = import "k8s/kube.libsonnet";
local config = import "config.json";
{
  ".secrets/k8s/m2-secret-dir.json": (import "k8s/m2-secret-dir.libsonnet").gen(config),
} 
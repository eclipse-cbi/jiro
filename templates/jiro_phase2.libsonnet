local Kube = import "k8s/kube.libsonnet";
local config = import "config.json";
{
  ".secrets/k8s/m2-secret-dir.json": if (config.maven.generate) then (import "k8s/m2-secret-dir.libsonnet").gen(config),
  ".secrets/k8s/gradle-secret-dir.json": if (config.gradle.generate) then (import "k8s/gradle-secret-dir.libsonnet").gen(config),
} 
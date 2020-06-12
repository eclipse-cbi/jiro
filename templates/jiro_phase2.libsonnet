local Kube = import "k8s/kube.libsonnet";
local config = import "config.json";

{} + if (config.maven.generate) then {
  ".secrets/k8s/m2-secret-dir.json": (import "k8s/m2-secret-dir.libsonnet").gen(config),
  "k8s/m2-dir.json": (import "k8s/m2-dir.libsonnet").gen(config),
} else {} + if (config.gradle.generate) then {
  ".secrets/k8s/gradle-secret-dir.json": (import "k8s/gradle-secret-dir.libsonnet").gen(config),
} else {}

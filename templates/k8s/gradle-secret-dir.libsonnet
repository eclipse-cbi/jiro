local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Secret("gradle-secret-dir", config) {
    stringData: {
      "gradle.properties": importstr '.secrets/gradle/gradle.properties',
    }
  }
}

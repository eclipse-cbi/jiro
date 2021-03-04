local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Secret("sbt-secret-dir", config) {
    stringData: {
      ".credentials": importstr '.secrets/sbt/.credentials',
    }
  }
}

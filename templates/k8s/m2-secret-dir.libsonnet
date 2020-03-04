local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Secret("m2-secret-dir", config) {
    stringData: {
      "settings.xml": importstr '.secrets/maven/settings.xml',
      "settings-security.xml": importstr '.secrets/maven/settings-security.xml'
    }
  }
}

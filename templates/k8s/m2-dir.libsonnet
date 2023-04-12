local Kube = import "kube.libsonnet";
{
  gen(config): Kube.ConfigMap("m2-dir", config) {
    data: {
      ".mavenrc": importstr '.secrets/maven/.mavenrc',
      //toolchains.xml is generated in /jiro/build/gen-mvn-settings.sh
      "toolchains.xml": importstr '.secrets/maven/toolchains.xml',
    }
  }
}

local Kube = import "kube.libsonnet";
{
  gen(config): Kube.Secret("m2-secret-dir", config) {
    stringData: {
      "settings.xml": |||
        <?xml version="1.0" encoding="UTF-8"?>
        <settings>
          <mirrors>
            <mirror>
              <id>eclipse.maven.central.mirror</id>
              <name>Eclipse Central Proxy</name>
              <url>https://repo.eclipse.org/content/repositories/maven_central/</url>
              <mirrorOf>central</mirrorOf>
            </mirror>
          </mirrors>
        </settings>
      |||,
      "settings-security.xml": |||
        <?xml version="1.0" encoding="UTF-8"?>
      |||
      
    }
  }
}

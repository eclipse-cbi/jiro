local Kube = import "k8s/kube.libsonnet";
{
  dot_m2:: ".m2",
  dot_mavenrc:: ".mavenrc",
  settings_xml:: "settings.xml",
  settings_security_xml:: "settings-security.xml",
  maven_config_folder:: "/usr/share/jenkins-agent/maven",
  maven_secrets_folder:: "/run/secrets/jenkins-agent/maven",

  local thisModule = self,

  Maven: {
    local thisMaven = self,
    projectFullName:: error 'Must override "projectFullName"',

    generate: true,

    showversion: true,
    hideTransferLogs: true,
    interactiveMode: false,

    [thisModule.dot_mavenrc]: {
      setOptions:: [
        if thisMaven.showversion then '-V',
        if !thisMaven.interactiveMode then '--batch-mode',
        if thisMaven.hideTransferLogs then "-Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn",
        '"${@}"',
      ],
      content: "set -- %s" % std.join(" ", self.setOptions),
    },
    toolchains: {
      "toolchains.xml": importstr "toolchains.xml",
    },
    "settings-files": {
      [thisModule.settings_xml]: {
        servers: {
          "repo.eclipse.org": {
            username: {
              pass: "nexus/username",
            },
            password: {
              pass: "nexus/password",
            },
          },
          ossrh: {
            nexusProUrl: if std.startsWith(thisMaven.projectFullName, "ee4j") then "https://jakarta.oss.sonatype.org" else "https://oss.sonatype.org",
            username: {
              pass: "bots/" + thisMaven.projectFullName + "/oss.sonatype.org/username",
            },
            password: {
              pass: "bots/" + thisMaven.projectFullName + "/oss.sonatype.org/password",
            },
          },
          "gpg.passphrase": {
            passphrase: {
              pass: "bots/" + thisMaven.projectFullName + "/gpg/passphrase"
            },
          },
        },
        mirrors: {
          "eclipse.maven.central.mirror": {
            name: "Eclipse Central Proxy",
            url: "https://repo.eclipse.org/content/repositories/maven_central/",
            mirrorOf: "central",
          },
        },
      },
    },
    [thisModule.settings_security_xml]: {
      master: {
        pass: "bots/" + thisMaven.projectFullName + "/apache-maven-security-settings/master-password"
      },
    },

    symlinks:: 
      [ "%s/%s;${HOME}/%s" % [thisModule.maven_config_folder, thisModule.dot_mavenrc, thisModule.dot_mavenrc] ] +
      [ "%s/%s;${HOME}/%s/%s" % [thisModule.maven_config_folder, toolchain, thisModule.dot_m2, toolchain] for toolchain in std.objectFields(thisMaven.toolchains) ] +
      [ "%s/%s;${HOME}/%s/%s" % [thisModule.maven_secrets_folder, settings, thisModule.dot_m2, settings] for settings in std.objectFields(thisMaven["settings-files"]) ] +
      [ "%s/%s;${HOME}/%s/%s" % [thisModule.maven_secrets_folder, thisModule.settings_security_xml, thisModule.dot_m2, thisModule.settings_security_xml] ],

    Kube:: {
      local thisKube = self,
      m2_secret_dir:: "m2-secret-dir",
      m2_dir:: "m2-dir",

      configmaps(config):: Kube.ConfigMap(thisKube.m2_dir, config) {
        data: {
          [toolchain]: thisMaven.toolchains[toolchain] for toolchain in std.objectFields(thisMaven.toolchains) 
        } + {
          [thisModule.dot_mavenrc]: thisMaven[thisModule.dot_mavenrc],
          "symlinks": std.join("\n", thisMaven.symlinks),
        },
      },

      volumes(home):: if thisMaven.generate then [
        {
          name: thisKube.m2_secret_dir,
          secret: { name: thisKube.m2_secret_dir, },
          mountPath: thisModule.maven_secrets_folder,
          readOnly: true,
        },
        {
          name: thisKube.m2_dir,
          configMap: { name: thisKube.m2_dir, },
          mountPath: thisModule.maven_config_folder,
          readOnly: true,
        },
      ] else [],

      secrets(config):: Kube.Secret(thisKube.m2_secret_dir, config) {
        stringData: {
          [thisModule.settings_xml]: importstr '.secrets/maven/settings.xml',
          [thisModule.settings_security_xml]: importstr '.secrets/maven/settings-security.xml',
        }
      },
    },
  },
}
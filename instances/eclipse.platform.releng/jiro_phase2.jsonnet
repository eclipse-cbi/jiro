local jiro = import '../../templates/jiro_phase2.libsonnet';
jiro + {
  ".secrets/k8s/m2-secret-dir.json"+: super[".secrets/k8s/m2-secret-dir.json"] + {
    stringData+: {
      "settings-deploy-ossrh-jdt.xml": importstr '.secrets/maven/settings-deploy-ossrh-jdt.xml',
      "settings-deploy-ossrh-pde.xml": importstr '.secrets/maven/settings-deploy-ossrh-pde.xml',
      "settings-deploy-ossrh-releng.xml": importstr '.secrets/maven/settings-deploy-ossrh-releng.xml',
    },
  },
}
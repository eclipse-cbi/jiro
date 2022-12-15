local jiro = import '../../templates/jiro_phase2.libsonnet';
jiro + {
  ".secrets/k8s/m2-secret-dir.json"+: super[".secrets/k8s/m2-secret-dir.json"] + { 
    stringData+: {
      "settings-deploy-ossrh-docs.xml": importstr '.secrets/maven/settings-deploy-ossrh-docs.xml',
    },
  },
}
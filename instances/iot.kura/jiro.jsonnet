local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("iot.kura", "Eclipse Kura") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "clone-workspace-scm",
        "jacoco",
        "junit-attachments",
      ],
    },
  }
}

local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.egit", "Eclipse EGit") {
  "config.json"+: {
    project+: {
      resourcePacks: 2,
    },
    jenkins+: {
      theme: "quicksilver-light",
      plugins+: [
        "dashboard-view",
      ],
    }
  },
}

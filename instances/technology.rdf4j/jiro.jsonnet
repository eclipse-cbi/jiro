local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("technology.rdf4j", "Eclipse RDF4J") {
  "config.json"+: {
    jenkins+: {
      plugins+: [
        "dashboard-view",
      ],
    },
  },
}

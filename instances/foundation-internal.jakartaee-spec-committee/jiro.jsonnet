local jiro = import '../../templates/jiro.libsonnet';

jiro.newJiro("foundation-internal.jakartaee-spec-committee", "Jakarta EE Specification Committee") {
  project+: {
    unixGroupName: "jakartaee.spec-committee"
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
}

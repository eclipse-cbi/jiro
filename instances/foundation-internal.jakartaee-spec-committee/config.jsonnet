local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    shortName: "jakartaee-spec-committee",
    fullName: "foundation-internal.jakartaee-spec-committee",
    displayName: "Jakarta EE Specification Committee",
    unixGroupName: "jakartaee.spec-committee"
  },
  "secrets": {
    "gerrit-trigger-plugin": {
      "username": ""
    }
  }
}

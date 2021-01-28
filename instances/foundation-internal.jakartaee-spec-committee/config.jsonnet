{
  project+: {
    fullName: "foundation-internal.jakartaee-spec-committee",
    displayName: "Jakarta EE Specification Committee",
    unixGroupName: "jakartaee.spec-committee"
  },
  deployment+: {
    cluster: "okd-c1",
  },
  secrets+: {
    "gerrit-trigger-plugin": {},
  },
}

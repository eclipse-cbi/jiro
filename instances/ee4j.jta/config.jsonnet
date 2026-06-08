local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "ee4j.jta",
    displayName: "Jakarta Transactions",
  },
  jenkins+: {
    plugins+: [
      "copyartifact",
    ],
    permissions+:
      permissionsTemplates.user("aidentzhang@gmail.com", ["Overall/Read", "Job/Read"]),
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c45,c10",
}

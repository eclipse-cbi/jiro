local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "modeling.cdo",
    displayName: "Eclipse CDO Model Repository",
  },
  jenkins+: {
    plugins+: [
      "build-name-setter",
      "mail-watcher-plugin",
      "pipeline-utility-steps",
      "zentimestamp",
    ],
    permissions+:
      permissionsTemplates.user("cdo-trigger-bot@eclipse.org", ["Overall/Read", "Job/Read"])
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c31,c30",
}

local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.justj",
    displayName: "Eclipse JustJ",
  },
  jenkins+: {
    permissions+:
      permissionsTemplates.user("ed.merks@gmail.com", ["Agent/Connect", "Agent/Disconnect"]),
    plugins+: [
      "build-with-parameters",
      "mail-watcher-plugin",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c45,c25",
}

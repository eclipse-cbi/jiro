local permissionsTemplates = import '../../templates/permissions.libsonnet';
{
  project+: {
    fullName: "technology.tycho",
    displayName: "Eclipse Tycho",
    resourcePacks: 6,
  },
  jenkins+: {
    permissions+:
      // https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/1110#note_648658
      permissionsTemplates.user("laeubi@laeubi-soft.de", ["Agent/Connect", "Agent/Disconnect", "Agent/ExtendedRead"])
  },
  seLinuxLevel: "s0:c56,c10",
  storage: {
    storageClassName: "managed-nfs-storage-bambam-retain-policy",
  }
}

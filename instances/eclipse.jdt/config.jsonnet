local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "eclipse.jdt",
    displayName: "Eclipse Java Development Tools (JDT)",
    resourcePacks: 3,
  },
  jenkins+: {
    permissions: 
      permissionsTemplates.group("admins", ["Overall/Administer"]) +
      permissionsTemplates.group("common", ["Overall/Read", "Job/Read", "Job/ExtendedRead"]) +
      permissionsTemplates.group($.project.unixGroupName, permissionsTemplates.committerPermissionsList)
    ,
    plugins+: [
      "gerrit-code-review",
      "github-checks",
      "git-forensics",
    ],
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c43,c37",
}

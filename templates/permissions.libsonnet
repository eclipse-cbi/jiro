{
  projectPermissions(unixGroupName, projectGroupPermissionsList): [
    {
      principal: "anonymous",
      grantedPermissions: [
        "Overall/Read",
        "Job/Read"
      ]
    },
    {
      principal: "common",
      grantedPermissions: [
        "Job/ExtendedRead"
      ]
    },
    {
      principal: "admins",
      grantedPermissions: [
        "Overall/Administer"
      ]
    },
    {
      principal: unixGroupName,
      grantedPermissions: projectGroupPermissionsList,
    },
  ],

  committerPermissionsList::
  [
    "Agent/Build",
    "Credentials/View",
    "Job/Build",
    "Job/Cancel",
    "Job/Configure",
    "Job/Create",
    "Job/Delete",
    "Job/Move",
    "Job/Read",
    "Job/Workspace",
    "Run/Delete",
    "Run/Replay",
    "Run/Update",
    "SCM/Tag",
    "View/Configure",
    "View/Create",
    "View/Delete",
    "View/Read",
  ],
}
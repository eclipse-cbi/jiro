{
  project+: {
    fullName: "technology.dash",
    displayName: "Eclipse Dash",
  },
  jenkins+: {
    permissions: [
      {
        grantedPermissions: 
          if x.principal == "anonymous" then 
            [ "Overall/Read", ] 
          else if x.principal == "common" then 
            x.grantedPermissions + ["Job/Read"]
          else 
            x.grantedPermissions,
        principal: x.principal
      } for x in super.permissions 
    ] + [
      {
        principal: "frederic.gurr@eclipse-foundation.org",
        grantedPermissions: [
          "Overall/Administer"
        ]
      }
    ],
  },
}
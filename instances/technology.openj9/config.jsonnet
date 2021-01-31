local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.openj9",
    displayName: "Eclipse OpenJ9",
  },
  jenkins+: {
    staticAgentCount: 50,
    permissions: permissionsTemplates.projectPermissions($.project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"]) + [
      {
        principal: "adam.brousseau88@gmail.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure"]
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=559384
          + ["Job/Configure"]
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=567291
          + ["Job/Build", "Job/Cancel", "Agent/Build"], 
      },
      {
        principal: "joe_dekoning@ca.ibm.com",
        grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure"]
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=559384
          + ["Job/Configure"]
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=567291
          + ["Job/Build", "Job/Cancel", "Agent/Build"], 
      },
      {
        principal: "peter_shipton@ca.ibm.com",
        grantedPermissions: ["Agent/Configure"],
      },
      {
        principal: "heidinga@redhat.com",
        grantedPermissions: ["Agent/Configure"],
      },
      {
        principal: "vsebe@ca.ibm.com",
        grantedPermissions: 
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=559384
          ["Job/Configure"]
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=559384#c3
          + ["Agent/Configure", "Agent/Connect", "Agent/Disconnect"]
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=567291
          + ["Job/Build", "Job/Cancel", "Agent/Build"], 
      },
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=553268
        principal: "rajdeep.singh@ibm.com",
        grantedPermissions: ["Agent/Configure", "Agent/Connect", "Agent/Disconnect"],
      },
      {
        // https://bugs.eclipse.org/bugs/show_bug.cgi?id=569487
        principal: "ben@benthomas.ca",
        grantedPermissions: ["Job/Build", "Job/Cancel"],
      },
    ],
    plugins+: [
      "artifactory",
      "badge",
      "build-user-vars-plugin",
      "copyartifact",
      "embeddable-build-status",
      "generic-webhook-trigger",
      "groovy-postbuild",
      "http_request",
      "jira",
      "job-dsl",
      "pipeline-utility-steps",
      "slack",
      "tap",
      "build-with-parameters",
      "xvfb",
      "monitoring ",
    ],
  },
}

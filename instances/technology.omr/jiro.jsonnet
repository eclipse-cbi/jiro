local jiro = import '../../templates/jiro.libsonnet';
local permissionsTemplates = import '../../templates/permissions.libsonnet';

jiro.newJiro("technology.omr", "Eclipse OMR") {
  "config.json"+: {
    jenkins+: {
      staticAgentCount: 40,
      permissions: permissionsTemplates.projectPermissions($["config.json"].project.unixGroupName, permissionsTemplates.committerPermissionsList + ["Agent/Connect", "Agent/Disconnect"]) + [
        {
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
          principal: "adam.brousseau88@gmail.com",
          grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Configure", "Job/Build", "Job/Cancel", "Overall/SystemRead"],
        },
        {
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
          principal: "joe_dekoning@ca.ibm.com",
          grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure", "Agent/Build", "Job/Configure", "Job/Build", "Job/Cancel"],
        },
        {
          // https://bugs.eclipse.org/bugs/show_bug.cgi?id=570552
          principal: "rajdeep.singh@ibm.com",
          grantedPermissions: ["Agent/Connect", "Agent/Disconnect", "Agent/Configure"],
        },
      ],
      plugins+: [
        "embeddable-build-status",
        "envinject",
        "generic-webhook-trigger",
        "gradle",
      ],
    },
  },
  "k8s/statefulset.json"+: import "k8s/statefulset.jsonnet",
}

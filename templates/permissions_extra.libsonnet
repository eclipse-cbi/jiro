local release_coordinator_jipps() = [
  "ee4j.authentication",
  "ee4j.authorization",
  "ee4j.ca",
  "ee4j.cdi",
  "ee4j.cu",
  "ee4j.data",
  "ee4j.ejb",
  "ee4j.el",
  "ee4j.faces",
  "ee4j.interceptors",
  "ee4j.jaf",
  "ee4j.jakartaconfig",
  "ee4j.jakartaee-platform",
  "ee4j.jaxb",
  "ee4j.jaxws",
  "ee4j.jca",
  "ee4j.jpa",
  "ee4j.jsonb",
  "ee4j.jsonp",
  "ee4j.jsp",
  "ee4j.jstl",
  "ee4j.jta",
  "ee4j.mail",
  "ee4j.messaging",
  "ee4j.mvc",
  "ee4j.nosql",
  "ee4j.rest",
  "ee4j.security",
  "ee4j.servlet",
  "ee4j.validation",
  "ee4j.websocket",
];

local release_coordinator_permissions() = [
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
  "Overall/Read",
  "Run/Delete",
  "Run/Replay",
  "Run/Update",
  "SCM/Tag",
  "View/Configure",
  "View/Create",
  "View/Delete",
  "View/Read"
];

{
  additionalPermissions(projectFullName):
    # ee4j JIPPs where release coordinators get special permissions
    # See also: https://gitlab.eclipse.org/eclipsefdn/helpdesk/-/issues/3910
    if std.member(release_coordinator_jipps(), projectFullName) then [{
      user: {
        name: "edward.burns@microsoft.com",
        permissions: release_coordinator_permissions()
      },
    }, {
      user: {
        name: "arjan.tijms@omnifish.ee",
        permissions: release_coordinator_permissions()
      }
    }] else []

}

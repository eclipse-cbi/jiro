# Documentation

## Administration

Please note, the following commands can only be executed if you have direct access to the build cluster environment.

### Create a new Jenkins instance

Run `jenkins-new-instance.sh <project_id> '<project_display_name>'`

e.g. for Eclipse CBI: `jenkins-new-instance.sh technology.cbi 'Eclipse CBI'`

### Deploy a Jenkins instance

Run `make deploy_<project_id>`

e.g. for Eclipse CBI JIPP: `make deploy_technology.cbi`

### Reload one or more Jenkins instance(s)

Run `jenkins-reload.sh <project_id> [<project_id2>]`

e.g. for Eclipse CBI JIPP: `jenkins-reload.sh technology.cbi`





## Jenkins instance configuration options

Every Jenkins instance has it's own folder under instances/<project_id>, which contains a `config.jsonnet` file.

A minimal configuration in [instances/technology.cbi/config.jsonnet](https://github.com/eclipse-cbi/jiro/tree/master/instances/technology.cbi/config.jsonnet) would look like this: 

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI"
  }
}
```

Executing `make deploy_<project_id>` in the Jiro root directory, creates all necessary files in the target folder utilizing templates from
the [templates/](https://github.com/eclipse-cbi/jiro/tree/master/templates) directory.

Most configuration options are set by default and only need to be specified if they differ from the default.

### Set a specific Jenkins version

By default the latest Jenkins version specified in [https://github.com/eclipse-cbi/jiro-masters/masters.jsonnet](https://github.com/eclipse-cbi/jiro-masters/blob/master/masters.jsonnet#L13) is used.
For testing purposes or in case of a regression, other versions can be specified.

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    version: "2.263.3",
  }
}
```

### Additional Jenkins plugins

List of plugins that are installed by default: [https://github.com/eclipse-cbi/jiro-masters/jiro.libsonnet](https://github.com/eclipse-cbi/jiro-masters/blob/master/jiro.libsonnet#L48)

Additional plugins can be specified like this:

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    plugins+: [
      "cloudbees-disk-usage-simple",
      "embeddable-build-status",
    ],
  },
}
```

### Resource packs

Additional resource packs can be configured.

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
    resourcePacks: 3,
  },
}
```

**Please note:** by default, one resource pack is granted. If the project requests one additional resource packs, you need to specify the absolute number (2).

### Adapt Jenkins controller resources according to the number of static agents

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    staticAgentCount: 3,
  }
}
```

### Set additional permissions

By default the LDAP group is determined by the `fullName` of the project.
All members of the LDAP group get committer-level permissions, e.g. reading, configuring and starting jobs.

If the LDAP group differs from the `fullName` it can be set explicitly like this:

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
    unixGroupName: "eclipse.cbi"
  }
}
```

If people, who are not committers on the project, should get access to a Jenkins instance or committers should get additional permissions, they can be added individually:

```jsonnet
local permissionsTemplates = import '../../templates/permissions.libsonnet';

{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    permissions+: 
      permissionsTemplates.projectPermissions("webmaster@eclipse.org", ["Agent/Connect", "Agent/Disconnect"])
  }
}
```

**Please note:** requests for adding non-committers require a +1 from a project lead.


### Set light theme

Jiro instances use a dark theme by default. If you are afraid of the dark, you can set a light theme.

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  jenkins+: {
    theme: "quicksilver-light",
  }
}
```

### Set deployment options

Specific deployment options like host, prefix or cluster can be set.

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  deployment+: {
    host: "foundation.eclipse.org",
    prefix: "/ci/"+ $.project.shortName,
    cluster: "okd-c1",
  }
}
```

### Build tools

#### Maven

Maven specific folders/configurations are created by default.

#### Gradle

Create Gradle specific folders/configurations (e.g. ~/.gradle)

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  gradle+: {
    generate: true,
  }
}
```

#### sbt

Create sbt specific folders/configurations (e.g. ~/.sbt)

```jsonnet
{
  project+: {
    fullName: "technology.cbi",
    displayName: "Eclipse CBI",
  },
  sbt+: {
    generate: true,
  }
}
```

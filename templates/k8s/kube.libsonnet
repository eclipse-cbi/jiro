{
  __:: {
    KubeObject(apiVersion, kind, name, config):: {
      local this = self,
      apiVersion: apiVersion,
      kind: kind,
      metadata: {
        name: name,
        labels: {
          "org.eclipse.cbi.jiro/project.shortname": config.project.shortName,
          "org.eclipse.cbi.jiro/project.fullName": config.project.fullName,
        },
      },
    },

    KubeNSObject(apiVersion, kind, name, config):: self.KubeObject(apiVersion, kind, name, config) + {
      metadata+: {
        namespace: config.kubernetes.master.namespace,
      },
    },
  },

  LimitRange(name, config): $.__.KubeNSObject("v1", "LimitRange", name, config),
  ResourceQuota(name, config): $.__.KubeNSObject("v1", "ResourceQuota", name, config),
  Namespace(name, config): $.__.KubeObject("v1", "Namespace", name, config),
  RoleBinding(name, config): $.__.KubeNSObject("v1", "RoleBinding", name, config),
  Role(name, config): $.__.KubeNSObject("v1", "Role", name, config),
  Route(name, config): $.__.KubeNSObject("route.openshift.io/v1", "Route", name, config),

  stripSI(n):: (
    local suffix_len =
      if std.endsWith(n, "m") then 1
      else if std.endsWith(n, "K") then 1
      else if std.endsWith(n, "M") then 1
      else if std.endsWith(n, "G") then 1
      else if std.endsWith(n, "T") then 1
      else if std.endsWith(n, "P") then 1
      else if std.endsWith(n, "E") then 1
      else if std.endsWith(n, "Ki") then 2
      else if std.endsWith(n, "Mi") then 2
      else if std.endsWith(n, "Gi") then 2
      else if std.endsWith(n, "Ti") then 2
      else if std.endsWith(n, "Pi") then 2
      else if std.endsWith(n, "Ei") then 2
      else error "Unknown numerical suffix in " + n;
    local n_len = std.length(n);
    std.parseInt(std.substr(n, 0, n_len - suffix_len))
  ),

  pair_list_ex(tab, kfield, vfield)::
    [{ [kfield]: k, [vfield]: tab[k] } for k in std.objectFields(tab)],

  pair_list(tab)::
    self.pair_list_ex(tab, "name", "value"),
}
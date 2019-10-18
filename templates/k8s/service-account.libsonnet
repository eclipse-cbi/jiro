local Kube = import "kube.libsonnet";
{
  gen(config): 
    Kube.ServiceAccount(config.project.shortName, config)
}
local Kube = import "kube.libsonnet";
{
  gen(config): 
    Kube.Namespace(config.kubernetes.master.namespace, config)
}
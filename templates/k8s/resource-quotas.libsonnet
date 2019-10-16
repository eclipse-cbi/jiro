local Kube = import "kube.libsonnet";
local Const = import "resource-packs.libsonnet";
{
  gen(config): Kube.ResourceQuota('jenkins-instance-quota', config) {
    spec: {
      local spec = self,
      quotas_cpu::Const.pack_cpu*config.project.resourcePacks,
      quotas_mem::Const.pack_mem*config.project.resourcePacks,
      hard: {
        pods: 1 + config.jenkins.maxConcurrency,
        //"requests.storage": "%dGi" % (Const.master_hdd + config.project.resourcePacks * Const.pack_hdd),
        "requests.cpu": "%dm" % (Kube.stripSI(config.kubernetes.master.resources.cpu.request) + config.jenkins.maxConcurrency * Const.jnlp_cpu + spec.quotas_cpu),
        "requests.memory": "%dMi" % (Kube.stripSI(config.kubernetes.master.resources.memory.request) + config.jenkins.maxConcurrency * Const.jnlp_mem + spec.quotas_mem),
        "limits.cpu": "%dm" % (Kube.stripSI(config.kubernetes.master.resources.cpu.limit) + config.jenkins.maxConcurrency * (Const.jnlp_cpu * Const.jnlp_cpu_burst + Kube.stripSI(config.kubernetes.agents.defaultResources.cpu.limit))),
        "limits.memory": self["requests.memory"],
      },
    },
  },
}

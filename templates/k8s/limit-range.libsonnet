local Kube = import "kube.libsonnet";
local Const = import "resource-packs.libsonnet";
{
  gen(config): Kube.LimitRange("jenkins-instance-limit-range", config) {
    spec: {
      local spec = self,
      quotas_cpu::Const.pack_cpu*config.project.resourcePacks,
      quotas_mem::Const.pack_mem*config.project.resourcePacks,
      limits: [
        { 
          type: "Pod",
          min: {
            cpu: "200m",
            memory: "8Mi",
          },
          max: {
            cpu: "%dm" % std.max(Kube.stripSI(config.kubernetes.master.resources.cpu.limit), std.min(Const.agent_max_cpu_per_pod_or_container, spec.quotas_cpu) + Const.jnlp_cpu),
            memory: "%dMi" % std.max(Kube.stripSI(config.kubernetes.master.resources.memory.limit), std.min(Const.agent_max_mem_per_pod_or_container, spec.quotas_mem) + Const.jnlp_mem),
          },
        }, {
          type: "Container",
          min: {
            cpu: "100m",
            memory: "16Mi",
          },
          default: {
            cpu: "%dm" % (Const.jnlp_cpu * Const.jnlp_cpu_burst),
            memory: "%dMi" % Const.jnlp_mem,
          },
          defaultRequest: {
            cpu: "%dm" % (Const.jnlp_cpu),
            memory: "%dMi" % Const.jnlp_mem,
          },
          max: {
            cpu: "%dm" % std.max(Kube.stripSI(config.kubernetes.master.resources.cpu.limit), std.min(Const.agent_max_cpu_per_pod_or_container, spec.quotas_cpu)),
            memory: "%dMi" % std.max(Kube.stripSI(config.kubernetes.master.resources.memory.limit), std.min(Const.agent_max_mem_per_pod_or_container, spec.quotas_mem)),
          },
        },
      ],
    },
  },
}

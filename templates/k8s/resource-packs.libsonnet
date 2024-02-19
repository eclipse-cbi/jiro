{
  // Resource pack definition
  pack_cpu::2000,
  pack_mem::8*1024,
  pack_hdd::100,

  // Resource constants for Jenkins master
  master_base_cpu_req::250,
  master_max_cpu_req::4000,
  master_min_cpu_limit::2000,
  master_cpu_burst::2,
  master_hdd::100,
  
  master_base_mem::1024,
  master_max_mem::8*1024,
  
  master_cpu_per_agent::150,
  master_mem_per_agent::256,
  master_min_agent_for_additional_resources::2,
  

  // Resource constants for Jenkins dynamic agents
  agent_max_cpu_per_pod_or_container::8000,
  agent_max_mem_per_pod_or_container::16*1024, 
  agent_min_cpu_limit::2000,
  jnlp_cpu_burst::1.5,
  jnlp_cpu::200,
  jnlp_mem::512,

}
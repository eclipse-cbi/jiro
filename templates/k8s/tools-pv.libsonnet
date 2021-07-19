local Kube = import "kube.libsonnet";
{
  storageClassName::"bbzcxird03bsb81s-tools",

  gen_pv(config): Kube.PersistentVolume("tools-jiro-"+config.project.shortName, config) {
    spec: {
      storageClassName: $.storageClassName,
      capacity: {
        storage: "20Gi",
      },
      accessModes: [
        "ReadOnlyMany",
      ],
      claimRef: {
        namespace: config.kubernetes.master.namespace,
        name: "tools-claim-jiro-"+config.project.shortName,
      },
      nfs: {
        server: "bambam",
        path: "/home/data/cbi/buildtools",
        readOnly: true,
      },
      mountOptions: [
        "vers=4.2", "rw", "proto=tcp", "rsize=32768", "wsize=32768", "timeo=600", "fg", "hard", "retrans=10", "intr", "relatime", "nodiratime", "async",
      ],
    },
  },

  gen_pvc(config): Kube.PersistentVolumeClaim("tools-claim-jiro-"+config.project.shortName, config) {
    spec: {
      storageClassName: $.storageClassName,
      accessModes: [
        "ReadOnlyMany",
      ],
      resources: {
        requests: {
          storage: "20Gi",
        },
      },
    },
  },
}


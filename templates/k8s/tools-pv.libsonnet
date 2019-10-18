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
        path: "/home/data/c1-ci.eclipse.org/buildtools",
        readOnly: true,
      },
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


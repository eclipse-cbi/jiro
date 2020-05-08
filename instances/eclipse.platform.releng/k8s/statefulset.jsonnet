{
  spec+: {
    template+: {
      spec+: {
        containers: [
          x + {
            volumeMounts+: [
              {
                mountPath: "/var/jenkins/.ssh",
                name: "master-known-hosts",
              }
            ],
          } for x in super.containers
        ], 
        volumes+: [
          {
            name: "master-known-hosts",
            configMap: {
              name: "master-known-hosts",
            },
          },
        ],
      },
    },
  },
}
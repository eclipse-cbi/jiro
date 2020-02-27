{
  spec+: {
    template+: {
      spec+: {
        containers: [
          x + {
            volumeMounts+: [
              {
                mountPath: "/var/jenkins_home/.ssh",
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
{
  releases: {
    [r.jenkins.version]: r for r in [
      import "2.204.3/build-args.jsonnet",
      import "2.190.1/build-args.jsonnet",
    ]
  } + {
    latest: $.releases["2.190.1"],
  }
}

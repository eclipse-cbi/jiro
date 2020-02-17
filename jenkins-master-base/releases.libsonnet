{
  releases: {
    [r.jenkins.version]: r for r in [
      import "2.190.1/build-args.json",
      import "2.176.2/build-args.json",
      import "2.176.1/build-args.json",
    ]
  } + {
    latest: $.releases["2.190.1"],
  }
}

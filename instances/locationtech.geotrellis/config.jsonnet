{
  project+: {
    fullName: "locationtech.geotrellis",
    displayName: "LocationTech GeoTrellis",
  },
  deployment+: {
    host: "ci.eclipse.org",
    cluster: "okd-c1",
  },
  sbt+: {
    generate: true,
  }
}

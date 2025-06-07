{
  project+: {
    fullName: "locationtech.geotrellis",
    displayName: "LocationTech GeoTrellis",
  },
  sbt+: {
    generate: true,
  },
  storage: {
    storageClassName: "cephfs-new-retain",
  },
  seLinuxLevel: "s0:c40,c25",
}

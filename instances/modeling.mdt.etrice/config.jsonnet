local default = import '../../templates/default.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mdt.etrice",
    shortName: "etrice",
    displayName: "Eclipse eTrice"
  },
  "gradle": {
    "home": "/home/jenkins/.gradle",
    "files": {
      "gradle.properties": {
        "volumeType": "Secret",
        "volumeName": "gradle-secret-dir"
      }
    }
  }
}

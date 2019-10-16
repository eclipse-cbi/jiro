local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "ee4j.faces",
    shortName: "faces",
    displayName: "Jakarta Server Faces"
  }
}

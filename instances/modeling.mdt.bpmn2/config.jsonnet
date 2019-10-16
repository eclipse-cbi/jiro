local default = import '../../templates/config.libsonnet';

default+ {
  project+: {
    fullName: "modeling.mdt.bpmn2",
    shortName: "bpmn2",
    displayName: "Eclipse BPMN2"
  }
}

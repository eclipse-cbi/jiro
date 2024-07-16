local jiro = import '../../templates/jiro.libsonnet';

jiro+ {
  "config.json"+: import "config.jsonnet",
  "k8s/statefulset.json"+: import "../eclipse.platform.releng/k8s/statefulset.jsonnet",
}
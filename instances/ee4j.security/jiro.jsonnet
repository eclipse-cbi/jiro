local jiro = import '../../templates/jiro.libsonnet';

jiro+ {
  "config.json"+: import "config.jsonnet",
}
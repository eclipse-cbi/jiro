// check update center for updates

println "  Checking for updates..."
jenkins.model.Jenkins.getInstance().getUpdateCenter().getSites().each { site ->
  site.updateDirectlyNow(hudson.model.DownloadService.signatureCheck)
}

hudson.model.DownloadService.Downloadable.all().each { downloadable ->
  downloadable.updateNow();
}

// Find plugins that can be updated
def plugins = jenkins.model.Jenkins.instance.pluginManager.activePlugins.findAll {
  it -> it.hasUpdate()
}.collect {
  it -> it.getShortName()
}

// remove 'promoted-builds' plugin from list and don't update it
plugins -= 'promoted-builds'

// println "  Found ${plugins.size()} plugins that can be updated: ${plugins}"
println "  Found ${plugins.size()} plugins that can be updated."
long count = 0

// update plugins
println "  Updating plugins..."
jenkins.model.Jenkins.instance.pluginManager.install(plugins, false).each { f ->
  f.get()
  println "    ${++count}/${plugins.size()}.."
}

// Find plugins that are deprecated
def deprecated_plugins = jenkins.model.Jenkins.instance.pluginManager.activePlugins.findAll {
  it -> it.isDeprecated()
}.collect {
  it -> it.getShortName()
}

println "  Found ${deprecated_plugins.size()} plugins that are deprecated."
println "  " + deprecated_plugins

// uninstall deprecated plugins
println "  Uninstalling deprecated plugins..."
long counter = 0
deprecated_plugins.each{
  jenkins.model.Jenkins.instance.pluginManager.getPlugin(it).doDoUninstall()
  println "    ${++counter}/${deprecated_plugins.size()}.."
}

// safe restart

println "  Restarting safely..."
println ""

if(plugins.size() != 0 && count == plugins.size()) {
  //TODO: set restart reason
  // doQuietDown(boolean block, int timeout, String reason) ??
  jenkins.model.Jenkins.instance.safeRestart()
}
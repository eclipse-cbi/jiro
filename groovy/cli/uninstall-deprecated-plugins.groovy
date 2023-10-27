// check update center for updates
jenkins.model.Jenkins.getInstance().getUpdateCenter().getSites().each { site ->
  site.updateDirectlyNow(hudson.model.DownloadService.signatureCheck)
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

if(deprecated_plugins.size() != 0 && counter == deprecated_plugins.size()) {
  //TODO: set restart reason
  // doQuietDown(boolean block, int timeout, String reason) ??
  jenkins.model.Jenkins.instance.safeRestart()
}
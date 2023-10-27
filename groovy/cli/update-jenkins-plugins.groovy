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

// safe restart

println "  Restarting safely..."
println ""

if(plugins.size() != 0 && count == plugins.size()) {
  //TODO: set restart reason
  // doQuietDown(boolean block, int timeout, String reason) ??
  jenkins.model.Jenkins.instance.safeRestart()
}
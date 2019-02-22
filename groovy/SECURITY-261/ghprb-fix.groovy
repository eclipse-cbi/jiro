/*
The MIT License

Copyright (c) 2018, CloudBees, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import jenkins.model.*
import hudson.security.*
import hudson.model.AbstractProject
import hudson.model.AbstractBuild
import hudson.model.CauseAction

// check plugin installed and version for GitHub-PR-builder

def pluginGhprb = Jenkins.instance.pluginManager.activePlugins.find{ it.getShortName() == 'ghprb' }
if(!pluginGhprb){
  println "You do not have the [ghprb] plugin and so does not seem to be vulnerable, if you had installed it, please comment this check"
  return
}

def pluginVersion = pluginGhprb?.getVersionNumber()
if(pluginVersion && pluginVersion.isOlderThan(new hudson.util.VersionNumber("1.40.0"))){
  println "The plugin [ghprb:${pluginVersion}] is vulnerable, please upgrade at least to [1.40.0] and re-run this script."
  return
}

println ''

int totalNumberOfBuilds = 0
int totalNumberOfCorrectedBuilds = 0
int totalNumberOfFailedBuilds = 0

Jenkins.instance.getAllItems(AbstractProject).each { AbstractProject project ->
  println "Project=[${project.name}] of type=[${project.class.simpleName}]"
  
  boolean affected = false
  AbstractBuild build = project.getLastBuild()
  while(build != null){
    print "\t#${build.number} of type [${build.class.simpleName}] " 
    
    List<CauseAction> causeActions = build.getActions(CauseAction)
     
    totalNumberOfBuilds++
    if(causeActions.any{ it.findCause(org.jenkinsci.plugins.ghprb.GhprbCause) != null }){
      try{
        build.save()
        
        totalNumberOfCorrectedBuilds++
        println "affected, re-saved to erase clear-text credentials"
      }catch(e){
        println "affected, but save FAILED due to ${e.message}"
        e.printStackTrace()
       	totalNumberOfFailedBuilds++
      }
      
      affected = true
    }else{
      println "not affected" 
    }
    
    build = build.getPreviousBuild()
  }

  println "=> ${affected ? 'affected' : 'not affected'}"
  println ''
}

println "Builds found: ${totalNumberOfBuilds}, affected and corrected: ${totalNumberOfCorrectedBuilds}"
if(totalNumberOfFailedBuilds > 0){
  println "  some build save failed, please look above for details of which builds was not saved correctly"
}
return
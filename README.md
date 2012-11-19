mcollective-agents
==================

A collection of my Agents for Marionette Collective, licensed
under the Apache Software License 2.0, see NOTICE.

To install/use, drop this mcollective folder directly into your
mcollective libdir.

Nexus Deployer
==============

Deploy a Java web app residing in a Nexus repository.

    mco nexusdpl dpl app=jenkins group=jenkins.org repo=all context=/jenkins restart=tomcat7-jenkins

Configuration:

* plugin.nexusdpl.nexus_url
* plugin.nexusdpl.user
* plugin.nexusdpl.passwd
* config.nexusdpl.repo


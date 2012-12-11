class MCollective::Application::Nexusdpl<MCollective::Application
  exclude_argument_sections "common"
  description "Install and uninstall software packages"
  usage "mco nexusdpl [options] [filters] app=<mvn-id> [<key=val> <key=val> ...]"

  option :app,
    :description    => "Which application (identified by Maven-ID) to deploy?",
    :arguments      => ["--app APP"],
    :required       => true

  option :context,
    :description    => "Which tomcat context to install this app to",
    :arguments      => ["--context CONTEXT"]

  option :path,
    :description    => "full path where to put the deployable",
    :arguments      => ["--path PATH"]

  option :version,
    :description    => "Which exact version of this app to install",
    :arguments      => ["--version VERSION"],
    :default        => "LATEST"

  option :ext,
    :description    => "Which extension does this app have?",
    :arguments      => ["--ext EXTENSION"],
    :default        => "war"

  option :repo,
    :description    => "Which repository to install this app from",
    :arguments      => ["--repo REPO"]

  option :restart,
    :description    => "restart this tomcat, after successful deployment",
    :arguments      => ["--restart TOMCAT"]

  def post_option_parser(configuration) 
  end

  def validate_configuration(configuration)
    if MCollective::Util.empty_filter?(options[:filter])
      STDERR.print "Cowardly refusing to run nexusdpl unfiltered\n"
      exit!
    end
  end

  def main
    mc = rpcclient('nexusdpl', {:options => options})
    printrpc mc.dpl(configuration) # we could yield here and do something fancy for each node.
    printrpcstats
    halt mc.stats
  end
end

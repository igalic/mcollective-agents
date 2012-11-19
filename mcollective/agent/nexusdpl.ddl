metadata    :name        => "nexusdpl",
  :description => "Nexus Deployment Manager",
  :author      => "Igor Galić <i.galic@brainsware.org>",
  :license     => "Apache 2",
  :version     => "0.1",
  :url         => "http://www.puppetlabs.com/mcollective",
  :timeout     => 60


action "dl", :description => "Download specified artefact (and check SHA1 sum)" do
  input :app,
    :prompt      => "App to download",
    :description => "Download this application",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => false,
    :maxlength   => 256

  input :group,
    :prompt      => "Maven Group",
    :description => "Download application from this Maven Group",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => false,
    :maxlength   => 256

  input :repo,
    :prompt      => "Repository to download from",
    :description => "Download application from this repository. (Default: config.nexusdpl.repo)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :version,
    :prompt      => "Version of app to download",
    :description => "Download application in this specific version. (Default: LATEST)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :ext,
    :prompt      => "Extension of app",
    :description => "What extension does this app have? (Default: war)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  output :tempfile,
    :description => "Path to downloaded tempfile",
    :display_as  => "Path"
end

action "dpl", :description => "Deploy specified artefact to application server" do
  input :app,
    :prompt      => "App to download",
    :description => "Download this application",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => false,
    :maxlength   => 256

  input :group,
    :prompt      => "Maven Group",
    :description => "Download application from this Maven Group",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => false,
    :maxlength   => 256

  input :repo,
    :prompt      => "Repository to download from",
    :description => "Download application from this repository. (Default: config.nexusdpl.repo)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :version,
    :prompt      => "Version of app to download",
    :description => "Download application in this specific version. (Default: LATEST)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :ext,
    :prompt      => "Extension of app",
    :description => "What extension does this app have? (Default: war)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :context,
    :prompt      => "Context of this App",
    :description => "What context should this app be deployed to? (Default: /$app)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :path,
    :prompt      => "Filesystem path to place this artefact to",
    :description => "What filesystem path should this app be deployed to? (Default: /opt/tomcats/$app/webapps/$app.$ext)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  input :restart,
    :prompt      => "Restart application container?",
    :description => "Should the application container be restarted, and if so, which? (Default: no. Specifi, e.g.: tomcat7-$app)",
    :type        => :string,
    :validation  => '^.+$',
    :optional    => true,
    :maxlength   => 256

  output :error,
    :description => "Reason for failure described in status",
    :display_as  => "error",
    :default     => ''

  output :trace,
    :description => "Full back trace",
    :display_as  => "trace",
    :default     => ''
end


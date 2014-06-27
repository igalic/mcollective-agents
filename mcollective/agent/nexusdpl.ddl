#  Copyright 2012 Igor Galić and contributors
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

metadata    :name        => "nexusdpl",
  :description => "Nexus Deployment Manager",
  :author      => "Igor Galić <i.galic@brainsware.org>",
  :license     => "Apache 2",
  :version     => "0.1",
  :url         => "http://www.puppetlabs.com/mcollective",
  :timeout     => 60


action "dpl", :description => "Deploy specified artefact to application server" do
  input :app,
    :prompt      => "Maven ID of App to download",
    :description => "Download this application, specified by its Maven ID",
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

  input :appversion,
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


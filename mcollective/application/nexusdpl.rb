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

class MCollective::Application::Nexusdpl<MCollective::Application
  description "Install and uninstall software packages"
  usage "mco nexusdpl [options] [filters] app=<mvn-id> [<key=val> <key=val> ...]"

  option :app,
    :description    => "Which application (identified by Maven-ID) to deploy?",
    :arguments      => ["-a", "--app APP"]

  option :context,
    :description    => "Which tomcat context to install this app to",
    :arguments      => ["-c", "--context CONTEXT"]

  option :path,
    :description    => "full path where to put the deployable",
    :arguments      => ["-p", "--path PATH"]

  option :version,
    :description    => "Which exact version of this app to install",
    :arguments      => ["--version VERSION"],
    :default        => "LATEST"

  option :repo,
    :description    => "Which repository to install this app from",
    :arguments      => ["-r", "--repo REPO"]

  option :restart,
    :description    => "restart this tomcat, after successful deployment",
    :arguments      => ["--restart TOMCAT"]

  def post_option_parser(configuration)
    if ARGV.length >= 1

      ARGV.each do |v|
        if v =~ /^(.+?)=(.+)$/
          configuration[:arguments] = [] unless configuration.include?(:arguments)
          configuration[:arguments] << v
        else
          STDERR.puts("Could not parse arguments: #{v}")
          exit!
        end
      end
    else
      STDERR.puts("Please specify a maven ID.")
      exit!
    end
  end

  def validate_configuration(configuration)
    if MCollective::Util.empty_filter?(options[:filter])
      STDERR.print "Cowardly refusing to run nexusdpl unfiltered\n"
      exit!
    end
  end

  def main
    nxdpl = rpcclient('nexusdpl')
    nxdpl.send("dpl", configuration[:arguments]) # we could yield here and do something fancy for each node.
    printrpcstats
    nxdpl.disconnect
  end
end

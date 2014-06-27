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

require 'fileutils'
require 'digest/sha1'
require 'net/http'
require 'digest'
require 'tempfile'

module MCollective
  module Agent
    # A deploymnet management agent, which uses Nexus as source
    #
    # This agent will download a specified file-version.war from a
    # Nexus server configured, verifies the .sha1 sum, and copies
    # the file into the specified container's path.
    # Optionally, it restarts the app server.
    #
    # Configuration:
    #   plugin.nexusdpl.nexus_url 
    #   plugin.nexusdpl.user
    #   plugin.nexusdpl.passwd
    #
    # Paramters:
    #   app        maven name
    #   appversion e.g.: 1.1, default: LATEST per Nexus API
    #   repo       default: config.nexusdpl.repo
    #   ext        default: war
    #   context    default $app
    #   path       default: /opt/tomcats/$context/webapps/$context.$ext
    #   restart    default: No, otherwise, specifiy service name, e.g.: tomcat7-$context
    #
    #   https://nexus/service/local/artifact/maven/redirect?r=repo&g=group&a=app&e=war&v=LATEST
    #
    #   $ mco nexusdpl dpl app=app group=group repo=repo context=app restart=tomcat7-app
    #
    class Nexusdpl<RPC::Agent


      def startup_hook
        # noremalize base url # this could be done in the agent startup hook?
        @base_url =  config.pluginconf["nexusdpl.nexus_url"]
        @base_url.chop! if @base_url.rindex('/') == (@base_url.size - 1 )

        @user = config.pluginconf["nexusdpl.user"]
        @passwd = config.pluginconf["nexusdpl.passwd"]

        @repo = config.pluginconf['nexusdpl.repo']
      end

      action "dpl" do
        mvn = request[:app]
        *group, app = mvn.split "."
        group = group.join "."
        version = request[:appversion] || "LATEST"
        repo = request[:repo] || @repo
        ext = request[:ext] || "war"
        context = request[:context] || app
        path = request[:path] || "/opt/tomcats/#{context}/webapps/#{context}.#{ext}"
        restart = request[:restart] || nil # no default here ;)

        url = "#{@base_url}/service/local/artifact/maven/redirect?r=#{repo}&g=#{group}&a=#{app}&e=#{ext}&v=#{version}"
        url_sha1 = "#{@base_url}/service/local/artifact/maven/redirect?r=#{repo}&g=#{group}&a=#{app}&e=#{ext}.sha1&v=#{version}"
        tempfile = download(url, url_sha1, ext)	

        # unlink old file, rename new file to old file

        begin
          File.unlink(path) if File.exists?(path)
        rescue Exception => e
          reply[:error] = e.message
          reply[:trace] = e.backtrace.inspect
          reply.fail! "failed to unlink old .#{ext} file: #{path}"
        end
        begin
          FileUtils.mv(tempfile, path)
        rescue Exception => e
          reply[:error] = e.message
          reply[:trace] = e.backtrace.inspect
          reply.fail! "failed to move new artefact: #{tempfile} to  old .war file: #{path}"
        end

        # restart service, if necessary:
        unless restart == nil then
          begin
            svc = get_puppet(restart)
          rescue Exception => e
            reply[:error] = e.message
            reply[:trace] = e.backtrace.inspect
            reply.fail!
          end
        end

      end


      private
      # Creates an instance of the Puppet service provider, supports config options:
      #
      # - service.hasrestart - set this if your OS provides restart options on services
      # - service.hasstatus  - set this if your OS provides status options on services
      # - this is stolen from service agent
      def get_puppet(service)
        hasstatus = false
        hasrestart = false

        if @config.pluginconf.include?("service.hasrestart")
          hasrestart = true if @config.pluginconf["service.hasrestart"] =~ /^1|y|t/
        end

        if @config.pluginconf.include?("service.hasstatus")
          hasstatus = true if @config.pluginconf["service.hasstatus"] =~ /^1|y|t/
        end

        ::Puppet::Type.type(:service).new(:name => service, :hasstatus => hasstatus, :hasrestart => hasrestart).provider
      end

      private
      def shellout_dl(url, localpath)


        if File.exists?('/usr/bin/wget')
          system('/usr/bin/wget', '-q', '--user', @user, '--password', @passwd, '-O', localpath, "#{url}")
        elsif File.exists?('/usr/bin/curl')
          system('/usr/bin/curl', '-s', '-u', "#{@user}:#{@passwd}", '-o', localpath, url)
        else
          false
        end
      end

      # Why the fuck is this not an internal Ruby variable?
      # btw, the alternative is to use ffi:
      #   http://manveru.name/blog/show/2012-10-16/en/Using-sysconf-in-Ruby-with-FFI-Update
      private
      def get_pagesize
        tmp = `getconf PAGESIZE 2>/dev/null`.to_i
        pgsize = 512
        pgsize = tmp if tmp > pgsize
        pgsize
      end

      private
      def sha1_file(localpath)
        sha1 = Digest::SHA1.new

        File.open(localpath) do|file|
          buffer = ''

          # Read the file PAGESIZE bytes at a time
          pgsize = get_pagesize
          while not file.eof
            file.read(pgsize, buffer)
            sha1.update(buffer)
          end
        end
        sha1.to_s
      end

      # download and sha1-verify artefact.
      # return path to temp file
      # false otherwise
      private
      def download(url, sha1_url, ext)
        artefact_file = Tempfile.new(ext)
        sha1_file = Tempfile.new('sha1')

        shellout_dl url, artefact_file.path
        shellout_dl sha1_url, sha1_file.path

        sha1 = sha1_file(artefact_file.path)
        sha1_file_content = sha1_file.read

        # cleanup (close before unlink)
        sha1_file.close
        sha1_file.unlink
        artefact_file.close

        unless sha1_file_content == sha1 then
          artefact_file.unlink
          nil # returning nil fits better with
        end
        artefact_file.path # returning a string
      end

    end
  end
end


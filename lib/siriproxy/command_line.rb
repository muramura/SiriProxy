require 'optparse'

class SiriProxy::CommandLine

  BANNER = <<-EOS
Siri Proxy is a proxy server for Apple's Siri "assistant." The idea is to allow for the creation of custom handlers for different actions. This can allow developers to easily add functionality to Siri.

See: http://github.com/plamoni/SiriProxy/

Usage: siriproxy COMMAND OPTIONS

Commands:
server (default)  Start up the Siri proxy server
console           Launch the plugin test console 
help              Show this usage information

Options:
  EOS

  def initialize
    parse_options
    command     = ARGV.shift
    subcommand  = ARGV.shift
    case command
    when 'server'           then run_server(subcommand)
    when 'console'          then run_console
    when 'help'             then usage
    else                    run_server()
    end
  end

  def run_console
    puts "Not yet implemented"
  end

  def run_server(subcommand='start')
    load_code
    start_server
    # @todo: support for forking server into bg and start/stop/restart
    # subcommand ||= 'start'
    # case subcommand
    # when 'start'    then start_server
    # when 'stop'     then stop_server
    # when 'restart'  then restart_server
    # end
  end

  def start_server
    proxy = SiriProxy.new
    proxy.start()
  end

  def usage
    puts "\n#{@option_parser}\n"
  end

  private
  
  def parse_options
    $APP_CONFIG = OpenStruct.new(YAML.load_file(File.expand_path('~/.siriproxy/config.yml')))
    @option_parser = OptionParser.new do |opts|
      opts.on('-p', '--port PORT', 'port number for server (central or node)') do |port_num|
        $APP_CONFIG.port = port_num
      end
      opts.on('-l', '--log LOG_LEVEL', 'The level of debug information displayed (higher is more)') do |log_level|
        $APP_CONFIG.log_level = log_level
      end
      opts.on_tail('-v', '--version', 'show version') do
        require "siriproxy/version"
        puts "SiriProxy version #{SiriProxy::VERSION}"
        exit
      end
    end
    @option_parser.banner = BANNER
    @option_parser.parse!(ARGV)
  end

  def load_code
    require 'siriproxy/connection'
    require 'siriproxy/connection/iphone'
    require 'siriproxy/connection/guzzoni'

    require 'siriproxy/plugin'
    require 'siriproxy/plugin_manager'
  end
end

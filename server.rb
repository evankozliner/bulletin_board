require 'socket'
require 'logger'
require 'optparse'
require_relative 'http_server'

def get_options
	options = {}
	OptionParser.new do |opts|
		opts.banner = "Usage: ruby server.rb [options]"
		opts.on("-H", "--http", "Use the HTTP server example (Not intended for submission, only as example code.") do |http|
			options[:http] = http
		end
		opts.on("-v", "--[no-]verbose", "Run verbose mode") do |v|
			options[:verbose] = v
		end
		opts.on("-p port", Integer, "Sets the port") do |port|
			options[:port] = port.to_s
		end
		opts.on("-h", "--help", "Prints help") do 
			puts opts
			exit
		end
	end.parse!
	return options
end

# Accepts any request on a new thread
def start_server
	options = get_options()
	basePath = Dir.pwd
	port = options[:port] || "9090"
	server = TCPServer.new('localhost', port)

	`touch log.txt` unless File.exists? 'log.txt'
	logger = Logger.new(basePath + "/log.txt")
	logger.info "Server started on port " + port
	
	if options[:http] == true
		puts "Selected in HTTP mode."
	end

	loop do
	  session = server.accept
	  request = session.gets
	  logStr =  "#{session.peeraddr[2]} (#{session.peeraddr[3]})\n"
	  logStr += Time.now.localtime.strftime("%Y/%m/%d %H:%M:%S")
	  logStr += "\n#{request}"
		logger.info logStr
	
	  Thread.start(session, request) do |session, request|
			if options[:http]
	    	HttpServer.new(session, request, basePath, logger).serve()
			else
				puts "Bulletin Board not implemented"
			end
	  end
	end
end

start_server()

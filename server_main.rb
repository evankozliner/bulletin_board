require 'socket'
require 'logger'
require 'optparse'
require_relative 'http_server'
require_relative 'server'

def get_options
	options = {}
	OptionParser.new do |opts|
		http_str = "Use the HTTP server example (Not intended for " +
								"submission, only as example code."
		opts.banner = "Usage: ruby server.rb [options]"
		opts.on("-H", "--http", http_str) do |http|
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
		opts.on("-host", String, "Sets the host") do |host|
			options[:host] = host
		end
	end.parse!
	return options
end
def start_http_server(server)
	loop do
		session = server.accept
	  request = session.gets
		logStr =  "#{session.peeraddr[2]} (#{session.peeraddr[3]})\n"
		logStr += Time.now.localtime.strftime("%Y/%m/%d %H:%M:%S")
		logStr += "\n#{request}"
		logger.info logStr
		if options[:http]
		  Thread.start(session, request) do |session, request|
		    HttpServer.new(session, request, basePath, logger).serve()
			end
		end
	end
end
# The starting point for the server. Instantiates a server object that listens for clients.
def start_server
	options = get_options()
	basePath = Dir.pwd
	port = options[:port] || "9090"
	host = options[:host] || "localhost"

	`touch log.txt` unless File.exists? 'log.txt'
	logger = Logger.new(basePath + "/log.txt")
	logger.info "Server started on port " + port
	if options[:http] == true
		puts "Selected in HTTP mode."
		start_http_server(server)
	else
		puts "Bulletin Board mode on port " + port + " for host " + host
		board = BulletinBoard.new(host, port, logger)
	end
end

start_server()

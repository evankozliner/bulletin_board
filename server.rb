require 'socket'

class BulletinBoard
	def initialize(host, port, logger)
		@server = TCPServer.new port
		@logger = logger
		@connections, @rooms, @clients = {}, {}, {} 
	end

	def listen
		loop do 
			session = @server.accept
			puts "session!"
			Thread.start(session) do |client|
				puts "Client Request"
				puts line = client.gets.chomp
				client.puts "hey from server!"
				# get the input json
				# figure out the response
				# send the response to the sender and all the other clients 
			end
		end
	end
end

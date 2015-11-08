require 'socket'

class BulletinBoard
	def initialize(host, port, logger)
		@server = TCPServer.open port # Specifying host seems to deny connection on OSX 
		@logger = logger
		@connections, @rooms, @clients = {}, {}, {} 
		listen
	end

	def listen
		loop {
			session = @server.accept
			puts "accepted a session"
			Thread.start(session) do |client|
				puts "started a thread for the session"
				name = client.gets.chomp.to_sym
				@logger.info name
			#	@connections[:clients].each do |member_name, member_client|
			#		# Test for dupeicate names here
			#		puts "will test dup here..."
			#	end
				puts "appending a client"
				puts @connections
				@connections[name] = client
				client.puts "You've joined the chat!"
				listen_messages(name, client)
				# get the input json
				# figure out the response
				# send the response to the sender and all the other clients 
			end
		}.join
	end

	def listen_messages(name, client)
		loop do 
			message = client.gets.chomp
			@connections.each do |connection_name, connection_cleint|
				puts "Listing a message..."
				unless connection_name == name
					connection_client.puts message
				end
			end
		end
	end
end

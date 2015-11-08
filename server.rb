require 'socket'

class BulletinBoard
	def initialize(server, logger)
		@logger = logger
		@server = server
	end

	def listen()
		puts "listening!"
	end
end

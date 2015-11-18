require 'socket'
require 'json'

class Group
	def initialize(id, name)
		@id = id
		@name = name
		@messages = []
		@clients = []
	end
	
	# Gets the messages from the group
	def get_messages(number = 2)
	end

	# Sends a message to all the clients in the group
	def send_message(message)
	end

	# 
end

class Client
	attr_accessor :name, :session
	
	# Sends a JSON response to the client containing a list of strings 
	def send message
	end
end

class Message
	attr_accessor :id, :subject, :contents
end

# Singleton for the bulletin board server
class Server
	def initialize(host, port, logger)
		@server = TCPServer.open port
		@logger = logger
		@clients = {}
		listen
	end
	
	# Waits for requests from clients and opens a thread for each client.
	# Prompts any new clients for a username initially, then keeps a connection
	# open for future requests.
	def listen
		loop {
			accept_session = @server.accept
			Thread.start(accept_session) do |session|
				session.puts("Please enter a username:")
				client = add_client(client.gets, session)
				if username
					listen_for_commands(client)
				else
					session.puts("[Server] Invalid username, closing connection.")
					Thread.kill self
				end
			end
		}.join
	end


	def listen_for_commands(client)
		loop {
			client_dump = JSON.parse(client.session.gets)
			first_word = client_dump["command"]
			act_on_command(first_word, raw_command, client)
		}
	end

	def act_on_command(first_word, raw_command, client)
		case first_word
		when 'join'
		when ''
		else
			client.send("Server", ["I don't know the command #{first_word}"])
		end
	end

	def add_client(raw_command, session)
		name = raw_command.split(" ")[0].to_sym # Name should be space seperated
		if is_duplicate_name(name, client)
			session.puts("[Server] This username already exist. Client not added.")
			return false
		else
			new_client = Client.new
			new_client.session = session
			new_client.name = name
			@clients << new_client
			new_client.send("Server", "You've joined the board! Please enter a command" +
									" or type help for a list of commands.")
			return name
		end
	end

	def is_duplicate_name(client_session, name)
		@clients.each do |other_client|
			if name == other_client.name || client == client.session
				return true
			end
		end
		return false
	end
end

port = "9090"
host = "localhost"
logger = Logger.new(basePath + "/log.txt") 
logger.info "Server started on port " + port 
server = Server.new(host, port, logger)

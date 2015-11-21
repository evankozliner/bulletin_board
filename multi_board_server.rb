require 'socket'
require 'json'
require 'logger'

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
	# Appends the sender in brackets to each line
	def send sender, lines
		puts sender
		puts lines.to_s
		senderified_lines = []
		lines.each do |line|
			senderified_lines << "[" + sender + "]" + line
		end
		json_message = {
			:messageContents => senderified_lines
		}.to_json
		puts json_message.to_s
		@session.puts json_message
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
		@clients = []
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
				client = add_client(session.gets, session)
				if client
					listen_for_commands(client)
				else
					session.puts("[Server] Invalid username, closing connection.")
					Thread.kill self
				end
			end
		}.join
	end

	# Waits for JSON messages from the client on a seperate thread
	# then 
	def listen_for_commands(client)
		loop {
			msg = client.session.gets
			client_dump = JSON.parse(msg)
			puts client_dump.to_s
			first_word = client_dump["command"]
			act_on_command(first_word, raw_command, client)
		}
	end

	def act_on_command(first_word, raw_command, client)
		puts first_word
		case first_word
		when 'join'
		when ''
		else
			client.send("Server", ["I don't know the command #{first_word}"])
		end
	end
	
	# Adds an object of type client to the clients attribute if that client
	# passses is_duplicate_name. Sends a response indicating success.
	def add_client(raw_command, session)
		name = raw_command.split(" ")[0].to_sym # Name should be space seperated
		if is_duplicate_name(name, session)
			session.puts("[Server] This username already exist. Client not added.")
			return false
		else
			new_client = Client.new
			new_client.session = session
			new_client.name = name
			@clients << new_client
			new_client.send("Server", ["You've joined the board! Please enter a command" +
									" or type help for a list of commands."])
			return new_client
		end
	end
	
	# Returns true for a duplicate session or client name, false otherwise
	def is_duplicate_name(name, client_session)
		@clients.each do |other_client|
			if name == other_client.name || client_session == other_client.session
				return true
			end
		end
		return false
	end
end

port = "9090"
host = "localhost"
logger = Logger.new(Dir.pwd+ "/log.txt") 
logger.info "Server started on port " + port 
server = Server.new(host, port, logger)

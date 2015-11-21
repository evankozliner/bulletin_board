require 'socket'
require 'json'
require 'logger'

class Group
	attr_reader :name
	attr_accessor :messages, :clients
	def initialize(name)
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

	# Returns a list of usernames of clients in the group
	def get_usernames
		names = []
		@clients.each do |client|
			names << client.name.to_s
		end
		puts names.to_s
		return names
	end
end

class Client
	attr_accessor :name, :session
	
	# Sends a JSON response to the client containing a list of strings 
	# Appends the sender in brackets to each line
	def send sender, lines
		senderified_lines = []
		lines.each do |line|
			senderified_lines << "[" + sender + "] " + line
		end
		json_message = {
			:messageContents => senderified_lines
		}.to_json
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
		@groups = []
		create_groups
		listen
	end
	
	# Returns a list of 5 hard-coded groups
	def create_groups
		group_names = ["cats", "dogs", "humans", "horses", "cows"]
		while group_names.length > 0 do
			group = Group.new(group_names.pop)
			@groups << group
		end
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
		puts "listening to " + client.name.to_s
		loop {
			msg = client.session.gets
			client_dump = JSON.parse(msg)
			puts client_dump.to_s
			first_word = client_dump["command"]
			act_on_command(first_word, client_dump, client)
		}
	end
	
	# Sends the client a list of group names back
	def handle_groups(client)
		group_names = []
		@groups.each do |group|
			group_names << group.name
		end
		client.send("Server", group_names)
	end

	# Adds a client to a group, informs client if the group doesn't exist
	def handle_join(client, group_name)
		resp = "Group " + group_name + " doesn't exist"
		group = get_group_by_name(group_name)
		if group
			group.clients << client
			resp = "Joined group " + group_name
		end
		client.send("Server", [resp])
	end

	# Returns the users belonging to a group or informs the client 
	# that the group doesn't exist
	def handle_users(client, group_name)
		group = get_group_by_name(group_name)
		resp = ["Group " + group_name + " doesn't exist"]
		if group
			puts "Getting usernames... for group " + group.name
			resp = group.get_usernames
		end
		client.send("Server", resp)
	end

	# Fetches a group by its (unique) name, returns false if the group
	# doesn't exist
	def get_group_by_name(name)
		@groups.each do |group|
			if group.name == name
				return group
			end
		end
		return false
	end
	
	# Takes a specific word as a command and calls a response function based on
	# that command
	def act_on_command(first_word, client_hash, client)
		puts "handling " + first_word
		case first_word
		when 'groupjoin'
			handle_join(client, client_hash["groupId"])
		when 'groups'
			handle_groups(client)
		when 'grouppost'
		when 'groupusers'
			handle_users(client, client_hash["groupId"])
		when 'groupleave'
		when 'groupmessage'
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

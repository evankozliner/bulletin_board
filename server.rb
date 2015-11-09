require 'socket'
require 'json'

class BulletinBoard
	def initialize(host, port, logger)
		@server = TCPServer.open port # Specifying  gets denied connection on OSX
		@logger = logger
		@clients, @rooms = {}, {}
		listen
	end

	def listen
		loop {
			session = @server.accept
			Thread.start(session) do |client|
				client.puts "Please enter a username:"
				username = add_client(client.gets, client)
				if username
					listen_for_commands(client, username)
				else
					client.puts "Invalid username, closing connection."
					Thread.kill self
				end
			end
		}.join
	end

	def listen_for_commands(client, username)
		loop {
			raw_command = client.gets
			first_word = raw_command.split(" ")[0]
			act_on_command(first_word, raw_command, client, username)
		}
	end

	def act_on_command(first_word, raw_command, client, username)
		case first_word
		when 'post'
			post(raw_command, username)
		else
			client.puts "I don't know the command #{first_word}"
		end
	end

	def post(raw_command, username)
		puts "post! " + raw_command
		# lose the command word
		# messsage = raw_command.split(" ")[1..raw_command.length].join(" ")
		@clients.each do |name, client|
			unless name == username
				client.puts raw_command
			end
		end
	end

	def add_client(raw_command, client)
		puts "adding client"
		name = raw_command.split(" ")[0].to_sym # Name should be space seperated
		if is_duplicate_name(name, client)
			client.puts "This username already exist. Client not added."
			return false
		else
			@clients[name] = client
			client.puts ("You've joined the board! Please enter a command" +
									" or type help for a list of commands.")
			return name
		end
	end

	def is_duplicate_name(client, name)
		puts "is_duplicate_name"
		@clients.each do |other_name, other_client|
			if name == other_name || client == other_client
				return true
			end
		end
		return false
	end
end

import socket
import sys
import json
import select

class Client:
    def __init__(self, hostname, port):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.settimeout(2)
        self.connect(socket)

    def connect(self, socket):
        try:
            self.socket.connect((host, port))
            print "Successfully connected to host. "
            print "Welcome to the chat! Enter 'help' for a list of commands."
        except:
            print 'Unable to connect'
            sys.exit()

    # TODO We'll need to fill this guy out if we want to use json
    def prep_data(self, data):
        words = data.split(" ")
        command = words[0]
        remaining_words = " ".join(words[1:len(words)])
        return json.dumps({"command": command, "data": data})

    def start(self):
        while True:
            socket_list = [sys.stdin, self.socket]
            ready_to_read,ready_to_write,in_error = select.select(socket_list , [], [])
            for sock in ready_to_read:
                if sock == self.socket: # Message from server
                    data = sock.recv(4096)
                    if not data :
                        print '\nYou are disconnected.'
                        sys.exit()
                    else :
                        sys.stdout.write(data)
                        # sys.stdout.write('[Me] ')
                        # sys.stdout.flush()
                else : # User sending message to server
                    # sys.stdout.write('[Me] ')
                    # sys.stdout.flush()
                    msg = sys.stdin.readline()
                    self.socket.send(msg)

#program starts here
print "Welcome client, to this server thing"
input_list=raw_input("Enter command 'connect [hostname] [port]' to connect to a server: ").split()
if input_list[0]!="connect" or len(input_list)!=3:
    print "Input should be 'connect [hostname] [port]'"
    sys.exit()

host = input_list[1]
port = int(input_list[2])
client = Client(host, port)
client.start()
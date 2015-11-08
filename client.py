import socket
import thread

class Client:
    def __init__(self, hostname, port):
        print("connecting on port " + str(port) + " for host " + hostname + "...") 
        client_socket = socket.socket()
        client_socket.connect((hostname, port))
        self.socket = client_socket
        self.request = None
        self.response = None
    
    def start(self, username):
        thread.start_new_thread(self.listen(), ())
        thread.start_new_thread(self.send_messages(), ())

    def listen(self):
        while True:
            print self.socket.recv(1024)

    def send_messages(self):
        while True:
            raw_command = raw_input("Enter a command:")
            self.socket.send(raw_command)

port = 9090
host = "localhost"
client = Client(host, port)
client.start("Evan")

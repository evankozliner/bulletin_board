import socket
import sys
import threading

class Client:
    def __init__(self, hostname, port):
        print("connecting on port " + str(port) + " for host " + hostname + "...") 
        client_socket = socket.socket()
        client_socket.connect((hostname, port))
        self.socket = client_socket
    
    def start(self, username):
        listening_thread = threading.Thread(target=self.listen)
        sending_thread = threading.Thread(target=self.send_messages)
        listening_thread.start()
        sending_thread.start()
        listening_thread.join()
        sending_thread.join()

    def listen(self):
        while True:
            print self.socket.recv(1024)

    def send_messages(self):
        while True:
            raw_command = sys.stdin.readline()
            self.socket.send(raw_command)

port = 9090
host = "localhost"
client = Client(host, port)
client.start("Evan")

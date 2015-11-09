import socket
import sys
import json
import select

class Client:
    def __init__(self, hostname, port):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.settimeout(2)
        self.connect(socket)

    # connect to remote host
    def connect(self, socket):
        try:
            self.socket.connect((host, port))
            print "Successfully connected to host. "
            print "Welcome to the chat! Enter 'help' for a list of commands."
        except:
            print 'Unable to connect'
            sys.exit()

    def start(self):
        sys.stdout.write('[Me] ')
        sys.stdout.flush()
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
                        sys.stdout.write('[Me] ')
                        sys.stdout.flush()
                else : # User sending message to server
                    msg = sys.stdin.readline()
                    self.socket.send(msg)
                    sys.stdout.write('[Me] '); sys.stdout.flush()

# class Client:
#     def __init__(self, hostname, port):
#         print("connecting on port " + str(port) + " for host " + hostname + "...")
#         client_socket = socket.socket()
#         client_socket.connect((hostname, port))
#         self.socket = client_socket
#
#     def start(self, username):
#         listening_thread = threading.Thread(target=self.listen)
#         sending_thread = threading.Thread(target=self.send_messages)
#         listening_thread.start()
#         sending_thread.start()
#         listening_thread.join()
#         sending_thread.join()
#
#     def listen(self):
#         while True:
#             print self.socket.recv(1024)
#
#     def send_messages(self):
#         while True:
#             raw_command = sys.stdin.readline()
#             json_payload = json.dumps({'name': raw_command})
#             self.socket.send(json_payload)
if(len(sys.argv) < 3) :
    print 'Usage : python client.py host port'
    sys.exit()
else:
    host = sys.argv[1]
    port = int(sys.argv[2])
    client = Client(host, port)
    client.start()

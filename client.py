import socket
import sys
import json
import select
class Client:
    def __init__(self, hostname, port):
        self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.socket.settimeout(2)
        self.connect(socket)
        self.name=None

    def connect(self, socket):
        try:
            self.socket.connect((host, port))
            print "\nSuccessfully connected to {0} on port {1}. ".format(host, port)
            #self.socket.send("{command: 'groups'}") #get list of groups
        except:
            print 'Unable to connect to {0} on port {1}'.format(host,port)
            sys.exit()
    def handle_command(self,msg):
        msg_info={"command":msg[0].lower()}
        if msg[0].lower()=="h" or msg[0].lower()=="help":
            print "Possible commands are: 'grouppost', 'groupjoin', 'groups', 'groupusers', 'groupleave', or 'groupmessage'."
            return None
        elif msg[0].lower()=="grouppost":
            #get all info about message from user and add to array
            msg_info['groupId']=raw_input("Enter index of group you want to send message to:") or "1"
            msg_info['subject']=raw_input("Enter message subject: ") or "subject1"
            msg_info['message']=raw_input("Enter message body: ") or "body1"
        elif msg[0].lower()=="groupjoin":
            #get a groupid if user didn't specify one as param of command, then add to msg_info
            msg_info['groupId']=msg[1] if len(msg)>1 else (raw_input("Enter groupId: ") or "1")
        elif msg[0].lower()=="groups":
            #do nothing, just send message
            pass
        elif msg[0].lower()=="groupusers":
            #get a groupid if user didn't specify one as param of command, then add to msg_info
            msg_info['groupId']=msg[1] if len(msg)>1 else (raw_input("Enter groupId: ") or "1")
        elif msg[0].lower()=="groupleave":
            #get a groupid if user didn't specify one as param of command, then add to msg_info
            msg_info['groupId']=msg[1] if len(msg)>1 else (raw_input("Enter groupId: ") or "1")
        elif msg[0].lower()=="groupmessage":
            #get a groupid and messageid if user didn't specify as param of command, then add to msg_info
            msg_info['groupId']=msg[1] if len(msg)>1 else (raw_input("Enter groupId: ") or "1")
            msg_info['messageId']=msg[1] if len(msg)>1 else (raw_input("Enter messageId: ") or "1")
        else:
            print "Invalid command entered!"
            return None
        json_message=json.dumps(msg_info)
        print "sending message: "+json_message
        self.socket.send(json_message+"\n")
        return None
        
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
                else : # User sending message to server
                    msg=sys.stdin.readline().split()
                    if len(msg)==0: #error if user doesn't input anything
                        print "Invalid command entered!"
                    else:
                        if self.name==None: #if no name set yet
                            self.name=msg[0]
                            print "sending {0}".format(self.name)
                            self.socket.send(self.name+"\n")
                            print "Username set. Hello {0}!".format(self.name)
                            print "\nEnter a command, or 'h' for a list of commands."
                        else: #otherwise handle command
                            self.handle_command(msg)

#program starts here
print "\nWelcome client, to this server thing!\n"
input_list=(raw_input("Enter command 'connect [hostname] [port]' to connect to a server: ") or 'connect localhost 9090').split()
if input_list[0].lower()!="connect" or len(input_list)!=3:
    print "Error: Input should be 'connect [hostname] [port]'"
    print "Exiting..."
    sys.exit()

host = input_list[1]
port = int(input_list[2])
client = Client(host, port)
client.start()
# Bulletin Board
A simple, command line bulletin board.
Features:
# Client (Python) Server (Ruby)
## Protocol Design:
The format will be a JSON protocol
#### Client
See the PDF for the possible commands. Depending on the command different key values will need specified in the JSON object. The keys that are required should be self explanitory.
The protocol works as follows: The user submits a request with the command key specified and any other necessary keys required for that command also filled out. The server acts according to the command string, responding with a list of strings or message contents. If a command does not require some keys as a request or response those keys are just left blank.

Messages are passed back and forth in JSON format. The server maintains a thread for each connected client where it listens for new JSON requests and sends response(s) to the client(s) on a need-to-know basis. The client is "dumb" in the sense that it prints whatever the server specifies in "responseList", line by line.

## Client JSON implementation (All possible keys)
<pre>
{
	command: "String",
	groupId: "String",
	subject: "String",
	messageId: "String",
	message: "String"
}
</pre>

## Server JSON implementation (All possible keys)
<pre>
{
	responseList: List of Strings,
	messageContent: "String"
}
</pre>

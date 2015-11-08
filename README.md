A command line bulletin board.
Features:
# Client (Python) Server (Ruby)
*Remember to note any completed or in progress sub bullets*
* Connecting to a running bulletin board
	* Client
	* Server
* Joining a single discussion board 
	* Client
	* Server
* Posting to a single discussion board 
	* Client
	* Server
* Retrieving a list of users 
	* Client
	* Server
* Leaving a group
	* Client
	* Server
* Getting the content of a message
	* Client
	* Server
* Disconnecting from the serer
	* Client
	* Server
* Retrive a list of all groups that can be joined
	* Client
	* Server
* Join a specific group from a list
	* Client
	* Server
* Post to a specific group
	* Client
	* Server
* Get all users of a specific group
	* Client
	* Server
* Leave a specificgroup
	* Client
	* Server
* Retrieve specific group message
	* Client
	* Server
* GUI (NOT STARTED)
	* Client

## To run the server:
	ruby server.rb
<pre>
 Usage: ruby server.rb [options]
 -H, --http                       Use the HTTP server example (Not intended for submission, only as example code.
      -v, --[no-]verbose               Run verbose mode
      -p port                          Sets the port
      -h, --help                       Prints help
</pre>
## Protocol Design:
The format will be a JSON protocol 
#### Client
See the PDF for the possible commands. Depending on the command different key values will need specified in the JSON object. The keys that are required should be self explanitory. 
The protocol works as follows: The user submits a request with the command key specified and any other neccessary keys required for that command also filled out. The server acts according to the command string, responding with a list of strings or message contents. If a command does not require some keys as a request or response those keys are just left blank.

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


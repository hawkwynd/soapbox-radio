
# turn on logging, and open connections to telnet 1234
set("log.level", 3 ) # 3 is default
set("log.file.path","jarvis.log")
# set("server.telnet", true)
# set("server.telnet.port", 1234)
# set("harbor.bind_addr","0.0.0.0") 
# set("harbor.timeout",60.)
# set("harbor.icy_formats",["audio/mpeg","audio/aacp","audio/aac","audio/x-aac","audio/wav","audio/wave","audio/x-flac"])

def add_skip_command(~command,s)
	# Register the command:
	server.register(
		usage="skip",
		description="Skip the current song in source.",
		command,
		fun(_) -> begin source.skip(s) "Skipped current playing song." end
	)
end

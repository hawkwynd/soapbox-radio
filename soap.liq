#!/usr/bin/liquidsoap

# BROADCAST TO GREYSTONE

set("log.file.path","basic-radio.log")

set("server.telnet", true)
set("server.telnet.port", 1234)
set("harbor.bind_addr","0.0.0.0") 
set("harbor.timeout",30.)
set("harbor.icy_formats",["audio/mpeg","audio/aacp","audio/aac","audio/x-aac","audio/wav","audio/wave","audio/x-flac"])

#enable_replaygain_metadata ()

mainStreamRock =  "/home/scott/radio/playlists/main.m3u"
jingles  = nrj( audio_to_stereo( playlist( id="jingles", mode="randomize", reload_mode="watch", reload=0,mime_type="audio/x-mpegurl", "/home/scott/radio/jingles") ) )


radioId        =  "/home/scott/radio/hawkad1.mp3"

# Normalize this playlist in order they are in random play order

radio = playlist( id="main",mode="random",reload_mode="rounds",reload=1, mainStreamRock )
radio = normalize( gain_max=6.0,gain_min=-6.0,k_down=0.1,k_up=0.005,target=1.0,threshold=-25.0,window= 0.1, radio )

# define our station identifier track
clock = single( radioId )

# define the commercials
#jingles =  audio_to_stereo( playlist( id="jingles", mode="random", jingles) )

# when all else fails, play this
security = single( id="security", radioId )

# set our requests id
requests = request.queue( id="requested" )

# Live Stream
live = input.harbor("live",port=8080,password="hackme", buffer=1., max=5.)

# Mix jingles in, 1 for every 4 tracks played.
radio = rotate( weights = [ 1 , 4 ], [ jingles, radio ]) 

# play requests, but dont switch until existing track ends -- track sensitive true means wait until the song ends
radio = fallback( id="switcher", track_sensitive = false, [ live, requests, radio, security ] )

# at top of the hour, play a specific radio identifier over the playing track
radio  = add([ radio, switch([ ( {0m0s}, clock ) ] ) ] )

# amplify our signal to level shit out. 
# radio = amplify( 1.0, override = "replay_gain", radio )

# Send to The Greystone Rocks station
output.shoutcast(
    %mp3,
    host       = "35.174.26.109", 
    name        = "Hawkwynd Radio", 
    url         = "http://stream.hawkwynd.com", 
    genre       = "Classic Rock",  
    port        = 8000, 
#   password    = "scootre:#2",
    password    = "scootre",
    public      = true,
    radio
)

# out(radio)

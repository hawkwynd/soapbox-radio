#!/usr/bin/liquidsoap

# Jarvis v2.0 

%include "includes/jarvis.config.liq"

MainStream  = playlist( id="main", mode="randomize", reload_mode="watch", reload=0, mime_type="audio/x-mpegurl", "/home/scott/radio/playlists/main.m3u" )

# nrj: Compress and normalize, producing a more uniform and “full” sound.
jingles  = nrj( audio_to_stereo( playlist( id="jingles", mode="randomize", reload_mode="watch", reload=0,mime_type="audio/x-mpegurl", "/home/scott/Music/jingles") ) )

# define our station identifier Top Of The Hour
# ============================================
radioId             =  "/home/scott/radio/hawkad1.mp3"

clock               = single( radioId )

# set our requests id, to accept requests the LR
# requests = request.queue( id="requested")

# Live Stream input from MIXXX with a 0.5 second buffer 60s max for Friday Night Live
# live = input.harbor( "live", port=8080, password="hackme", buffer=0.5, max=60.0 )

# rotation 
rotating = rotate( weights = [ 1, 3 ], [ jingles, MainStream  ] )

radio = fallback( track_sensitive = true,
  [ switch( 
    [

        ####################### Regular Scheduling ##################
   
    ]
    ),

        # All other times/days play main playlist, track sensitive to requests and live feed.
        rotating
])

# at top of the hour, play a specific radio identifier over the playing track
radio  = add([ radio, switch( [ ( {0m0s}, clock ) ] ) ] )

radio = normalize( radio )

# Add a skip command for use via telnet
# add_skip_command( command="skip", radio )


# Send to Shoutcast Server Greystone Rocks
output.shoutcast(
    %mp3,
    host        = "35.174.26.109", 
    name        = "Greystone Rocks", 
    url         = "http://stream.hawkwynd.com", 
    genre       = "Classic Rock",  
    port        = 8000, 
    password    = "scootre:#2",
    public      = true,
    fallible    = true,
    radio
)

# shoot it to the soundcard
# out(radio)

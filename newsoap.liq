#!/usr/bin/liquidsoap

# include code for crossfade
%include "crossfade.liq"

# enable liquidsoap to read mp3 metadata "REPLAY_GAIN" values
enable_replaygain_metadata ()

# turn on logging, and open connections to telnet 1234
set("log.file.path","scheduled-radio.log")
set("server.telnet", true)
set("server.telnet.port", 1234)
set("harbor.bind_addr","0.0.0.0")


# Live Stream
# Live Mount URL
livem = "http://hawkwynd.com:8000/test"

# Buffer
live_buffer = 5.
live_buffer_max = 15.



# Add a skip function to a source
# when it does not have one
# by default
def add_skip_command(~command,s)
	# Register the command:
	server.register(
		usage="skip",
		description="Skip the current song in source.",
		command,
		fun(_) -> begin source.skip(s) "Skipping current song." end
	)
end

# Define crossfade and smooth_add
def crossfade(s)
  #duration is automatically overwritten by metadata fields passed in
  #with audio
  s = fade.in(type="sin", duration=4., s)
  s = fade.out(type="sin", duration=5., s)
  fader = fun (a,b) -> add(normalize=false,[b,a])
  cross(fader,s)
end

def smooth_add(~delay=0.5,~p=0.2,~normal,~special)
  d = delay
  fade.final = fade.final(duration=d*2.)
  fade.initial = fade.initial(duration=d*2.)
  q = 1. - p
  c = amplify
  fallback(track_sensitive=false,
           [special,normal],
           transitions=[
             fun(normal,special)->
               add(normalize=false,
                   [c(p,normal),
                    c(q,fade.final(type="sin",normal)),
                    sequence([blank(duration=d),c(q,special)])]),
             fun(special,normal)->
               add(normalize=false,
                   [c(p,normal),
                    c(q,fade.initial(type="sin",normal))])
           ])
end


# MainStream Top40 List
# =====================
MainStream  = playlist( id="main", mode="randomize", reload_mode="rounds", reload=1, mime_type="audio/x-mpegurl", "~/playlist/a-z-bands-of-rock.pls" )

# nrj: Compress and normalize, producing a more uniform and “full” sound.
jingles     = nrj( audio_to_stereo( playlist( id="jingles", mode="randomize", reload_mode="rounds", reload=1,mime_type="audio/x-mpegurl", "~/playlist/jingles.m3u") ) )


# live stream (greystone)
liveshow = nrj(audio_to_stereo(input.http(buffer=live_buffer,max=live_buffer_max,livem)))


# define our station identifier Top Of The Hour
# ============================================
clock =  single("~/music/jingles/hawkad1.mp3")

# set our requests id, to accept requests the LR
requests = request.queue( id="requested" )

# Band Playlists top-bottom play normal
# =====================================
mellow      = playlist( id="mellow",mode="randomize",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/mellow-mornings.m3u" )
ACDC        = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/AC-DC.m3u" )
Beatles     = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/Beatles.m3u" )
jambros     = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/jambros.m3u" )
LedZeppelin = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/Led-Zeppelin.m3u" )
PinkFloyd   = playlist( id="main",mode="normal",reload_mode="rounds",reload=1, mime_type="audio/x-mpegurl","~/playlist/Pink-Floyd.m3u" )
Rush        = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/Rush.m3u" )
TheCrusaders= playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/The-Crusaders.m3u" )
ThePolice   = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/The-Police.m3u" )
Yes         = playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/Yes.m3u" )
FridayNightShow= playlist( id="main",mode="normal",reload_mode="rounds",reload=1,mime_type="audio/x-mpegurl", "~/playlist/1-3-19-liveshow.m3u" )

# Weekdays listings
# =================
sunday      = rotate( weights=[1,4], [jingles, Beatles])
monday      = rotate( weights=[1,4], [jingles, TheCrusaders])
tuesday     = rotate( weights=[1,4], [jingles, LedZeppelin])
wednesday   = rotate( weights=[1,4], [jingles, ThePolice])
thursday    = rotate( weights=[1,3,2],[jingles, Rush, LedZeppelin] )
friday      = rotate( weights=[1,4], [jingles, Yes])
Freplay     = rotate( weights=[1,4], [jingles, FridayNightShow ])

# Rotating Mainstream
# ===================================================
rotating    = rotate( weights=[ 1, 4 ], [ jingles, MainStream ] )

# set up play for radio, dont interupt tracks
# for requests, jingles. 

radio = fallback( track_sensitive=true, 
[ liveshow, requests,
    switch( track_sensitive=true, 
    [
        # midnight to 1am every night it's the Pink Floyd hour
        ({0h-1h}, rotate( weights=[1,4], [jingles, PinkFloyd])),

        #sunday 7a-noon Sunday morning with the Beatles
        ({ (0w) and 07h-12h }, sunday), 
        #  12-1pm Jambros hour
        ({ (0w) and 12h-13h}, rotate( weights=[1,4],[jingles, jambros] )),
        # 1-2pm Zeppelin hour
        ({ (0w) and 13h-14h}, rotate( weights=[1,4],[jingles, LedZeppelin] )),
        #  2-3pm The Police Hour
        ({ (0w) and 14h-15h}, rotate( weights=[1,4],[jingles, ThePolice] )),
        
        #monday
        # 6-7am mellow out
        ({ (1w) and 06h-7h }, mellow ), 
        #  3-4pm The monday
        ({ (1w) and 15h-16h}, rotate( weights=[1,4],[jingles, monday] )),
        
        # tuesday
        # 6-7 mellow out
        ({ (2w) and 6h-7h }, mellow ), 
        #  3-4pm tuesday
        ({ (2w) and 15h-16h}, rotate( weights=[1,4],[jingles, tuesday] )),
        
        # wednesday
        # 6-7am mellow out
        ({ (3w) and 6h-7h }, mellow), 
        #  3-4pm The wednesday
        ({ (3w) and 15h-16h}, rotate( weights=[1,4],[jingles, wednesday] )),
        
        ### Thursday ###

        # 6-7am mellow out
        ({ (4w) and 6h-7h }, mellow), 
        #  3-4pm The Rush Zeppelin hour and police
        ({ (4w) and 15h-16h}, rotate( weights=[1,4],[jingles, thursday] )),
        
        ### Friday ###
        
        # 6-7am mellow out
        # 3-4pm ACDAC ATTACK
        # 7-9pm Crusaders
        ({ (5w) and 6h-7h }, mellow ), 
        ({ (5w) and 18h-19h }, friday ),
        ({ (5w) and 19h-21h}, monday ),
        ({ (5w) and 15h-16h}, rotate( weights=[1,4],[jingles, ACDC] )),
        
        # Saturday
        # 6-7am mellow out
        # 7-9am Coffee with The Beatles (2hrs)
        ({ (6w) and 6h-7h }, mellow), 
        ({ (6w) and 07h-09h }, rotate( weights=[1,4], [jingles, Beatles])),
        # 9-930 Zeppelin
        ({ (6w) and 9h-9h30}, rotate( weights=[1,4],[jingles, LedZeppelin] )), 
        # 930-10 Police
        ({ (6w) and 9h30-10h}, rotate( weights=[1,4],[jingles, ThePolice])),       
        # 12 - 2pm Friday Night Replay with some MainStream mixed in
        ({ (6w) and 12h-14h}, rotate( weights=[1,4,2],[ jingles, Freplay, MainStream ] ))

    ]
    ),
        # All other times/days play rotating:
        rotating
])

# Normalize the playback of our stream
radio = normalize( gain_max=6.0, gain_min=-6.0,k_down=0.1,k_up=0.005,target=1.0,threshold=-25.0,window= 0.1, radio )

# at top of the hour, play a specific radio identifier over the playing track
radio  = add([ radio, switch([ ( {0m0s}, clock ) ] ) ] )

# amplify our signal to level shit out based on replay_gain metadata in the track. 
radio = amplify( 1.0, override = "replay_gain", radio )

# Add a skip command for use via telnet
add_skip_command(command="skip", radio)

# Send to greystone local  station
# output.shoutcast(
#     %mp3,
#     host        = "35.174.26.109", 
#     name        = "Greystone Rocks", 
#     url         = "http://stream.hawkwynd.com", 
#     genre       = "Classic Rock",  
#     port        = 8000, 
#     password    = "scootre#2",
#     public      = true,
#     fallible    = true,
#     radio
# )

# Send to Hawkwynd Radio station
output.shoutcast(
    %mp3,
    host        = "35.174.26.109", 
    name        = "Hawkwynd Radio", 
    url         = "http://stream.hawkwynd.com", 
    genre       = "Classic Rock",  
    port        = 8000, 
    password    = "scootre",
    public      = true,
    fallible    = true,
    radio
)

# shoot it all out to the soundcard so we can hear it in the sound booth!!
out(radio)

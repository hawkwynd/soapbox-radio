#!/usr/bin/liquidsoap

# turn on logging, and open connections to telnet 1234
set("log.level", 3 ) # 3 is default
set("log.file.path","ambient-radio.log")
set("server.telnet", true)
set("server.telnet.port", 1234)
set("harbor.bind_addr","0.0.0.0") 
set("harbor.timeout",60.)

AmbientList  = playlist( id="main", mode="randomize", reload_mode="watch", reload=0, mime_type="audio/x-mpegurl", "/home/scott/Music/State Azure/" )
radio = normalize( AmbientList )

output.shoutcast(
    %mp3,
    host        = "35.174.26.109", 
    name        = "Infinity Ambient", 
    url         = "http://hawkwynd.com:8000/ambient", 
    genre       = "Ambient",  
    port        = 8000, 
    password    = "scootre:#3",
    public      = true,
    fallible    = true,
    radio
)
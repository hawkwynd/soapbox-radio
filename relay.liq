#!/usr/bin/liquidsoap

# turn on logging, and open connections to telnet 1234
set("log.level", 1 ) # 3 is default
set("log.file.path","relay-radio.log")
# set("server.telnet", true)
# set("server.telnet.port", 1235)
# set("harbor.bind_addr","0.0.0.0") 
# set("harbor.timeout",60.)

#  A christmas stream from internet-radio.com

url     = "http://85.25.217.22:8050/listen.pls?sid=1"
radio   = input.http(url)

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

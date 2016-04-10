a=import("\Source.avs").subtitle("Source", align=9)################################################################################### REPLACE WITH THE RIGHT FILE
b=ffvideosource("\FINAL_ENCODE.mkv").subtitle("ENCODE", align=9).ffinfo(framenum=true,frametype=true,cfrtime=false,vfrtime=false)##### REPLACE WITH THE RIGHT FILE

interleave(a,b)
spline36resize(converttorgb,ffsar>1?round(width*ffsar):width,ffsar<1?round(height/ffsar):height)
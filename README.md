# Requirements
 - Windows
 - MATLAB installed (created and tested with R2014a)
 - AviSynth with plugins
 - AvsPmod
 
-----------------------------------------------------------------------------------------------

# Instructions
##### - Open source.avs
 - Replace the command attributes according to the #notes
 - With the command SelectRangeEvery use a maximum of 200 to 400 frames (depending on how fast your machine is).
 - Save
##### - Run ".---RUN_THIS_ONLY---.bat"
 - Select your source.avs
 - Select if you want to test the default value ranges of the x264 settings, or you want to enter them by yourself.
 - Select if you know what bitrate you want to use for your final encode.
 - If you click No, you'll have to enter what is the bitrate (in kbps) of your source, and after some processing it will show you a diagram of how the bitrate and the transparency changes for different CRF values. Then you'll have to enter what CRF value is the optimal so the encoder will use that bitrate to continue with the tests. If you click Yes, you'll have to enter what bitrate (in kbps) you want to use for the tests.
 - Testing has now began. After testing each setting it will show you a diagram with the results of each comparing-algorithm and the bitrate. You'll have to choose what is your desired value for the current setting (the best result of the SSI algorithm is the default).
 - Continue by following the simple instructions.
##### - Done. The results are now saved in a text file inside the program's folder.

-----------------------------------------------------------------------------------------------

# Default value ranges of the x264 settings
 - qcomp min: 0.5, max: 0.8, step: 0.05
 - aqmode min: 1, max: 3, step: 1
 - aq-strength min: 0.5, max: 1.1, step: 0.05
 - psyrd min: 0.6:0, max: 1.2:0.1, step: 0.05
 - deblock, mbtree and dct-decimate are also tested
 

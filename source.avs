########################### FOR DVD ###########################

MPEG2Source(\DVD.d2v", cpu=0)##################################################################### REPLACE WITH THE RIGHT FILE
TFM(d2v="\DVD.d2v", clip2=QTGMC().SelectEven())################################################### REPLACE WITH THE RIGHT FILE
##### ONLY IF IT'S TELECINED #####TFM(d2v="\DVD.d2v", clip2=QTGMC().SelectEven()).TDecimate()##### ONLY IF IT'S TELECINED

########################### FOR BLURAY ###########################

FFVideoSource("\REMUX.mkv")####################################################################### REPLACE WITH THE RIGHT FILE
##### ONLY IF IT'S TELECINED #####TFM(clip2=QTGMC().SelectEven()).TDecimate()##################### ONLY IF IT'S TELECINED

########################### AND THEN ##########################

Crop(0, 0, -0, -0)################################## REPLACE WITH THE RIGHT VALUES
Spline36Resize(1920,1080)########################### REPLACE WITH THE RIGHT VALUES
Trim(8000,120000)
SelectRangeEvery(10000,5,1)######################### REPLACE WITH THE RIGHT VALUES
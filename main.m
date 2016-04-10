close all;clear all;clc;
moviepath=pwd;

allready = menu('Before you continue, you must first follow the instructions in the README file','I have done that!','Exit');
if allready == 2 || allready == 0
   exit
end

AVSFileName=0;AVSPathName=0;
[AVSFileName,AVSPathName] = uigetfile('*.avs','Select the source AviSynth script');
if isequal(AVSFileName,0) == 1 || isequal(AVSPathName,0) == 1 
    exit
end

%WWWWWWWWWWWWWWWWWWW DELETE PNGS WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
Source_pngs=(strrep('-\pngs\source\*.png', '-', moviepath));
Source_png_Folder=(strrep('-\pngs\source\', '-', moviepath));
Encode_pngs=(strrep('-\pngs\encode\*.png', '-', moviepath));
Encode_png_Folder=(strrep('-\pngs\encode\', '-', moviepath));
Source_dir=dir(Source_pngs);
Encode_dir=dir(Encode_pngs);

if isempty(Source_dir)==0 || isempty(Encode_dir)==0
    DeleteChoise = menu('The previous generated png files should be removed. Do you want to delete them?','Yes (strongly recommended)','No');
    if DeleteChoise == 1
        NOS=length(Source_dir);
        NOE=length(Encode_dir);  
        for i=1:NOE           
            Encode_PNG=[Encode_png_Folder Encode_dir(i).name];
            delete(Encode_PNG);
        end
        for i=1:NOS           
            Source_PNG=[Source_png_Folder Source_dir(i).name];
            delete(Source_PNG);
        end
    end 
end

%WWWWWWWWWWWWWWWWWWW SELECT RANGES WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
setranges = menu('Do you want to test the default value ranges?','Yes (recommended)','No, I will enter them myself.');
if setranges==2
    prompt = {'Enter qcomp minimum value:','Enter qcomp maximum value:','Step:'};
    dlg_title = 'qcomp settings';
    num_lines = 1;
    defaultans = {'0.5','0.8','0.05'};
    QCOMPSettings = inputdlg(prompt,dlg_title,num_lines,defaultans);

    QCOMPmin=str2num(cell2mat(QCOMPSettings(1)))
    QCOMPmax=str2num(cell2mat(QCOMPSettings(2)))
    QCOMPstep=str2num(cell2mat(QCOMPSettings(3)))


    prompt = {'Enter aqmode minimum value:','Enter aqmode maximum value:'};
    dlg_title = 'aqmode settings';
    num_lines = 1;
    defaultans = {'1','3'};
    AQMODEsettings = inputdlg(prompt,dlg_title,num_lines,defaultans);

    AQModemin=str2num(cell2mat(AQMODEsettings(1)))
    AQModemax=str2num(cell2mat(AQMODEsettings(2)))


    prompt = {'Enter aq-strength minimum value:','Enter aq-strength maximum value:','Step:'};
    dlg_title = 'aq-strength settings';
    num_lines = 1;
    defaultans = {'0.5','1.1','0.05'};
    AQSTRENGTHSettings = inputdlg(prompt,dlg_title,num_lines,defaultans);

    AQSTRENGTHmin=str2num(cell2mat(AQSTRENGTHSettings(1)))
    AQSTRENGTHmax=str2num(cell2mat(AQSTRENGTHSettings(2)))
    AQSTRENGTHstep=str2num(cell2mat(AQSTRENGTHSettings(3)))


    prompt = {'Enter psyrd minimum value:',':','Enter psyrd maximum value:',':','Step:'};
    dlg_title = 'aq-strength settings';
    num_lines = 1;
    defaultans = {'0.6','0','1.2','0.1','0.05'};
    PSYRDSettings = inputdlg(prompt,dlg_title,num_lines,defaultans);

    PSYmin=str2num(cell2mat(PSYRDSettings(1)))
    PSYmax=str2num(cell2mat(PSYRDSettings(3)))
    RDmin=str2num(cell2mat(PSYRDSettings(2)))
    RDmax=str2num(cell2mat(PSYRDSettings(4)))
    PSYRDstep=str2num(cell2mat(PSYRDSettings(5)))

else
    QCOMPmin=0.5
    QCOMPmax=0.8
    QCOMPstep=0.05
    AQModemin=1
    AQModemax=3
    AQSTRENGTHmin=0.5
    AQSTRENGTHmax=1.1
    AQSTRENGTHstep=0.05
    PSYmin=0.6
    PSYmax=1.2
    RDmin=0
    RDmax=0.1
    PSYRDstep=0.05
end

%WWWWWWWWWWWWWWWWWWW EXTRACT SOURCE/ZIPS WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
if exist('x264.zip', 'file')==2
    unzip('x264.zip')
    delete('x264.zip')
end
cd mkvs
if exist('ffmpeg.zip', 'file')==2
    unzip('ffmpeg.zip')
    delete('ffmpeg.zip')
end
if exist('ffprobe.zip', 'file')==2
    unzip('ffprobe.zip')
    delete('ffprobe.zip')
end

copyfile('source.bat','source_new.bat')
find_and_replace('source_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('source_new.bat', '\\source.avs', AVSFileName)
find_and_replace('source_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
dos('source_new.bat')
cd ../;cd pngs/source
movefile('../../mkvs/*.png')
[heigh,width,z]=size(imread('source_00001.png'))

ref=floor( 32768 / ( ceil( width / 16 ) * ceil( heigh / 16 ) ) )
cd ../../;

knofinalbitrate = menu('Do you know what bitrate you want to use for your final encode?','No','Yes');
if knofinalbitrate~=2%-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$

skipcrf = menu('Do you want to skip Bitrate/Transparency comparisons for different CRF settings?','No (recommended)','Yes, I know what CRF I want to use.');
if skipcrf~=2%--------------------------------------------------------------------------------------------
    
%WWWWWWWWWWWWWWWWWWW SOURCE BITRATE QUESTION WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
Source_Bit_Rate=[];
while isempty(Source_Bit_Rate)==1
while isempty(Source_Bit_Rate)==1
    prompt = {'Enter the bit-rate of the source (kbps):'};
    dlg_title = 'User Input';
    num_lines = 1;
    defaultans = {'20000'};
    Source_Bit_Rate = inputdlg(prompt,dlg_title,num_lines,defaultans);
    
end
Source_Bit_Rate=str2num(Source_Bit_Rate{:})
end

%WWWWWWWWWWWWWWWWWWW TEST CRF WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
copyfile('crftest1.bat','crftest1_new.bat');
find_and_replace('crftest1_new.bat', '--ref 16', ['--ref ' num2str(ref)]);
find_and_replace('crftest1_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest1_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest1_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
CRF=23;
k=1;
while CRF>13
copyfile('crftest1_new.bat','CRF_TEST.bat');
find_and_replace('CRF_TEST.bat', 'THE_CRF', num2str(CRF))
find_and_replace('CRF_TEST.bat', 'FILENAME', num2str(CRF))
dos('CRF_TEST.bat');
cd mkvs;

%%%%%%%%%%%%%% get crf.mkv bitrate %%%%%%%%%%%%%%%
copyfile('bitrate.bat','bitrate_new.bat')
find_and_replace('bitrate_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('bitrate_new.bat', 'THE_CRF', num2str(CRF))
dos('bitrate_new.bat')

file = textread('bitrate.txt', '%s', 'delimiter', '\n');
bit_rate=file{2,1};
bit_rate_all(k)=ceil(str2num(strrep(bit_rate, 'bit_rate=', ''))/1024)

%%%%%%%%%%%%%% explode crf.mkv %%%%%%%%%%%%%%%%%%
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', num2str(CRF))
dos('batch_new.bat')

%%%%%%%%%%%%%% move and compare %%%%%%%%%%%%%%%%%
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../

[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,0,0,0,0,0,0,0,0,1);

for l=1:length(Zeros)
CRF_Zeros(l,k)=Zeros(l);
end

k=k+1
CRF=CRF-1;
end

%WWWWWWWWWWWWWWWWWWW GET TRANSPARENCYWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
for q=1:length(CRF_Zeros(:,1))
    for e=1:length(CRF_Zeros(1,:))
        Transparency(q,e)=CRF_Zeros(q,e)/(width*heigh*3);   
        MeanTransparency(e)=mean(Transparency(:,e));
    end    
end

%WWWWWWWWWWWWWWWWWWW PLOT WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
figure('units','normalized','outerposition',[0 0 1 1])
x=linspace(21,14,length(MeanTransparency(1,:)));
x2=linspace(1,1,length(MeanTransparency(1,:)));
x3=linspace(0.998,0.998,length(MeanTransparency(1,:)));
plot(x,x2,'r',x,MeanTransparency(1,:),'b-o',x,(bit_rate_all(1,:)/Source_Bit_Rate),'g-o',x,x3,'r')
title('Transparency / Bit-rate Plot')
xlabel('CRF')
legend('Source','Transparency','Bitrate','Location','northwest')
set(gca,'XTick',fliplr(x));
set(gca, 'xdir','reverse')
set(findall(gca, 'Type', 'Line'),'LineWidth',2);saveas(gcf,'CRF_comparison.png');
saveas(gcf,'CRF_comparison.fig','fig');
end%--------------------------------------------------------------------------------------------

%WWWWWWWWWWWWWWWWWWW CRF QUESTION WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
STOP_CRF=[];
while isempty(STOP_CRF)==1
    while isempty(STOP_CRF)==1
    prompt = {'Enter the desired CRF:'};
    dlg_title = 'User Input';
    num_lines = 1;
    defaultans = {'17'};
    STOP_CRF = inputdlg(prompt,dlg_title,num_lines,defaultans);
    end
    STOP_CRF=str2num(STOP_CRF{:})
end

if skipcrf~=2;close;end;

if skipcrf==2 || any(STOP_CRF==x)==0%--------------------------------------------------------------------------------------------        
    copyfile('crftest1.bat','crftest1_new.bat');
    find_and_replace('crftest1_new.bat', '--ref 16', ['--ref ' num2str(ref)]);
    find_and_replace('crftest1_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
    find_and_replace('crftest1_new.bat', 'source.avs', AVSFileName)
    find_and_replace('crftest1_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
    copyfile('crftest1_new.bat','CRF_TEST.bat');
    find_and_replace('CRF_TEST.bat', 'THE_CRF', num2str(STOP_CRF))
    find_and_replace('CRF_TEST.bat', 'FILENAME', num2str(STOP_CRF))
    dos('CRF_TEST.bat');
    cd mkvs;
    %%%%%%%%%%%%%% get crf.mkv bitrate %%%%%%%%%%%%%%%
    copyfile('bitrate.bat','bitrate_new.bat')
    find_and_replace('bitrate_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
    find_and_replace('bitrate_new.bat', 'THE_CRF', num2str(STOP_CRF))
    dos('bitrate_new.bat')
    file = textread('bitrate.txt', '%s', 'delimiter', '\n');
    bit_rate2=file{2,1};
    bit_rate=num2str(ceil(str2num(strrep(bit_rate2, 'bit_rate=', ''))/1024))
    cd ../        
else
    bit_rate=num2str(bit_rate_all((21-STOP_CRF)*2+1))
end%--------------------------------------------------------------------------------------------

else%-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$
    bit_rate=[];
    while isempty(bit_rate)==1
        while isempty(bit_rate)==1
        prompt = {'Enter the bitrate you want to use:'};
        dlg_title = 'User Input';
        num_lines = 1;
        defaultans = {'10000'};
        bit_rate = inputdlg(prompt,dlg_title,num_lines,defaultans);
        end
        bit_rate=num2str(bit_rate{:})
    end

end%-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$-----$$$$$


%WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW START TESTS WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
%----------------------TEST QCOMP----------------------
qcomp=QCOMPmin
u=1;
while qcomp<QCOMPmax+QCOMPstep
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('crftest2_new.bat', '--ref 16', ['--ref ' num2str(ref)]);
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', 'qcomp 0.60', ['qcomp ' num2str(qcomp)])
find_and_replace('crftest2_new.bat', 'FILENAME', ['qcomp ' num2str(qcomp)])
dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', ['qcomp ' num2str(qcomp)])
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../

[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,1,1,1,1,1,1,1,1,1);

for l=1:length(Zeros)    
    QCOMP_MSE(l,u)=MSE(l);
    QCOMP_PSNR(l,u)=PSNR(l);
    QCOMP_NK(l,u)=NK(l);
    QCOMP_AD(l,u)=AD(l);
    QCOMP_SC(l,u)=SC(l);
    QCOMP_MD(l,u)=MD(l);
    QCOMP_NAE(l,u)=NAE(l);
    QCOMP_SSI(l,u)=SSI(l);
    QCOMP_Zeros(l,u)=Zeros(l);    
end

u=u+1;
qcomp=qcomp+QCOMPstep

end

FinalQcomp=BTPQ(moviepath,'qcomp',QCOMPmin,QCOMPmax+QCOMPstep,length(QCOMP_Zeros(1,:)),QCOMP_MSE,QCOMP_PSNR,QCOMP_NK,QCOMP_AD,QCOMP_SC,QCOMP_MD,QCOMP_NAE,QCOMP_SSI,QCOMP_Zeros,QCOMPstep)

%----------------------TEST AQ MODE ----------------------
mode=AQModemin
u=1;
while mode<AQModemax+1
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('crftest2_new.bat', '--ref 16', ['--aq-mode 1 --ref ' num2str(ref)]);
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', 'qcomp 0.60', ['qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(mode)]);
find_and_replace('crftest2_new.bat', 'FILENAME', ['aq-mode ' num2str(mode)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', ['aq-mode ' num2str(mode)])
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../

[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,1,1,1,1,1,1,1,1,1);

for l=1:length(Zeros)    
    AQMode_MSE(l,u)=MSE(l);
    AQMode_PSNR(l,u)=PSNR(l);
    AQMode_NK(l,u)=NK(l);
    AQMode_AD(l,u)=AD(l);
    AQMode_SC(l,u)=SC(l);
    AQMode_MD(l,u)=MD(l);
    AQMode_NAE(l,u)=NAE(l);
    AQMode_SSI(l,u)=SSI(l);
    AQMode_Zeros(l,u)=Zeros(l);    
end

u=u+1;
mode=mode+1

end

FinalAQmode=BTPQ(moviepath,'aq-mode',AQModemin,AQModemax+1,length(AQMode_Zeros(1,:)),AQMode_MSE,AQMode_PSNR,AQMode_NK,AQMode_AD,AQMode_SC,AQMode_MD,AQMode_NAE,AQMode_SSI,AQMode_Zeros,1)

%----------------------TEST AQ STRENGTH ----------------------
strength=AQSTRENGTHmin
u=1;
while strength<AQSTRENGTHmax+AQSTRENGTHstep
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('crftest2_new.bat', '--ref 16', ['--aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', 'qcomp 0.60', ['qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(strength)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
find_and_replace('crftest2_new.bat', 'FILENAME', ['aq-strength ' num2str(strength)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', ['aq-strength ' num2str(strength)])
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../

[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,1,1,1,1,1,1,1,1,1);

for l=1:length(Zeros)    
    AQstrength_MSE(l,u)=MSE(l);
    AQstrength_PSNR(l,u)=PSNR(l);
    AQstrength_NK(l,u)=NK(l);
    AQstrength_AD(l,u)=AD(l);
    AQstrength_SC(l,u)=SC(l);
    AQstrength_MD(l,u)=MD(l);
    AQstrength_NAE(l,u)=NAE(l);
    AQstrength_SSI(l,u)=SSI(l);
    AQstrength_Zeros(l,u)=Zeros(l);    
end

u=u+1;
strength=strength+AQSTRENGTHstep

end

FinalAQstrength=BTPQ(moviepath,'aq-strength',AQSTRENGTHmin,AQSTRENGTHmax+AQSTRENGTHstep,length(AQstrength_Zeros(1,:)),AQstrength_MSE,AQstrength_PSNR,AQstrength_NK,AQstrength_AD,AQstrength_SC,AQstrength_MD,AQstrength_NAE,AQstrength_SSI,AQstrength_Zeros,AQSTRENGTHstep)

%----------------------TEST PSYRD ----------------------
psy=PSYmin
u=1;
while psy<PSYmax+PSYRDstep
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('crftest2_new.bat', '--ref 16', ['--psy-rd 0.70:0.00 --aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', 'qcomp 0.60', ['qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(FinalAQstrength)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
find_and_replace('crftest2_new.bat', 'FILENAME', ['psy-rd ' num2str(psy)]);
find_and_replace('crftest2_new.bat', '--psy-rd 0.70', ['--psy-rd ' num2str(psy)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', ['psy-rd ' num2str(psy)])
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../

[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,1,1,1,1,1,1,1,1,1);

for l=1:length(Zeros)    
    PSY_MSE(l,u)=MSE(l);
    PSY_PSNR(l,u)=PSNR(l);
    PSY_NK(l,u)=NK(l);
    PSY_AD(l,u)=AD(l);
    PSY_SC(l,u)=SC(l);
    PSY_MD(l,u)=MD(l);
    PSY_NAE(l,u)=NAE(l);
    PSY_SSI(l,u)=SSI(l);
    PSY_Zeros(l,u)=Zeros(l);    
end

u=u+1;
psy=psy+PSYRDstep

end

FinalPSY=BTPQ(moviepath,'psy-rd',PSYmin,PSYmax+PSYRDstep,length(PSY_Zeros(1,:)),PSY_MSE,PSY_PSNR,PSY_NK,PSY_AD,PSY_SC,PSY_MD,PSY_NAE,PSY_SSI,PSY_Zeros,PSYRDstep)

%----------------------TEST RD ----------------------
rd=RDmin
u=1;
while rd<RDmax+PSYRDstep
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('crftest2_new.bat', '--ref 16', ['--psy-rd 0.70:0.00 --aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', 'qcomp 0.60', ['qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(FinalAQstrength)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
find_and_replace('crftest2_new.bat', 'FILENAME', ['rd ' num2str(rd)]);
find_and_replace('crftest2_new.bat', '--psy-rd 0.70', ['--psy-rd ' num2str(FinalPSY)]);
find_and_replace('crftest2_new.bat', ':0.00', [':' num2str(rd)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', ['rd ' num2str(rd)])
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../

[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,1,1,1,1,1,1,1,1,1);

for l=1:length(Zeros)    
    RD_MSE(l,u)=MSE(l);
    RD_PSNR(l,u)=PSNR(l);
    RD_NK(l,u)=NK(l);
    RD_AD(l,u)=AD(l);
    RD_SC(l,u)=SC(l);
    RD_MD(l,u)=MD(l);
    RD_NAE(l,u)=NAE(l);
    RD_SSI(l,u)=SSI(l);
    RD_Zeros(l,u)=Zeros(l);    
end

u=u+1;
rd=rd+PSYRDstep

end

FinalRD=BTPQ(moviepath,'rd',RDmin,RDmax+PSYRDstep,length(RD_Zeros(1,:)),RD_MSE,RD_PSNR,RD_NK,RD_AD,RD_SC,RD_MD,RD_NAE,RD_SSI,RD_Zeros,PSYRDstep)

%----------------------DE BLOCK ----------------------

for u=1:2
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))

find_and_replace('crftest2_new.bat', '--ref 16', ['--psy-rd 0.70:0.00 --aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
if u==2
    find_and_replace('crftest2_new.bat', '--ref 16', ['--deblock -3:-3 --ref ' num2str(ref)]);
else
    find_and_replace('crftest2_new.bat', '--ref 16', ['--deblock -1:-1 --ref ' num2str(ref)]);
end
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', '--qcomp 0.60', ['--qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', 'FILENAME', ['deblock ' num2str(u)]);
find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(FinalAQstrength)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
find_and_replace('crftest2_new.bat', '--psy-rd 0.70', ['--psy-rd ' num2str(FinalPSY)]);
find_and_replace('crftest2_new.bat', ':0.00', [':' num2str(FinalRD)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', ['deblock ' num2str(u)])
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../
[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,0,0,0,0,0,0,0,1,0);

for l=1:length(SSI)
RD_Zeros(l,u)=SSI(l);
end

end

for e=1:length(RD_Zeros(1,:))
     MeanRD(e)=mean(RD_Zeros(:,e));
end 
[xRD,yRD]=max(MeanRD)
DEBLOCKSETTING=yRD

%----------------------no-mbtree ----------------------
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))

find_and_replace('crftest2_new.bat', '--ref 16', ['--no-mbtree --deblock -1:-1 --psy-rd 0.70:0.00 --aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
if DEBLOCKSETTING==2
    find_and_replace('crftest2_new.bat', '--deblock -1:-1', ['--deblock -3:-3 --ref ' num2str(ref)]);
end
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', '--qcomp 0.60', ['--qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', 'FILENAME', 'mbtree_OFF');
find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(FinalAQstrength)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
find_and_replace('crftest2_new.bat', '--psy-rd 0.70', ['--psy-rd ' num2str(FinalPSY)]);
find_and_replace('crftest2_new.bat', ':0.00', [':' num2str(FinalRD)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', 'mbtree_OFF')
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../
[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,0,0,0,0,0,0,0,1,0);
MeanMB=mean(SSI);

if MeanMB>xRD
    mbtree=0;newZeros=MeanMB;
else
    mbtree=1;newZeros=xRD;
end

%----------------------dct-decimate----------------------
copyfile('crftest2.bat','crftest2_new.bat');
find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))

find_and_replace('crftest2_new.bat', '--ref 16', ['--no-dct-decimate --no-mbtree --deblock -1:-1 --psy-rd 0.70:0.00 --aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
if DEBLOCKSETTING==2
    find_and_replace('crftest2_new.bat', '--deblock -1:-1', ['--deblock -3:-3 --ref ' num2str(ref)]);
end
if mbtree==1
    find_and_replace('crftest2_new.bat', '--no-mbtree ', '');
end
find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
find_and_replace('crftest2_new.bat', '--qcomp 0.60', ['--qcomp ' num2str(FinalQcomp)])
find_and_replace('crftest2_new.bat', 'FILENAME', 'decimate_OFF');
find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(FinalAQstrength)])
find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
find_and_replace('crftest2_new.bat', '--psy-rd 0.70', ['--psy-rd ' num2str(FinalPSY)]);
find_and_replace('crftest2_new.bat', ':0.00', [':' num2str(FinalRD)]);

dos('crftest2_new.bat');


cd mkvs;
copyfile('batch.bat','batch_new.bat')
find_and_replace('batch_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
find_and_replace('batch_new.bat', 'THE_CRF', 'decimate_OFF')
dos('batch_new.bat')
cd ../;cd pngs/encode
movefile('../../mkvs/*.png')
cd ../../
[MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,0,0,0,0,0,0,0,1,0);
MeanDCT=mean(SSI);

if MeanDCT>newZeros
    dct=0
else
    dct=1
end

%WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW PRINT WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
CreateFinal = menu('Do you want to do a test encode with the choosen settings?','Yes','No');
    if CreateFinal == 1        
        copyfile('crftest2.bat','crftest2_new.bat');
        find_and_replace('crftest2_new.bat', 'SOURCEPATH', strrep(AVSPathName, '\', '\\'))
        find_and_replace('crftest2_new.bat', 'source.avs', AVSFileName)
        find_and_replace('crftest2_new.bat', 'PATH', strrep(moviepath, '\', '\\'))
        find_and_replace('crftest2_new.bat', 'mkvs\', '')      

        find_and_replace('crftest2_new.bat', '--ref 16', ['--no-dct-decimate --no-mbtree --deblock -1:-1 --psy-rd 0.70:0.00 --aq-mode 1 --aq-strength 0.5 --ref ' num2str(ref)]);
        if DEBLOCKSETTING==2
            find_and_replace('crftest2_new.bat', '--deblock -1:-1', ['--deblock -3:-3 --ref ' num2str(ref)]);
        end
        if mbtree==1
            find_and_replace('crftest2_new.bat', '--no-mbtree ', '');
        end
        if dct==1
            find_and_replace('crftest2_new.bat', '--no-dct-decimate ', '');
        end
        find_and_replace('crftest2_new.bat', 'BIT_RATE', bit_rate)
        find_and_replace('crftest2_new.bat', '--qcomp 0.60', ['--qcomp ' num2str(FinalQcomp)])
        find_and_replace('crftest2_new.bat', 'FILENAME', 'FINAL_ENCODE');
        find_and_replace('crftest2_new.bat', 'aq-strength 0.5', ['aq-strength ' num2str(FinalAQstrength)])
        find_and_replace('crftest2_new.bat', '--aq-mode 1', ['--aq-mode ' num2str(FinalAQmode)]);
        find_and_replace('crftest2_new.bat', '--psy-rd 0.70', ['--psy-rd ' num2str(FinalPSY)]);
        find_and_replace('crftest2_new.bat', ':0.00', [':' num2str(FinalRD)]);

        dos('crftest2_new.bat');
    end 
    
clc
fprintf('\nThe test encode was saved in the working folder as FINAL_ENCODE.mkv\n')
Reference_Frames=ref
fprintf('\nChoosen values:\n')
Chosen_BitRate=vpa(bit_rate)
Chosen_Qcomp=vpa(FinalQcomp)
Chosen_AQMode=FinalAQmode
Chosen_AQStrength=vpa(FinalAQstrength)
Chosen_PSY=vpa(FinalPSY)
Chosen_RD=vpa(FinalRD)

fprintf('\nAlso the following values were chosen automatically considering the generated transparency:\n')

fprintf('\nDE BLOCK:\n')
if yRD==1
    fprintf('--deblock -1:-1\n')
    printedeblock='--deblock -1:-1';
else
    fprintf('--deblock -3:-3\n')
    printedeblock='--deblock -3:-3';
end

fprintf('\nmbtree:\n')
if mbtree==1
    fprintf('ON\n')
    printedmbtree='';
else
    fprintf('OFF\n')
    printedmbtree='--no-mbtree';
end

fprintf('\ndecimate:\n')
if dct==1
    fprintf('ON\n')
    printedct='';
else
    fprintf('OFF\n')
    printedct='--no-dct-decimate';
end
    
fprintf('\nThe diagrams were saved as png files in your folder.\n')    

fid = fopen('final_settings.txt','wt');
fprintf(fid, '--ref %s --bitrate %s --qcomp %s --aq-mode %s --aq-strength %s --psy-rd %s:%s %s %s %s ',num2str(ref),bit_rate,num2str(FinalQcomp),num2str(FinalAQmode),num2str(FinalAQstrength),num2str(FinalPSY),num2str(FinalRD),char(printedeblock),char(printedmbtree),char(printedct));
fclose(fid);

fprintf('The settings were also saved as final_settings.txt in your folder.\n') 

save('matlab.mat')

%WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW DELETE FILES WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
ALL_mkvs=(strrep('-\mkvs\*.mkv', '-', moviepath));
ALL_mkv_Folder=(strrep('-\mkvs\', '-', moviepath));
Source_pngs=(strrep('-\pngs\source\*.png', '-', moviepath));
Source_png_Folder=(strrep('-\pngs\source\', '-', moviepath));
Encode_pngs=(strrep('-\pngs\encode\*.png', '-', moviepath));
Encode_png_Folder=(strrep('-\pngs\encode\', '-', moviepath));

Source_dir=dir(Source_pngs);
Encode_dir=dir(Encode_pngs);
MKV_dir=dir(ALL_mkvs);

NOS=length(Source_dir);
NOE=length(Encode_dir);  
NOM=length(MKV_dir); 

if isempty(Source_dir)==0 || isempty(Encode_dir)==0
    DeletePNG = menu('Do you want to delete the generated frames (png files)?','Yes (recommended)','No');
    if DeletePNG == 1
        NOS=length(Source_dir);
        NOE=length(Encode_dir);  
        for i=1:NOE           
            Encode_PNG=[Encode_png_Folder Encode_dir(i).name];
            delete(Encode_PNG);
        end
        for i=1:NOS           
            Source_PNG=[Source_png_Folder Source_dir(i).name];
            delete(Source_PNG);
        end
    end 
end

if isempty(MKV_dir)==0
    DeleteMKV = menu('Do you want to delete the generated mkv files (except the final test encode)? (Remember that you can use them to do some comparisons)','Yes','No');
    if DeleteMKV == 1        
        for i=1:NOM           
            ALL_MKV=[ALL_mkv_Folder MKV_dir(i).name];
            delete(ALL_MKV);
        end
    end 
end

DeleteALL = menu('Do you want to delete all the other generated files (except the diagrams and the final_settings.txt)?','Yes (recommended)','No');
if DeleteALL == 1
    if exist('crftest1_new.bat','file')==2;delete('crftest1_new.bat');end
    if exist('crftest2_new.bat','file')==2;delete('crftest2_new.bat');end
    if exist('aq-mode.fig','file')==2;delete('aq-mode.fig');end
    if exist('aq-strength.fig','file')==2;delete('aq-strength.fig');end
    if exist('Psy-RDO.fig','file')==2;delete('Psy-RDO.fig');end
    if exist('Psy-Trellis.fig','file')==2;delete('Psy-Trellis.fig');end
    if exist('qcomp.fig','file')==2;delete('qcomp.fig');end
    if exist('CRF_comparison.fig','file')==2;delete('CRF_comparison.fig');end
    if exist('matlab.mat','file')==2;delete('matlab.mat');end
    if exist('CRF_TEST.bat','file')==2;delete('CRF_TEST.bat');end
    cd mkvs;
    if exist('batch_new.bat','file')==2;delete('batch_new.bat');end
    if exist('bitrate_new.bat','file')==2;delete('bitrate_new.bat');end
    if exist('source_new.bat','file')==2;delete('source_new.bat');end
    if exist('bitrate.txt','file')==2;delete('bitrate.txt');end
    cd ../
end
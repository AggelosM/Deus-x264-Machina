function Return=BTPQ(moviepath,TEST,min,max1,lengthx,MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros,val_step)
%WWWWWWWWWWWWWWWWWWWWWWWWWWWWWW GET BITRATE WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
cd mkvs
u=1;
min1=min;
while min1<max1
    copyfile('bitrate.bat','bitrate_new.bat');
    find_and_replace('bitrate_new.bat', 'PATH', strrep(moviepath, '\', '\\'));
    find_and_replace('bitrate_new.bat', 'THE_CRF', [TEST ' ' num2str(min1)]);
    dos('bitrate_new.bat');

    file = textread('bitrate.txt', '%s', 'delimiter', '\n');
    bit_rate_file=file{2,1};
    bit_rate(u)=ceil(str2num(strrep(bit_rate_file, 'bit_rate=', ''))/1024);

    u=u+1;
    min1=min1+val_step;
end

cd ../

%WWWWWWWWWWWWWWWWWWW GET MEAN WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
for e=1:lengthx
    MSE(isnan(MSE))=0;Mean_MSE(e)=mean(MSE(:,e));
    PSNR(isnan(PSNR))=99;Mean_PSNR(e)=mean(PSNR(:,e));
    NK(isnan(NK))=1;Mean_NK(e)=mean(NK(:,e));
    AD(isnan(AD))=0;Mean_AD(e)=mean(AD(:,e));
    SC(isnan(SC))=1;Mean_SC(e)=mean(SC(:,e));
    MD(isnan(MD))=0;Mean_MD(e)=mean(MD(:,e));
    NAE(isnan(NAE))=0;Mean_NAE(e)=mean(NAE(:,e));
    SSI(isnan(SSI))=0;Mean_SSI(e)=mean(SSI(:,e));
    Mean_Zeros(e)=mean(Zeros(:,e));
end

%WWWWWWWWWWWWWWWWWWW PLOT WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW
if strcmp(TEST,'psy-rd')
    TEST='Psy-RDO';
else if strcmp(TEST,'rd')
        TEST='Psy-Trellis';
    end
end

x=linspace(min,max1-val_step,length(Mean_MSE));

figure('units','normalized','Visible','off','outerposition',[0 0 1 1],'PaperPosition', [0 0 30 24])

subplot(5,2,1)
plot(x,Mean_MSE(1,:))
ylabel('Mean Square Error')
set(gca,'XTick',x);
%set(findall(gca, 'Type', 'Line'),'LineWidth',2);

subplot(5,2,2)
plot(x,Mean_MD(1,:))
ylabel('Maximum Difference')
set(gca,'XTick',x);

subplot(5,2,3)
plot(x,Mean_NK(1,:))
ylabel('Normalized Cross Correlation')
set(gca,'XTick',x);

subplot(5,2,4)
plot(x,Mean_Zeros(1,:),'y')
ylabel('Same pixels')
set(gca,'XTick',x);
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

subplot(5,2,5)
plot(x,Mean_SC(1,:))
ylabel('Structural Content')
set(gca,'XTick',x);

subplot(5,2,6)
plot(x,Mean_PSNR(1,:),'g')
ylabel('Peak Signal to Noise Ratio')
set(gca,'XTick',x);
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

subplot(5,2,7)
plot(x,Mean_NAE(1,:))
ylabel('Normalized Absolute Error')
set(gca,'XTick',x);

subplot(5,2,8)
plot(x,Mean_SSI(1,:),'r')
ylabel('Structural Similarity Index')
set(gca,'XTick',x);
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

subplot(5,2,9)
plot(x,Mean_AD(1,:))
ylabel('Average Difference')
xlabel([TEST ' value'])
set(gca,'XTick',x);

subplot(5,2,10)
plot(x,bit_rate(1,:),'k')
ylabel('Bitrate')
xlabel([TEST ' value'])
set(gca,'XTick',x);
set(findall(gca, 'Type', 'Line'),'LineWidth',2);

print(gcf, [TEST '.png'], '-dpng', '-r300' )
saveas(gcf,[TEST '.fig'],'fig');

[~,y]=max(Mean_SSI);

openfig([TEST '.fig'],'new','visible')
Return=[];
while isempty(Return)==1
    while isempty(Return)==1
        prompt = {['Enter the desired ' TEST ' value:']};
        dlg_title = 'User Input';
        num_lines = 1;
        defaultans = {num2str(min+val_step*(y-1))};
        Return = inputdlg(prompt,dlg_title,num_lines,defaultans);    
    end
    Return=str2num(Return{:})
end
close

%Return = (min+val_step*(y-1));
end
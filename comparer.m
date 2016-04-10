function [MSE,PSNR,NK,AD,SC,MD,NAE,SSI,Zeros]=comparer(moviepath,ON_MSE,ON_PSNR,ON_NK,ON_AD,ON_SC,ON_MD,ON_NAE,ON_SSI,ON_Zeros)
MSE=0;PSNR=0;NK=0;AD=0;SC=0;MD=0;NAE=0;SSI=0;Zeros=0;
Source_pngs=(strrep('-\pngs\source\*.png', '-', moviepath));
Source_png_Folder=(strrep('-\pngs\source\', '-', moviepath));
Encode_pngs=(strrep('-\pngs\encode\*.png', '-', moviepath));
Encode_png_Folder=(strrep('-\pngs\encode\', '-', moviepath));

Source_dir=dir(Source_pngs);
Encode_dir=dir(Encode_pngs);

NOS=length(Source_dir);
NOE=length(Encode_dir);

for i=1:NOE    
    Source_PNG=[Source_png_Folder Source_dir(i).name];
    Encode_PNG=[Encode_png_Folder Encode_dir(i).name];
    s=imread(Source_PNG);
    p=imread(Encode_PNG);
      
    if ON_Zeros==1
        D=imabsdiff(s,p);
        Zeros(i)=sum(D(:)==0);
    end
    
    if ON_MSE==1 || ON_PSNR==1 || ON_NK==1 || ON_AD==1 || ON_SC==1 || ON_MD==1 || ON_NAE==1 || ON_SSI==1
        
    %If the input image is rgb, convert it to gray image
    noOfDim = ndims(s);
    if(noOfDim == 3)
        s = rgb2gray(s);
    end
    
    noOfDim = ndims(p);
    if(noOfDim == 3)
        p = rgb2gray(p);
    end
    
    
    if ON_MSE==1
    %Mean Square Error 
    MSE(i) = MeanSquareError(s, p);
    end
    
    if ON_PSNR==1
    %Peak Signal to Noise Ratio 
    PSNR(i) = PeakSignaltoNoiseRatio(s, p);
    end
    
    if ON_NK==1
    %Normalized Cross-Correlation 
    NK(i) = NormalizedCrossCorrelation(s, p);
    end
    
    if ON_AD==1
    %Average Difference 
    AD(i) = AverageDifference(s, p);
    end

    if ON_SC==1
    %Structural Content 
    SC(i) = StructuralContent(s, p);
    end

    if ON_MD==1
    %Maximum Difference 
    MD(i) = MaximumDifference(s, p);
    end

    if ON_NAE==1
    %Normalized Absolute Error
    NAE(i) = NormalizedAbsoluteError(s, p);
    end

    if ON_SSI==1
    %Structural Similarity Index
    SSI(i) = ssim(p, s);
    end

    end

   
end
        
end




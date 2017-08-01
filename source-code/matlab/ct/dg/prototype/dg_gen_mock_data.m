% dg_gen_mock_data is a script that generates individual output data based on test requirements
% must read in the fits file first by running dg_controller (and read_ffi)
% read in data is 'fits.ffi' which has the correct final format
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
% 
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%


%%
% define the region of the  CCDs
starRow=21:1044;
starCol=13:1112;
leadingBlackRow=1:1070;
leadingBlackCol=1:12;
trailingBlackRow=1:1070;
trailingBlackCol=1113:1132;
maskedSmearRow=1:20;
maskedSmearCol=13:1112;
virtualSmearRow=1045:1070;
virtualSmearCol=13:1112;

% define gappedNum
gappedNum=2^32-1;

% define boundary values for high and low guard bands
maxHighGuard=(2^14-1);
minHighGuard=ceil(.95*maxHighGuard);

% Doug says that these should be a value for ea/ output (or pixels for ea/ output)
% that need to be read in 
maxLowGuard=floor(0.05*(2^14-1)); 
minLowGuard=0;

%% DG_test1 is normal data, so no processing

j=ceil(84.*rand(1));
DG_test1=ffiImage(:,:,j);
% scale the stars to range and randomize intensity
DG_test1=rand(1070,1132).*DG_test1/42*maxHighGuard; 
figure(1); imagesc(DG_test1);colormap(gray); title('normal data')


%% DG_test2 has star field at high guard band
j=ceil(84.*rand(1));
DG_test2=ffiImage(:,:,j);
DG_test2=rand(1070,1132).*DG_test2/42*maxHighGuard; % scale the stars to range and randomize intensity
starRegion=DG_test2(starRow, starCol);
newStarRegion=zeros(1024,1100);
numPix=0.1*1024*1100; % 10% of pixels are in  high guard band
indxHighGuard=ceil((1024*1100).*rand(numPix,1)); % uniformly randomize pixels in high guard band
newStarRegion(indxHighGuard)=minHighGuard+(maxHighGuard-minHighGuard)*(rand(numPix,1));
DG_test2(starRow, starCol)=starRegion+newStarRegion;
figure(2); imagesc(DG_test2);colormap(gray); title('10 % of star pixels in high guard band')

clear numPix starRegion newStarRegion indxHighGuard

%% DG_test3 has star field at low guard band
j=ceil(84.*rand(1));
DG_test3=ffiImage(:,:,j);
DG_test3=rand(1070,1132).*DG_test3/42*maxHighGuard; % scale the stars to range and randomize intensity
starRegion=DG_test3(starRow, starCol);
newStarRegion=zeros(1024,1100);
numPix=.1*1024*1100;
indxLowGuard=ceil((1024*1100).*rand(numPix,1)); % uniformly randomize pixels in low guard band
newStarRegion(indxLowGuard)=maxLowGuard*(rand(numPix,1));
DG_test3(starRow, starCol)=starRegion+newStarRegion;
figure(3); imagesc(DG_test3);colormap(gray); title('10 % of star pixels in low guard band')

clear numPix starRegion newStarRegion indxLowGuard

%% DG_test4 has collateral region at high guard band, i.e, >95% of 2^14-1 DN
j=ceil(84.*rand(1));
DG_test4=ffiImage(:,:,j);
DG_test4=rand(1070,1132).*DG_test4/42*maxHighGuard; % scale the stars to range and randomize intensity

leadingBlackRegion=DG_test4(leadingBlackRow, leadingBlackCol);
newLeadingBlackRegion=zeros(1070,12);
numPix=0.1*1070*12; % 10% of pixels are in low guard band
indxHighGuardLeadingBlack=ceil((1070*12).*rand(numPix,1)); % uniformly randomize pixels in high guard band in 10% of pix in LB
newLeadingBlackRegion(indxHighGuardLeadingBlack)=minHighGuard+(maxHighGuard-minHighGuard)*(rand(numPix,1));
DG_test4(leadingBlackRow, leadingBlackCol)=leadingBlackRegion+newLeadingBlackRegion;
clear numPix  indxHighGuardLeadingBlack leadingBlackRegion newLeadingBlackRegion

trailingBlackRegion=DG_test4(trailingBlackRow, trailingBlackCol);
newTrailingBlackRegion=zeros(1070,20);
numPix=0.1*1070*20;
indxHighGuardTrailingBlack=ceil((1070*20).*rand(numPix,1));
newTrailingBlackRegion(indxHighGuardTrailingBlack)=minHighGuard+(maxHighGuard-minHighGuard)*(rand(numPix,1));
DG_test4(trailingBlackRow, trailingBlackCol)=trailingBlackRegion+newTrailingBlackRegion;
clear numPix  indxHighGuardTrailingBlack trailingBlackRegion newTrailingBlackRegion

maskedSmearRegion=DG_test4(maskedSmearRow, maskedSmearCol);
newMaskedSmearRegion=zeros(20,1100);
numPix=0.1*20*1100;
indxHighGuardMaskedSmear=ceil((20*1100).*rand(numPix,1));
newMaskedSmearRegion(indxHighGuardMaskedSmear)=minHighGuard+(maxHighGuard-minHighGuard)*(rand(numPix,1));
DG_test4(maskedSmearRow, maskedSmearCol)=maskedSmearRegion+newMaskedSmearRegion;
clear numPix  indxHighGuardMaskedSmear maskedSmearRegion newMaskedSmearRegion

virtualSmearRegion=DG_test4(virtualSmearRow, virtualSmearCol);
newVirtualSmearRegion=zeros(26,1100);
numPix=0.1*26*1100;
indxHighGuardVirtualSmear=ceil((26*1100).*rand(numPix,1));
newVirtualSmearRegion(indxHighGuardVirtualSmear)=minHighGuard+(maxHighGuard-minHighGuard)*(rand(numPix,1));
DG_test4(virtualSmearRow, virtualSmearCol)=virtualSmearRegion+newVirtualSmearRegion;
clear numPix  indxHighGuardVirtualSmear virtualSmearRegion newVirtualSmearRegion

figure(4); imagesc(DG_test4);colormap(gray); title('10 % of collateral pixels at high guard band')

%% DG_test5 has collateral region at low guard band
j=ceil(84.*rand(1));
DG_test5=ffiImage(:,:,j);
DG_test5=rand(1070,1132).*DG_test5/42*maxHighGuard; % scale the stars to range and randomize intensity

leadingBlackRegion=DG_test5(leadingBlackRow, leadingBlackCol);
newLeadingBlackRegion=zeros(1070,12);
numPix=0.1*1070*12; % 10% of pixels are in low guard band
indxLowGuardLeadingBlack=ceil((1070*12).*rand(numPix,1)); % uniformly randomize pixels in high guard band in 10% of pix in LB
newLeadingBlackRegion(indxLowGuardLeadingBlack)=minLowGuard+(maxLowGuard-minLowGuard)*(rand(numPix,1));
DG_test5(leadingBlackRow, leadingBlackCol)=leadingBlackRegion+newLeadingBlackRegion;
clear numPix  indxLowGuardLeadingBlack leadingBlackRegion newLeadingBlackRegion

trailingBlackRegion=DG_test5(trailingBlackRow, trailingBlackCol);
newTrailingBlackRegion=zeros(1070,20);
numPix=0.1*1070*20;
indxLowGuardTrailingBlack=ceil((1070*20).*rand(numPix,1));
newTrailingBlackRegion(indxLowGuardTrailingBlack)=minLowGuard+(maxLowGuard-minLowGuard)*(rand(numPix,1));
DG_test5(trailingBlackRow, trailingBlackCol)=trailingBlackRegion+newTrailingBlackRegion;
clear numPix  indxLowGuardTrailingBlack trailingBlackRegion newTrailingBlackRegion

maskedSmearRegion=DG_test5(maskedSmearRow, maskedSmearCol);
newMaskedSmearRegion=zeros(20,1100);
numPix=0.1*20*1100;
indxLowGuardMaskedSmear=ceil((20*1100).*rand(numPix,1));
newMaskedSmearRegion(indxLowGuardMaskedSmear)=minLowGuard+(maxLowGuard-minLowGuard)*(rand(numPix,1));
DG_test5(maskedSmearRow, maskedSmearCol)=maskedSmearRegion+newMaskedSmearRegion;
clear numPix  indxLowGuardMaskedSmear maskedSmearRegion newMaskedSmearRegion

virtualSmearRegion=DG_test5(virtualSmearRow, virtualSmearCol);
newVirtualSmearRegion=zeros(26,1100);
numPix=0.1*26*1100;
indxLowGuardVirtualSmear=ceil((26*1100).*rand(numPix,1));
newVirtualSmearRegion(indxLowGuardVirtualSmear)=minLowGuard+(maxLowGuard-minLowGuard)*(rand(numPix,1));
DG_test5(virtualSmearRow, virtualSmearCol)=virtualSmearRegion+newVirtualSmearRegion;
clear numPix  indxLowGuardVirtualSmear virtualSmearRegion newVirtualSmearRegion

figure(5); imagesc(DG_test5);colormap(gray); title('10 % of collateral pixels at Low guard band')

%% DG_test6 has little 5% missing pixels in the star region 
j=ceil(84.*rand(1));
DG_test6=ffiImage(:,:,j);
DG_test6=rand(1070,1132).*DG_test6/42*maxHighGuard;% scale the stars to range and randomize intensity
numPix=0.05*1024*1100;
indxMissingData=ceil((1024*1100).*rand(numPix,1));
starRegion=DG_test6(starRow, starCol);
starRegion(indxMissingData)=gappedNum;
DG_test6(starRow, starCol)=starRegion;
clear numPix starRegion indxMissingData

figure(6); imagesc(DG_test6);colormap(gray); title('5 % missing  pixels in star field')


%% DG_test7 has entire missing pixels in the star region
j=ceil(84.*rand(1));
DG_test7=ffiImage(:,:,j);
DG_test7=rand(1070,1132).*DG_test7/42*maxHighGuard;% scale the stars to range and randomize intensity
DG_test7(starRow, starCol)=gappedNum;
figure(7); imagesc(DG_test7);colormap(gray); title('entire star field missing')

%% DG_test8 has little 5% missing pixels in the collateral region 
j=ceil(84.*rand(1));
DG_test8=ffiImage(:,:,j);
DG_test8=rand(1070,1132).*DG_test2/42*maxHighGuard; % scale the stars to range and randomize intensity

indxMissingDataLeadingBlack=ceil((1070*12).*rand(0.05*1070*12,1));
leadingBlackRegion=DG_test8(leadingBlackRow, leadingBlackCol);
leadingBlackRegion(indxMissingDataLeadingBlack)=gappedNum;
DG_test8(leadingBlackRow, leadingBlackCol)=leadingBlackRegion;
clear indxMissingDataLeadingBlack leadingBlackRegion 

indxMissingDataTrailingBlack=ceil((1070*20).*rand(0.05*1070*20,1));
trailingBlackRegion=DG_test8(trailingBlackRow, trailingBlackCol);
trailingBlackRegion(indxMissingDataTrailingBlack)=gappedNum;
DG_test8(trailingBlackRow, trailingBlackCol)=trailingBlackRegion;
clear indxMissingDataTrailingBlack trailingBlackRegion

indxMissingDataMaskedSmear=ceil((20*1100).*rand(0.05*20*1100,1));
maskedSmearRegion=DG_test8(maskedSmearRow, maskedSmearCol);
maskedSmearRegion(indxMissingDataMaskedSmear)=gappedNum;
DG_test8(maskedSmearRow, maskedSmearCol)=maskedSmearRegion;
clear indxMissingDataMaskedSmear maskedSmearRegion

indxMissingDataVirtualSmear=ceil((26*1100).*rand(0.05*26*1100,1));
virtualSmearRegion=DG_test8(virtualSmearRow, virtualSmearCol);
virtualSmearRegion(indxMissingDataVirtualSmear)=gappedNum;
DG_test8(virtualSmearRow, virtualSmearCol)=virtualSmearRegion;
clear indxMissingDataVirtualSmear virtualSmearRegion

figure(8); imagesc(DG_test8);colormap(gray); title('5 % missing  pixels in collateral region')


%% DG_test9 has entire missing pixels in the collateral region
j=ceil(84.*rand(1));
DG_test9=ffiImage(:,:,j);
DG_test9=rand(1070,1132).*DG_test9/42*maxHighGuard; % scale the stars to range and randomize intensity
DG_test9(leadingBlackRow, leadingBlackCol)=gappedNum;
DG_test9(trailingBlackRow, trailingBlackCol)=gappedNum;
DG_test9(maskedSmearRow, maskedSmearCol)=gappedNum;
DG_test9(virtualSmearRow, virtualSmearCol)=gappedNum;
figure(9); imagesc(DG_test9);colormap(gray); title('all pixels in collateral region missing')


%% DG_test10 and DG_test11 TBD...

%% 
clear starRow starCol leadingBlackRow leadingBlackCol trailingBlackRow trailingBlackCol...
maskedSmearRow maskedSmearCol virtualSmearRow virtualSmearCol gappedNum maxHighGuard...
minHighGuard maxLowGuard minLowGuard j
 

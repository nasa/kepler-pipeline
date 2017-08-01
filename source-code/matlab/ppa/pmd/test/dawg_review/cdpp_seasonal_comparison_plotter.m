%% set-up
% need to load current quarter pmdStructFile and then load Q-4 (or
% appropriate season file using:
% QNm4 = load('old_quarter_pmdStructFile_name')
% Next adjust quarter strings below
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

currentQ = 'Q15';
oldQ = 'Q11';

% set gaps
ng = ~pmdInputStructs(1).cadenceTimes.gapIndicators;
ngQm4 = ~QNm4.pmdInputStructs(1).cadenceTimes.gapIndicators;

%% Focal-plane %-change plots 12th & 14th mag
clear medCdpp9 medCdpp9QNm4 medCdpp12 medCdpp12QNm4 medCdpp14 medCdpp14QNm4

% 9th Mag
for i=1:80
     medCdpp9(i) = median(pmdOutputStructs(i).outputTsData.cdppMeasured.mag9.sixHour.values(ng));
     medCdpp9QNm4(i) = median(QNm4.pmdOutputStructs(i).outputTsData.cdppMeasured.mag9.sixHour.values(ngQm4));
     
end

% pad for Mod-3
medCdpp9=[medCdpp9(1:4),[NaN,NaN,NaN,NaN],medCdpp9(5:end)];
medCdpp9QNm4=[medCdpp9QNm4(1:4),[NaN,NaN,NaN,NaN],medCdpp9QNm4(5:end)];

display_focal_plane_metric(100*[medCdpp9'-medCdpp9QNm4']./medCdpp9QNm4',true)
colormap jet
set(gca,'fontSize',12)
caxis([-15,15])
title(['9th mag 6 hr ',currentQ,' - ', oldQ,' CDPP change (%)'])

print -dpng delta_cdpp_6hr_9mag.png

% 12th Mag
for i=1:80
     medCdpp12(i) = median(pmdOutputStructs(i).outputTsData.cdppMeasured.mag12.sixHour.values(ng));
     medCdpp12QNm4(i) = median(QNm4.pmdOutputStructs(i).outputTsData.cdppMeasured.mag12.sixHour.values(ngQm4));
     
end

% pad for Mod-3
medCdpp12=[medCdpp12(1:4),[NaN,NaN,NaN,NaN],medCdpp12(5:end)];
medCdpp12QNm4=[medCdpp12QNm4(1:4),[NaN,NaN,NaN,NaN],medCdpp12QNm4(5:end)];

display_focal_plane_metric(100*[medCdpp12'-medCdpp12QNm4']./medCdpp12QNm4',true)
colormap jet
set(gca,'fontSize',12)
caxis([-15,15])
title(['12th mag 6 hr ',currentQ,' - ', oldQ,' CDPP change (%)'])

print -dpng delta_cdpp_6hr_12mag.png

% 14th Mag
for i=1:80
     medCdpp14(i) = median(pmdOutputStructs(i).outputTsData.cdppMeasured.mag14.sixHour.values(ng));
     medCdpp14QNm4(i) = median(QNm4.pmdOutputStructs(i).outputTsData.cdppMeasured.mag14.sixHour.values(ngQm4));
     
end

% pad for Mod-3
medCdpp14=[medCdpp14(1:4),[NaN,NaN,NaN,NaN],medCdpp14(5:end)];
medCdpp14QNm4=[medCdpp14QNm4(1:4),[NaN,NaN,NaN,NaN],medCdpp14QNm4(5:end)];

display_focal_plane_metric(100*[medCdpp14'-medCdpp14QNm4']./medCdpp14QNm4',true)
colormap jet
set(gca,'fontSize',12)
caxis([-15,15])
title(['14th mag 6 hr ',currentQ,' - ', oldQ,' CDPP change (%)'])

print -dpng delta_cdpp_6hr_14mag.png


%% Line plots of median CDPP by channel
% 9th mag
figure
plot(1:84,medCdpp9,'b*-',1:84,medCdpp9QNm4,'ro-')
set(gca,'fontSize',12)
legend([currentQ, ' 6hr, 9th mag'],[oldQ,' 6hr, 9th mag'])

print -dpng cdpp_channel_6hr_9mag.png

% 12th mag
figure
plot(1:84,medCdpp12,'b*-',1:84,medCdpp12QNm4,'ro-')
set(gca,'fontSize',12)
legend([currentQ, ' 6hr, 12th mag'],[oldQ,' 6hr, 12th mag'])

print -dpng cdpp_channel_6hr_12mag.png

% 14th mag
figure
plot(1:84,medCdpp14,'b*-',1:84,medCdpp14QNm4,'ro-')
set(gca,'fontSize',12)
legend([currentQ, ' 6hr, 14th mag'],[oldQ,' 6hr, 14th mag'])

print -dpng cdpp_channel_6hr_14mag.png


%% 9th mag, diagnostic only
% figure
% for i=1:80,
%  
%     plot(pmdOutputStructs(i).outputTsData.cdppMeasured.mag9.sixHour.values(ng),'b'),
%     hold on, 
%     plot(QNm4.pmdOutputStructs(i).outputTsData.cdppMeasured.mag9.sixHour.values(ngQm4),'r--'),
%     if i<5
%         ch=i;
%     else
%         ch=i+4;
%     end
%     
% end
% 
%%

%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
expon = 1;
mod = 7;
out = 3;
nlinLocation = ['output/nonlinearstudy/nonlinear/run_long_m' num2str(mod) 'o' num2str(out) 's1/'];
linLocation = ['output/nonlinearstudy/linear/run_long_m' num2str(mod) 'o' num2str(out) 's1/'];

load([nlinLocation 'ccdSeries_pre_5.mat']);
nonlinPrePixData = ccdSeriesNoCr; 
clear ccdSeriesNoCr
load([linLocation 'ccdSeries_pre_5.mat']);
linPrePixData = ccdSeriesNoCr; 
figure(1);
plot(linPrePixData(:), (linPrePixData(:)./nonlinPrePixData(:)).^expon, '+')
title('before conversion to ADU');
xlabel('pixel value with no nonlinearity (electrons)');
ylabel('ratio of no nonlineaity to with nonlinearity');

load([nlinLocation 'ccdSeries_5.mat']);
nonlinPixData = ccdSeriesNoCr; 
clear ccdSeriesNoCr
load([linLocation 'ccdSeries_5.mat']);
linPixData = ccdSeriesNoCr; 
figure(2);
plot(linPixData(:), (linPixData(:)./nonlinPixData(:)).^expon, '+')
title('after conversion to ADU');
xlabel('pixel value with no nonlinearity (ADU)');
ylabel('ratio of no nonlineaity to with nonlinearity');

load([nlinLocation 'pixelData.mat']);
nonlinFinPixData = dataBufferNoCr; 
clear dataBufferNoCr
load([linLocation 'pixelData.mat']);
linFinPixData = dataBufferNoCr; 
figure(3);
plot(linFinPixData(:), (linFinPixData(:)./nonlinFinPixData(:)).^expon, '+')
title('before requantization');
xlabel('pixel value with no nonlinearity (ADU)');
ylabel('ratio of no nonlineaity to with nonlinearity');

nonlinPix = get_pixel_time_series(nlinLocation);
nonlinPixLin = [nonlinPix.pixelValues];
linPix = get_pixel_time_series(linLocation);
linPixLin = [linPix.pixelValues];
figure(4);
plot(linPixLin(:), (linPixLin(:)./nonlinPixLin(:)).^expon, '+');
title('requantized, as loaded by get_pixel_time_series');
xlabel('pixel value with no nonlinearity (ADU)');
ylabel('ratio of no nonlineaity to with nonlinearity');

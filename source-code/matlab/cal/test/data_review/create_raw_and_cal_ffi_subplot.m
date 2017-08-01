function create_raw_and_cal_ffi_subplot(channel, ffi, calFfi)
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


if nargin == 1
    ffi    =  '/path/to/flight/science/q4/ffi/kplr2010020005046_ffi-orig.fits';
    calFfi = '/path/to/flight/science/q4/calFfi/Instance_890/kplr2010020005046_ffi-SocCal.fits';
end

load /path/to/cal_Q4_data_review/gain_and_mean_black_arrays.mat

gain = gainArray(channel);  %  109.32;
meanBlack = meanBlackArray(channel); % 641;
fixedOffset = 419400;

% read in data
rawFfiForChannel = fitsread( ffi , 'image', channel);
calFfiForChannel = fitsread( calFfi , 'image', channel);


% Normalize CAL FFi
calFfiNormalized = (calFfiForChannel/gain) - meanBlack*270 + fixedOffset;


% set the scales
rawFfiScaled = (rawFfiForChannel - min(min(rawFfiForChannel)))./(max(max(rawFfiForChannel)) - min(min(rawFfiForChannel)));

calFfiScaled = (calFfiNormalized - min(min(calFfiNormalized)))./(max(max(calFfiNormalized)) - min(min(calFfiNormalized)));

figure;
ax(1) = subplot(2, 1, 1);
imagesc(rawFfiScaled);colorbar; colormap hot
caxis([prctile(rawFfiScaled(:), .1) prctile(rawFfiScaled(:), 99.1)])

title(['Raw FFI   Channel = ' num2str(channel)], 'fontsize', 12)
xlabel('CCD Column', 'fontsize', 12)
ylabel('CCD Row', 'fontsize', 12)
set(gca, 'YDir', 'normal')


ax(2) = subplot(2, 1, 2);
imagesc(calFfiScaled);colorbar; colormap hot
caxis([prctile(calFfiScaled(:), .1) prctile(calFfiScaled(:), 99.1)])

title(['Calibrated FFI   Channel = ' num2str(channel)], 'fontsize', 12)
xlabel('CCD Column', 'fontsize', 12)
ylabel('CCD Row', 'fontsize', 12)
set(gca, 'YDir', 'normal')

linkaxes(ax, 'xy')

return;

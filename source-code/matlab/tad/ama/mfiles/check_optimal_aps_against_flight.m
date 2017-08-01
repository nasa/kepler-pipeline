function check_optimal_aps_against_flight(module, output, targetListSetName)
% function check_optimal_aps_against_flight(module, output, targetListSetName)
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

flightFfiLocation ...
    = '/path/to/flight/commissioning/c032_fpg_ffi/pipeline_results/calFfi/instance-49/kplr2009112151725_ffi-SocCal.fits';

modOutStr = [num2str(module) '_' num2str(output)];

tadInputStruct = retrieve_tad_targets(module, output, targetListSetName);
completeOutputImage = tadInputStruct.coaImage;
optimalApertures = tadInputStruct.targets;

channel = convert_from_module_output(module, output);
flightFfi = fitsread(flightFfiLocation, 'Image', channel);

% remove smear
flightMedian = median(median(flightFfi(21:1043,13:1111)));
flightScale = std(std(flightFfi(21:1043,13:1111)));
scaledCoaImage = completeOutputImage - repmat(mean(completeOutputImage(1048:1068,:)), 1070,1);
coaImageMedian = median(median(scaledCoaImage(21:1043,13:1111)));
coaImageScale = std(std(scaledCoaImage(21:1043,13:1111)));
scaledCoaImage = (scaledCoaImage - coaImageMedian)*flightScale/coaImageScale + flightMedian;

maxBrightness = 0.95;
graymap = repmat(0:maxBrightness/2500:maxBrightness, 3,1)';
graymap = flipud(graymap);

% 	colorRange = [-0e5, 9e5];
colorRange = [5,7.6]; % post EE ffi

optApImage = zeros(size(scaledCoaImage));
nTargets = length(optimalApertures);
for t=1:nTargets
    if optimalApertures(t).keplerId ~= -1
        referenceRow = optimalApertures(t).referenceRow + 1;
        referenceColumn = optimalApertures(t).referenceColumn + 1;
        % draw the mask
        nApPix(t) = length([optimalApertures(t).offsets.row]);
        for p=1:nApPix(t)
            r = referenceRow + optimalApertures(t).offsets(p).row;
            c = referenceColumn + optimalApertures(t).offsets(p).column;
            optApImage(r, c) = 1;
        end
    end
end

figure(100);
ax(1) = subplot(1,3,1);
h = imagesc(log10(abs(flightFfi)), colorRange);
title('flight FFI');
set(h, 'Parent', ax(1));

ax(2) = subplot(1,3,2);
h = imagesc(optApImage);
title(['optimal apertures module ' num2str(module) ' output ' num2str(output)]);
set(h, 'Parent', ax(2));

ax(3) = subplot(1,3,3);
h = imagesc(log10(abs(scaledCoaImage)), colorRange);
title('TAD image');
set(h, 'Parent', ax(3));

colormap(graymap);

linkaxes(ax);
        



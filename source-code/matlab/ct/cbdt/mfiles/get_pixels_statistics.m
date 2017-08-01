function statStruct = get_pixels_statistics(FFIs, channel, highGuardBand, lowGuardBand, debugStatus)
%function statStruct = get_FFI_statistics(FFIs, channel)
% Extract and compute pixel statistics for all the five regions
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

% compute the original FFI image statistics using modoutClass

if ( nargin == 1 )
    % dummy value: it may trigger error depending how this is handled inside.
    channel = 1;
end

if ( nargin < 3 )
    debugStatus = false;
end

numOfFFIs = size(FFIs, 3);

[module, output] = convert_to_module_output(channel);

% dummy MJD values
startMjd = 0;
endMjd = 0;
numCoaddsFactor = 1; % pixel DN are normalized elsewhere
% pixel intensities get normalizedat this point
dgObj = dgTrimmedImageClass( module, output, numCoaddsFactor, startMjd, endMjd, FFIs(:, :, 1)); 
statStructTemp = dg_compute_stat(dgObj, highGuardBand, lowGuardBand);

% pre-allocate memory for the array
statStruct = repmat(statStructTemp, numOfFFIs);

for k = 2:numOfFFIs
    dgObj = dgTrimmedImageClass( module, output, numCoaddsFactor, startMjd, endMjd, FFIs(:, :, k));
    statStruct(k) = dg_compute_stat(dgObj, highGuardBand, lowGuardBand);
end

if ( debugStatus )
    for k = 1:numOfFFIs
        fprintf(' %2d, data completness [sci,lead, trail, masked, virtual]: [%.2f, %.2f, %.2f, %.2f, %.2f]\n', ...
            k, ...
            statStruct(k).star.percentPixelComplete, ...
            statStruct(k).leadingBlack.percentPixelComplete, ...
            statStruct(k).trailingBlack.percentPixelComplete, ...
            statStruct(k).maskedSmear.percentPixelComplete, ...
            statStruct(k).virtualSmear.percentPixelComplete);

        fprintf(' %2d, data mean [sci,lead, trail, masked, virtual]: [%.2f, %.2f, %.2f, %.2f, %.2f]\n', ...
            k, ...
            statStruct(k).star.mean, ...
            statStruct(k).leadingBlack.mean, ...
            statStruct(k).trailingBlack.mean, ...
            statStruct(k).maskedSmear.mean, ...
            statStruct(k).virtualSmear.mean);
        fprintf(' %2d, data std [sci,lead, trail, masked, virtual]: [%.2f, %.2f, %.2f, %.2f, %.2f]\n', ...
            k, ...
            statStruct(k).star.stdev, ...
            statStruct(k).leadingBlack.stdev, ...
            statStruct(k).trailingBlack.stdev, ...
            statStruct(k).maskedSmear.stdev, ...
            statStruct(k).virtualSmear.stdev);
        fprintf(' %2d, data min [sci,lead, trail, masked, virtual]: [%.2f, %.2f, %.2f, %.2f, %.2f]\n', ...
            k, ...
            statStruct(k).star.min, ...
            statStruct(k).leadingBlack.min, ...
            statStruct(k).trailingBlack.min, ...
            statStruct(k).maskedSmear.min, ...
            statStruct(k).virtualSmear.min);
        fprintf(' %2d, data max [sci,lead, trail, masked, virtual]: [%.2f, %.2f, %.2f, %.2f, %.2f]\n', ...
            k, ...
            statStruct(k).star.max, ...
            statStruct(k).leadingBlack.max, ...
            statStruct(k).trailingBlack.max, ...
            statStruct(k).maskedSmear.max, ...
            statStruct(k).virtualSmear.max);
    end

end

return;

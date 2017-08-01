function calOutputStruct = update_calOutput_w_photometric_variance(calOutputStruct, photoVarStruct)
%
% function calOutputStruct = update_calOutput_w_photometric_variance(calOutputStruct, photoVarStruct)
%
% This function places the uncertainties in the targetAndBackgroundPixels
% The modified CalOutputStruct is returned.
%
% INPUT:    calOutputStruct     = output structure from CAL
%           photometricVarStruct= structure containing the calculated
%                                 variance across cadences for a single
%                                 photometric data invocation in CAL.
% OUTPUT:   calOutputStruct     = same calOutputStruct as input with the
%                                 uncertainties for the photometric pixels
%                                 for this invocation populated.
%
%
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

photoVarName = fieldnames(photoVarStruct);

% extract uncertainties on used cadence indices
uncertainties = sqrt(photoVarStruct.(photoVarName{1}).variance);
usedCadenceIndex = photoVarStruct.(photoVarName{1}).usedCadenceIndex;

if( ~isreal(uncertainties) )
    warning(['CAL:',mfilename,':Complex uncertainties generated for photometric data. Taking real part.']);       %#ok<WNTAG>
    uncertainties = real(uncertainties);
end


% initially outputsStruct contains minimal pou
minimalPou = [calOutputStruct.targetAndBackgroundPixels.uncertainties];
gaps = [calOutputStruct.targetAndBackgroundPixels.gapIndicators];

% fill gaps in minimal pou with nearest neighbor before computing delta
[nCadences, nPixels] = size(minimalPou);
x = 1:nCadences;
for iPixel = 1:nPixels
    g = gaps(:,iPixel);
    gappedIndices = find(g);
    ungappedIndices = find(~g);
    if ~all(g)
        if ~isempty(gappedIndices)
            if length(ungappedIndices) > 1
                minimalPou(g,iPixel) = interp1(x(~g),minimalPou(~g,iPixel),gappedIndices,'nearest','extrap');
            elseif length(ungappedIndices) == 1
                minimalPou(g,iPixel) = minimalPou(ungappedIndices,iPixel);
            end
        end
    end
end

% compute mean delta from minimal pou on decimated cadences
delta = mean(uncertainties - minimalPou(usedCadenceIndex,:));

% add delta to all cadences
tempCell = num2cell(minimalPou + repmat(delta,size(minimalPou,1),1),1);

% write back to outputsStruct
[calOutputStruct.targetAndBackgroundPixels.uncertainties] = deal(tempCell{:});


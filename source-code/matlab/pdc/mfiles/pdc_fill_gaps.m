%***************************************************************************
%% function [targetDataStruct, gapFilledCadenceMidTimestamps] = pdc_fill_gaps(targetDataStruct, cadenceTimes)
%
% fills gaps using VERY simple pchip and linear interpolation. Gapped cadence times are filled using linear interpolation. Flux Values are filled using pchip.
%
% pchip does not work well for extrpolation so a linear fill is used is such cases.
%
% This function assumes that targetDataStruct.gapIndicators is a subset of
% cadenceTimes.gapIndicators. In other words, for every valid flux time there 
% should be a valid cadence time.
% 
% Inputs:
%       targetDataStruct-- [Struct array] array over N targets
%           fields: values        -- [float array] flux values for each cadence
%                   gapIndicators -- [logical array]
%       cadenceTimes     -- [Struct]
%           fields: midTimestamps --
%                   gapIndicators -- [int array]
%
% Outputs:
%       targetDataStruct -- {struct array]
%        .values    --  has gaps filled, gapIndicators is NOT changed
%       gapFilledCadenceMidTimestamps --- input cadenceTimes but with gaps linearly interpolated.
%
%%
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

function [targetDataStruct, gapFilledCadenceMidTimestamps] = pdc_fill_gaps(targetDataStruct, cadenceTimes)

gapFilledCadenceMidTimestamps  = pdc_fill_cadence_times (cadenceTimes);

nTargets = length(targetDataStruct);
for iTarget = 1 : nTargets

    targetGapIndicators = targetDataStruct(iTarget).gapIndicators;
        
    % Don't do anything for fully gapped targets
    if (all(targetGapIndicators))
        continue;
    end

    % Fill the flux gaps
    targetDataStruct(iTarget).values(targetGapIndicators) = ...
            interp1(cadenceTimes.midTimestamps(~targetGapIndicators), targetDataStruct(iTarget).values(~targetGapIndicators), ...
                                                gapFilledCadenceMidTimestamps(targetGapIndicators), 'pchip');

    % Check if we need to extrapolate flux value filling. If so, use a linear nearest-neighbor interpolator (pchip does not work well for extrapolation)
    if (targetGapIndicators(1))
        % find first non-gap
        firstNonGap = find(~targetGapIndicators,1 , 'first');
        targetDataStruct(iTarget).values(1:firstNonGap-1) = ...
                interp1(cadenceTimes.midTimestamps(~targetGapIndicators), targetDataStruct(iTarget).values(~targetGapIndicators), ...
                                                    gapFilledCadenceMidTimestamps(1:firstNonGap-1), 'nearest', 'extrap');
    end
    if(targetGapIndicators(end))
        % find last non-gap
        lastNonGap = find(~targetGapIndicators,1 , 'last');
        targetDataStruct(iTarget).values(lastNonGap+1:end) = ...
                interp1(cadenceTimes.midTimestamps(~targetGapIndicators), targetDataStruct(iTarget).values(~targetGapIndicators), ...
                                                    gapFilledCadenceMidTimestamps(lastNonGap+1:end), 'nearest', 'extrap');
    end

end

return % fill_gaps


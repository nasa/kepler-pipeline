function pdqInputStruct = pdqval_gap_modouts_and_cadences(pdqInputStruct, modouts, cadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% gapped = pdqval_gap_modouts_and_cadences(pdqInputStruct, modouts, cadences)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Insert gaps in all reference pixel time series for the designated 
% channels and cadences in a PDQ input structure. 
%
% Inputs:
%
%     pdqInputStruct
%
%     modouts        : an array of channel indices in the range [1-84]
%                      designating channels in which gaps are to be
%                      inserted. Indices of invalid channels are pruned.
%
%     cadences       : an array of cadence indices in the range
%                      [1-nCadences] designating cadences in which gaps are
%                      to be inserted. Out of bounds indices are pruned.
%
% Outputs:
%
%     gapped         : A copy of pdqInputStruct with gaps inserted.
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% Validate input arguments
[modules, outputs] = convert_to_module_output(unique(modouts));
nCadences = length(pdqInputStruct.pdqTimestampSeries.startTimes) ...
            - length(pdqInputStruct.inputPdqTsData.cadenceTimes);
validChannels = find(pdqval_get_valid_channels(pdqInputStruct));

if exist('modouts','var')
    modouts = intersect(modouts, validChannels); 
else
    modouts = validChannels;
end

if exist('cadences','var')
    cadences = unique(cadences); 
    cadences(find(cadences < 1)) = [];
    cadences(find(cadences > nCadences)) = [];
else
    cadences = [1:nCadences]';
end

% Insert gaps
targetFields = [ {'stellarPdqTargets'}; {'backgroundPdqTargets'}; {'collateralPdqTargets'}];
for i=1:numel(targetFields)
    targs = pdqInputStruct.(targetFields{i});
    nTargets = numel( targs );
    
    for j=1:nTargets
        modout = convert_from_module_output( targs(j).ccdModule, ...
                                             targs(j).ccdOutput );  
        if ismember(modout, modouts) 
            nPixels = numel( targs(j).referencePixels );
            for k=1:nPixels
                pdqInputStruct.(targetFields{i})(j).referencePixels(k).timeSeries(cadences) = -1;
                pdqInputStruct.(targetFields{i})(j).referencePixels(k).gapIndicators(cadences) = true;
            end
        end
    end
end

return

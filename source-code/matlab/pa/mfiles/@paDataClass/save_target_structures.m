function save_target_structures(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function save_target_structures(paDataObject, paResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Identify any PPA targets (for encircled energy and brightness metrics) in
% the current PA invocation, and append the respective PPA target star data
% and results structures to any that have already been saved in the PA
% state file. Also, append all target star results structures to those that
% have already been saved in the state file so that centroids are available
% on the last call for computation of the motion polynomials.
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


% Get state file name from input object.
paFileStruct = paDataObject.paFileStruct;
paStateFileName = paFileStruct.paStateFileName;

% Get fields from data and results structures.
targetStarDataStruct = paDataObject.targetStarDataStruct;
targetStarResultsStruct = paResultsStruct.targetStarResultsStruct;

encircledEnergyConfigurationStruct = ...
    paDataObject.encircledEnergyConfigurationStruct;
targetLabel = encircledEnergyConfigurationStruct.targetLabel;

% Load the state structures.
load(paStateFileName, 'ppaTargetStarDataStruct', ...
    'ppaTargetStarResultsStruct', 'paTargetStarResultsStruct');

% Append the latest target star results to the PA results structure.
paTargetStarResultsStruct = ...
    [paTargetStarResultsStruct, targetStarResultsStruct];                           %#ok<NODEF,NASGU>

% Identify the PPA targets, if any. Note that there may be multiple labels
% for any given target.
[isPpaTarget] = identify_targets(targetLabel, {targetStarDataStruct.labels});

% Save the data and results structures to the PA state file. Include any
% PPA targets.
if any(isPpaTarget)
    
    ppaTargetStarDataStruct = ...
        [ppaTargetStarDataStruct, targetStarDataStruct(isPpaTarget)];               %#ok<NODEF,NASGU>
    ppaTargetStarResultsStruct = ...
        [ppaTargetStarResultsStruct, targetStarResultsStruct(isPpaTarget)];         %#ok<NODEF,NASGU>
    
    save(paStateFileName, 'ppaTargetStarDataStruct', ...
        'ppaTargetStarResultsStruct', 'paTargetStarResultsStruct', '-append');

else % there are no PPA targets
    
    save(paStateFileName, 'paTargetStarResultsStruct', '-append');
    
end % if / else

% Return.
return

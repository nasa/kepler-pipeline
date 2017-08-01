function [calObject, calIntermediateStruct] = ...
    compute_collateral_smear_and_dark_transformations(calObject, calIntermediateStruct)
%function [calObject, calIntermediateStruct] = ...
%    compute_collateral_smear_and_dark_transformations(calObject, calIntermediateStruct)
%
% function to calculate transformations for smear and dark level
% operations used to propagate uncertainties
%
% Note (7/12/10)
%   This function is no longer used in production (Pipeline) code.
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

% extract timestamp (mjds)
cadenceTimes = calObject.cadenceTimes;
timestamp    = cadenceTimes.timestamp;
nCadences    = length(timestamp);

% extract flags for long or short cadence pixels
processLongCadence = calObject.processLongCadence;
processShortCadence = calObject.processShortCadence;

% get scale factor for long or short cadence pixels
if (processLongCadence)
    numberOfExposures = calIntermediateStruct.numberOfExposuresPerLongCadence;
elseif (processShortCadence)
    numberOfExposures = calIntermediateStruct.numberOfExposuresPerShortCadence;
end

% read out times and exposure times are given for all cadences here
ccdReadTime     = calIntermediateStruct.ccdReadTime;
ccdExposureTime = calIntermediateStruct.ccdExposureTime;

% correct only for cadences with valid pixels
missingMsmearCadences = calIntermediateStruct.missingMsmearCadences;
missingVsmearCadences = calIntermediateStruct.missingVsmearCadences;
missingCadences = union(missingMsmearCadences, missingVsmearCadences);

%--------------------------------------------------------------------------
% Compute uncertainty transforms (ccdReadTime and ccdExposureTime are time varying)
%--------------------------------------------------------------------------
for cadenceIndex = 1:nCadences

    if (isempty(missingCadences)) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))


        TrawMsmearTo2Dcorrected = sqrt(numberOfExposures(cadenceIndex));
        TrawVsmearTo2Dcorrected = sqrt(numberOfExposures(cadenceIndex));

        TcorrMsmearToEstSmear =  -(ccdReadTime(cadenceIndex)/ccdExposureTime(cadenceIndex));
        TcorrVsmearToEstSmear =  (1 + ccdReadTime(cadenceIndex)/ccdExposureTime(cadenceIndex));

        TmSmearCorrToDarkEst = -(1/ccdExposureTime(cadenceIndex));
        TvSmearCorrToDarkEst = (1/ccdExposureTime(cadenceIndex));

        % add to uncertainty struct
        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TrawMsmearTo2Dcorrected = TrawMsmearTo2Dcorrected;
        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TrawVsmearTo2Dcorrected = TrawVsmearTo2Dcorrected;

        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TcorrMsmearToEstSmear = TcorrMsmearToEstSmear;
        calIntermediateStruct.smearUncertaintyStruct(cadenceIndex).TcorrVsmearToEstSmear = TcorrVsmearToEstSmear;

        calIntermediateStruct.darkCurrentUncertaintyStruct(cadenceIndex).TmSmearCorrToDarkEst = TmSmearCorrToDarkEst;
        calIntermediateStruct.darkCurrentUncertaintyStruct(cadenceIndex).TvSmearCorrToDarkEst = TvSmearCorrToDarkEst;
    end
end

return;

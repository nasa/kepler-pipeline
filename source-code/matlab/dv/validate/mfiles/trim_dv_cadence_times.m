function [dvCadenceTimes] = ...
trim_dv_cadence_times(dvCadenceTimes, cadenceRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [dvCadenceTimes] = ...
% trim_dv_cadence_times(dvCadenceTimes, cadenceRange)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Trim a dvCadenceTimes structure to the specified cadence range. No
% rocket science here, but useful and called in multiple places.
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

% Do the trimming.
dvCadenceTimes.startTimestamps = ...
    dvCadenceTimes.startTimestamps(cadenceRange);
dvCadenceTimes.midTimestamps = ...
    dvCadenceTimes.midTimestamps(cadenceRange);
dvCadenceTimes.endTimestamps = ...
    dvCadenceTimes.endTimestamps(cadenceRange);
dvCadenceTimes.gapIndicators = ...
    dvCadenceTimes.gapIndicators(cadenceRange);
dvCadenceTimes.requantEnabled = ...
    dvCadenceTimes.requantEnabled(cadenceRange);
dvCadenceTimes.cadenceNumbers = ...
    dvCadenceTimes.cadenceNumbers(cadenceRange);
dvCadenceTimes.quarters = ...
    dvCadenceTimes.quarters(cadenceRange);
dvCadenceTimes.lcTargetTableIds = ...
    dvCadenceTimes.lcTargetTableIds(cadenceRange);
dvCadenceTimes.scTargetTableIds = ...
    dvCadenceTimes.scTargetTableIds(cadenceRange);

dvCadenceTimes.isSefiAcc = ...
    dvCadenceTimes.isSefiAcc(cadenceRange);
dvCadenceTimes.isSefiCad = ...
    dvCadenceTimes.isSefiCad(cadenceRange);
dvCadenceTimes.isLdeOos = ...
    dvCadenceTimes.isLdeOos(cadenceRange);
dvCadenceTimes.isFinePnt = ...
    dvCadenceTimes.isFinePnt(cadenceRange);
dvCadenceTimes.isMmntmDmp = ...
    dvCadenceTimes.isMmntmDmp(cadenceRange);
dvCadenceTimes.isLdeParEr = ...
    dvCadenceTimes.isLdeParEr(cadenceRange);
dvCadenceTimes.isScrcErr = ...
    dvCadenceTimes.isScrcErr(cadenceRange);

dvCadenceTimes.dataAnomalyFlags.attitudeTweakIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.attitudeTweakIndicators(cadenceRange);
dvCadenceTimes.dataAnomalyFlags.safeModeIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.safeModeIndicators(cadenceRange);
dvCadenceTimes.dataAnomalyFlags.earthPointIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.earthPointIndicators(cadenceRange);
dvCadenceTimes.dataAnomalyFlags.coarsePointIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.coarsePointIndicators(cadenceRange);
dvCadenceTimes.dataAnomalyFlags.argabrighteningIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.argabrighteningIndicators(cadenceRange);
dvCadenceTimes.dataAnomalyFlags.excludeIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.excludeIndicators(cadenceRange);
dvCadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators = ...
    dvCadenceTimes.dataAnomalyFlags.planetSearchExcludeIndicators(cadenceRange);

% Return.
return


function pointingObject = pointingClass(pointingData, interpolation_method)

% Define prime Kepler mission values so that legacy pointing models may be
% updated
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
PRIME_KEPLER_MISSION_END_MJD = 56444;

% Check usage
if nargin < 2
    pointingData.interpolation_method = 'spline';
else
    pointingData.interpolation_method = interpolation_method;
end

% Update legacy pointing models with prime Mission values but support
% prime mission pointings only
if ~isfield(pointingData, 'segmentStartMjds')
    
    isPrimeMission = pointingData.mjds <= PRIME_KEPLER_MISSION_END_MJD;
    
    if ~any(isPrimeMission)
        error('Matlab:FC:pointingClass', ...
            'Legacy pointing model includes no Kepler prime mission entries; legacy models are not supported for K2');
    end
    
    pointingData.mjds = pointingData.mjds(isPrimeMission);
    pointingData.ras = pointingData.ras(isPrimeMission);
    pointingData.declinations = pointingData.declinations(isPrimeMission);
    pointingData.rolls = pointingData.rolls(isPrimeMission);
    
    pointingData.segmentStartMjds = ...
        repmat(pointingData.mjds(1), size(pointingData.mjds));
    
end

% Data integrity check
fc_mjd_check(pointingData.mjds);
fc_nonimage_data_check(pointingData.ras);
fc_nonimage_data_check(pointingData.declinations);
fc_nonimage_data_check(pointingData.rolls);
fc_nonimage_data_check(pointingData.segmentStartMjds);

% Instantiate the object
pointingObject = class(pointingData, 'pointingClass');
    
return

function [transitModelLightCurve, cadenceTimes]  = ...
    generate_gaussian_model_light_curve(transitModelObject)
%
% function [transitModelLightCurve, cadenceTimes]  =
%    generate_gaussian_model_light_curve(transitModelObject)
%
% function to generate gaussian model light curve.
%
%
% INPUTS:
%
%   transitModelObject with the following fields:
%
%       cadenceTimes              [array] barycentric corrected MJDs
%       planetModel:              [struct] with the following fields:
%           transitEpochMjd       [scalar] time of first transit
%           transitDurationHours  [scalar] transit duration
%           transitDepthPpm       [scalar] transit depth
%           orbitalPeriodDays     [scalar] orbital period
%
%
% OUTPUTS:
%
%  transitModelLightCurve         [array] transit flux light curve relative
%                                 to unobscured flux light curve
%  cadenceTimes (optional)        [array] barycentric corrected MJDs (same
%                                 as input)
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

% Modification History:
%
%    2010-November-18, EQ:
%        this function can now be called via generate_planet_model_light_curve
%        which is a wrapper for all model light curve functions
%    2010-May-05, PT:
%        convert from transitEpochMjd to transitEpochBkjd.
%--------------------------------------------------------------------------

% extract fields from object
cadenceTimes          = transitModelObject.cadenceTimes;
planetModel           = transitModelObject.planetModel;

transitEpochMjd       = planetModel.transitEpochBkjd;
transitDurationHours  = planetModel.transitDurationHours;
transitDepthPpm       = planetModel.transitDepthPpm;
orbitalPeriodDays     = planetModel.orbitalPeriodDays;


hour2day            = get_unit_conversion('hour2day');
transitDurationDays = hour2day*transitDurationHours;
transitDepth        = transitDepthPpm/1e6;


% allocate memory for light curve
transitModelLightCurve = zeros(length(cadenceTimes), 1);

tCenterTransit = sort([(transitEpochMjd: -orbitalPeriodDays: cadenceTimes(1)-orbitalPeriodDays), ...
    (transitEpochMjd: orbitalPeriodDays: cadenceTimes(end))+orbitalPeriodDays ])';

nTransits = length(tCenterTransit);


%--------------------------------------------------------------------------
% generate gaussian transit pulses
%
% width = transit duration = 2 * 1_sigma
% depth = depth fraction = pulse height
%--------------------------------------------------------------------------
for n = 1:nTransits
    transitModelLightCurve = transitModelLightCurve - transitDepth .* (transitDurationDays/6) ...
        .* sqrt(2*pi) .* normpdf(cadenceTimes - tCenterTransit(n),0,transitDurationDays/6);
end


return;

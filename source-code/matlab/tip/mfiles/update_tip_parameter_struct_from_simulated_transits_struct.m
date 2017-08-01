function [tip] = update_tip_parameter_struct_from_simulated_transits_struct(tip, sim, varargin)
% function [tip] = update_tip_parameter_struct_from_simulated_transits_struct(tip, simulatedTransitsStruct, varargin)
%
% Place the values in the simulatedTransitsStruct (sim) if they are available into the corresponding fields in the TIP paramters struct
% (tip). This is useful if using the transitModelClass to provide derived parameters. The generating transit model parameters should remain
% unchanged. If a list of keplerIds is provided only these entries will be updated. Otherwise all keplerIds in tip with a match in sim will
% be updated. 
%
% 11/3/15 - Add support for multiple lines using the same keplerId
% It is assumed if there are multiple entries for the same keplerId in sim thee are the same number in tip. Furthermore, the
% order in which these multiple entries appear in the two input structs is identical.
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


% build list of keplerIds
if nargin > 2
    keplerIdList = varargin{1};
else
    keplerIdList = sim.keplerId;
end

% no duplicates in list
keplerIdList = unique(keplerIdList);

% which keplerIds on the input list do we have parameters for in tip
tf = ismember( keplerIdList, tip.keplerId );

if any(tf)
    
    % loop over the keplerIds found
    tfIdx = find(tf);
    for iTf = rowvec(tfIdx)
        
        % get indices into tip and sim lists
        idxTip = find(tip.keplerId == keplerIdList(iTf));
        idxSim = find(sim.keplerId == keplerIdList(iTf));
        
        % only perfrom updates if number of keplerId occurance in sim and tip lists are identical
        if ~isempty(idxTip) && ~isempty(idxSim) && length(idxTip) == length(idxSim)
            
            for iIdx = 1:length(idxTip)
                
                a = idxTip(iIdx);
                b = idxSim(iIdx);
                
                % first level of simulatedTransitsStruct
                tip.transitOffsetEnabled(a)    = sim.offsetEnabled(b);
                tip.transitOffsetArcsec(a)     = sim.offsetArcSec(b);
                tip.transitOffsetPhase(a)      = sim.offsetPhase(b);
                tip.transitSeparationDays(a)   = sim.transitSeparation(b);
                tip.transitOffsetDepthPpm(a)   = sim.offsetTransitDepth(b) .* 1e6;
                
                % second level of simulatedTransitsStruct
                tip.stellarLog10Gravity(a)         = sim.transitModelStructArray(b).log10SurfaceGravity.value;
                tip.stellarEffectiveTempKelvin(a)  = sim.transitModelStructArray(b).effectiveTemp.value;
                tip.stellarLog10Metalicity(a)      = sim.transitModelStructArray(b).log10Metallicity.value;
                tip.stellarRadiusRsun(a)           = sim.transitModelStructArray(b).radius.value;
                tip.transitBufferCadences(a)       = sim.transitModelStructArray(b).transitBufferCadences;
                
                % third level of simulatedTransitsStruct - planetModel which may or may not include derived parameters
                % check if fields are present and not empty in planetModel before writing contents
                if isfield(sim.transitModelStructArray(b).planetModel,'transitEpochBkjd') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.transitEpochBkjd)
                    tip.epochBjd(a) = sim.transitModelStructArray(b).planetModel.transitEpochBkjd;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'eccentricity') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.eccentricity)
                    tip.eccentricity(a) = sim.transitModelStructArray(b).planetModel.eccentricity;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'longitudeOfPeriDegrees') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.longitudeOfPeriDegrees)
                    tip.longitudeOfPeriDegrees(a) = sim.transitModelStructArray(b).planetModel.longitudeOfPeriDegrees;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'minImpactParameter') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.minImpactParameter)
                    tip.impactParameter(a) = sim.transitModelStructArray(b).planetModel.minImpactParameter;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'orbitalPeriodDays') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.orbitalPeriodDays)
                    tip.orbitalPeriodDays(a) = sim.transitModelStructArray(b).planetModel.orbitalPeriodDays;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'starRadiusSolarRadii') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.starRadiusSolarRadii)
                    tip.stellarRadiusRsun(a) = sim.transitModelStructArray(b).planetModel.starRadiusSolarRadii;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'ratioPlanetRadiusToStarRadius') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.ratioPlanetRadiusToStarRadius)
                    tip.RplanetOverRstar(a) = sim.transitModelStructArray(b).planetModel.ratioPlanetRadiusToStarRadius;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'ratioSemiMajorAxisToStarRadius') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.ratioSemiMajorAxisToStarRadius)
                    tip.semiMajorAxisOverRstar(a) = sim.transitModelStructArray(b).planetModel.ratioSemiMajorAxisToStarRadius;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'transitDepthPpm') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.transitDepthPpm)
                    tip.transitDepthPpm(a) = sim.transitModelStructArray(b).planetModel.transitDepthPpm;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'transitDurationHours') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.transitDurationHours)
                    tip.transitDurationHours(a) = sim.transitModelStructArray(b).planetModel.transitDurationHours;
                end
                if isfield(sim.transitModelStructArray(b).planetModel,'planetRadiusEarthRadii') && ...
                        ~isempty(sim.transitModelStructArray(b).planetModel.planetRadiusEarthRadii)
                    tip.planetRadiusREarth(a) = sim.transitModelStructArray(b).planetModel.planetRadiusEarthRadii;
                end
            end
        end        
    end
end    


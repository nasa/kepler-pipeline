function [planetModel] = seed_planet_model_with_reduced_parameter_fits( dvDataObject, dvResultsStruct, iTarget, iPlanet, planetModel )
% function [dvResultsStruct, planetModel] = seed_planet_model_with_reduced_parameter_fits( dvDataObject, dvResultsStruct, iTarget, iPlanet, planetModel )
%
% This function seeds the planet model with the valid reduced parameter fit (modelChiSquare>0) with the minimum modelChiSquare.
%
% Version date:  2012-July-02.
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

% Modification History:
%   2012-July-02, JL:
%       Initial release.
%
%=========================================================================================

% Determine valid reduced parameter fits 

reducedParameterFits      = dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).reducedParameterFits;
modelChiSquareArray       = [reducedParameterFits.modelChiSquare];
validReducedParameterFits = reducedParameterFits(modelChiSquareArray>0);
validChiSquareArray       = modelChiSquareArray(modelChiSquareArray>0);

if  dvDataObject.planetFitConfigurationStruct.reducedParameterFitsEnabled && ~isempty(validChiSquareArray)
    
    % Seed the planet model with the reduced parameter fit with the minimum modelChiSquare
    
    [ignored, minIndex]   = min(validChiSquareArray);
    modelParameters       = validReducedParameterFits(minIndex).modelParameters;
    modelParameterNames   = {modelParameters.name};
  
    planetModel.transitEpochBkjd                  = modelParameters(strcmp('transitEpochBkjd',               modelParameterNames)).value;
    planetModel.orbitalPeriodDays                 = modelParameters(strcmp('orbitalPeriodDays',              modelParameterNames)).value;
    planetModel.ratioPlanetRadiusToStarRadius     = modelParameters(strcmp('ratioPlanetRadiusToStarRadius',  modelParameterNames)).value;
    planetModel.ratioSemiMajorAxisToStarRadius    = modelParameters(strcmp('ratioSemiMajorAxisToStarRadius', modelParameterNames)).value;
    planetModel.minImpactParameter                = modelParameters(strcmp('minImpactParameter',             modelParameterNames)).value;
    planetModel.eccentricity                      = modelParameters(strcmp('eccentricity',                   modelParameterNames)).value;
    planetModel.longitudeOfPeriDegrees            = modelParameters(strcmp('longitudeOfPeriDegrees',         modelParameterNames)).value;
    planetModel.starRadiusSolarRadii              = modelParameters(strcmp('starRadiusSolarRadii',           modelParameterNames)).value;
    
    disp(' ');
    disp(['  Seed planet model with reduced parameter fit with fixed impact parameter ' num2str(planetModel.minImpactParameter, '%1.2f')]);
    disp(' ');
    
end
  
return


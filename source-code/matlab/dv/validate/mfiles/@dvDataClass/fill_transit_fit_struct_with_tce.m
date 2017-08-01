function dvResultsStruct = fill_transit_fit_struct_with_tce( dvDataObject, dvResultsStruct, iTarget, iPlanet, thresholdCrossingEvent, impactParameterSeed )
%
% fill_planet_results_struct_with_tce -- fills in the allTransitsFit struct of the planetResultsStruct 
% with thresholdCrossingEvent data when allTransitsFit fails.
%
% Version date:  2012-October-29.
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
%
%   2012-October-29, JL:
%       Do not fill modelLightCurve struct with TCE data
%   2012-August-23, JL:
%       Move calculation of inclination angle and equilibrium temperature 
%       to transitGeneratorClass
%   2012-July-03, JL;
%       Add input 'impactParameterSeed'
%   2012-May-16, JL:
%       Add computation of equilibrium temperature.   
%   2012-Februray-08, JL:
%       Initial release.
%
%=========================================================================================
   
    % get default value of impactParameterSeed
  
    if ~exist( 'impactParameterSeed', 'var' ) || isempty(impactParameterSeed)

        impactParameterSeed = dvDataObject.planetFitConfigurationStruct.impactParameterSeed;
     
    end
    
    % convert the TCE from TPS to the transit model
    
    [transitModel] = convert_tps_parameters_to_transit_model( dvDataObject, iTarget, thresholdCrossingEvent, ...
        dvResultsStruct.targetResultsStruct(iTarget).residualFluxTimeSeries, impactParameterSeed );

    % get the updated transitGeneratorObject 
    
    oddEvenFlag             = 0;
    transitObject           = transitGeneratorCollectionClass( transitModel, oddEvenFlag );
    transitGeneratorObject  = get( transitObject, 'transitGeneratorObjectVector' );
  
    % get the planet model and its field names list from the transit generator object

    planetModel             = get( transitGeneratorObject, 'planetModel' ) ;
    planetModelFieldNames   = fieldnames( planetModel ) ;
    nPlanetModelFields      = length(planetModelFieldNames) ;
  
    % Adjust planetModel.transitEpochBkjd so that it is larger than (or equal to) the first start timestamp of barycentric cadence times

    epochOffsetPeriods = 0;
    transitEpochBkjd   = planetModel.transitEpochBkjd;
    orbitalPeriodDays  = planetModel.orbitalPeriodDays;
    while (transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays) < dvDataObject.barycentricCadenceTimes(iTarget).startTimestamps(1)
        epochOffsetPeriods = epochOffsetPeriods + 1;
    end
    planetModel.transitEpochBkjd = transitEpochBkjd + epochOffsetPeriods*orbitalPeriodDays;

    % construct the modelParameters structure 

    modelParameters = struct('name', [], 'value', [], 'uncertainty', -1, 'fitted', false) ;
    modelParameters = repmat( modelParameters, nPlanetModelFields, 1 ) ;
  
    % put the fit parameters into the modelParameters structure

    for iPar = 1:nPlanetModelFields

        modelParameters(iPar).name = planetModelFieldNames{iPar};

        if ( isfinite( planetModel.(planetModelFieldNames{iPar}) ) && isreal( planetModel.(planetModelFieldNames{iPar}) ) )
              
            modelParameters(iPar).value = planetModel.(planetModelFieldNames{iPar});
              
        else
              
            errorIdentifier = ['dv:fill_planet_results_struct:' planetModelFieldNames{iPar} '_notReal'];
            errorMessage    = ['model parameter ' planetModelFieldNames{iPar} ' is not a finite real number'];
            error(errorIdentifier, errorMessage);
              
        end
          
    end      
  
    % update the output
    
    dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct(iPlanet).allTransitsFit.modelParameters = modelParameters';

return



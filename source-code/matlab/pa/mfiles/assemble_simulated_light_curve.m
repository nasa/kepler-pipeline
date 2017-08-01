function modelLightCurve = assemble_simulated_light_curve(transitModelStruct, transitSeparation, widthToModelDays)
%
% function modelLightCurve = assemble_simulated_light_curve(transitModelStruct, transitSeparation, widthToModelDays)
%
% This PA function builds the simulated transits light curve by taking a single transit as defined in transitModelStruct
% and repeating that transit not at the period specified in transitModelStruct but at the period defined by transitSeparation.
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


% default is to use transitSeparation as the simulated period
periodCompressionEnabled = true;

% extract parameters which define transit model
t = transitModelStruct.cadenceTimes;
planetModel = transitModelStruct.planetModel;
epoch = planetModel.transitEpochBkjd;

% allocate space for final light curve
modelLightCurve = zeros(size(t));

% Build vector of epochs within UOW separated by transitSeparation
if transitSeparation == 0
    % transitSeparation = 0 means no artificial period compression will be used
    transitSeparation = planetModel.orbitalPeriodDays;
    periodCompressionEnabled = false;
end
simulatedEpochs = unique([ epoch: -transitSeparation: (t(1)-widthToModelDays), epoch: transitSeparation: (t(end)+widthToModelDays) ] );
simulatedEpochs = simulatedEpochs( simulatedEpochs >= (t(1)-widthToModelDays) & simulatedEpochs <= (t(end)+widthToModelDays) );


% loop over the simulatedEpochs building a single transit model on each iteration and aggregate result
for epoch = rowvec(simulatedEpochs)
    
    if periodCompressionEnabled
        % adjust UOW in transitModelStruct to include only the transit around this epoch
        transitIndicator = abs( t - epoch ) <= widthToModelDays;
    else
        % use full UOW in transitModelStruct so light curve is generated in one call to generate_planet_model_light_curve
        transitIndicator = true(size(t));
    end
    
    % get light curve if there are any cadences available for this transit
    if any( transitIndicator )
        
        % build or alter transit model object
        if ~exist('transitModelObject','var')
            
            % adjust planetModel and cadence times in model struct
            planetModel.transitEpochBkjd = epoch; 
            transitModelStruct.cadenceTimes = t(transitIndicator);
            transitModelStruct.planetModel = planetModel; 
            
            % build new object
            transitModelObject = transitGeneratorClass(transitModelStruct);
            
            % read out instantiated planet model (w/class updates)
            planetModel = get(transitModelObject,'planetModel');
        else            
            % adjust epoch in planet model
            planetModel.transitEpochBkjd = epoch;
            
            % set new cadence times and planets model in object - also zero out light curve in object
            transitModelObject = set(transitModelObject, 'cadenceTimes', t(transitIndicator));
            transitModelObject = set(transitModelObject, 'transitModelLightCurve', zeros(size(t(transitIndicator))));
            transitModelObject = set(transitModelObject, 'planetModel', planetModel);
        end

        % get light curve for just these timestamps and place in output vector
        modelLightCurve(transitIndicator)  = generate_planet_model_light_curve(transitModelObject);
        
        
        if ~periodCompressionEnabled
            % only operate on first simulated epoch in UOW if not artificially compressing the period
            break;
        end        
    end    
end

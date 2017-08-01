function fit_amplitudes_and_positions_to_observations(obj)
%**************************************************************************
% function fit_amplitudes_and_positions_to_observations(obj)
%**************************************************************************
% Fit the aperture model to the observed pixels on each cadence.
% 
% INPUTS
%     (none)
%
% OUTPUTS
%     Updates the nCadences-by(nStars+1) 'coefficients' matrix as well as
%     the raDegrees and decDegrees fields of each structure in
%     obj.contributingStars whose lockRaDec flag is set to 'false'. Note
%     that coefs(c, end)contains the background flux coefficient for
%     cadence 'c'.
%
%**************************************************************************
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
    degreesPerPixel = apertureModelClass.DEGREES_PER_PIXEL;

    % Don't allow the star to drift farther than this many pixels from its
    % catalog position.
    hardLimitInPixels = obj.configStruct.raDecMaxDeltaPixels;
        
    %----------------------------------------------------------------------                
    % Define initial values and constraints on sources whose positions are
    % not locked. Initialize the RA and Dec of each unlocked star to the
    % catalog values and add it to a vector of unlocked (ra, dec) pairs in
    % the following format: 
    %
    % [ ra(  unlockedIndices(1) ); ...
    %   dec( unlockedIndices(1) ); ...
    %   ra(  unlockedIndices(2) ); ...
    %   dec( unlockedIndices(2) ); ...
    %                        :  
    %   ra(  unlockedIndices(N) ); ...
    %   dec( unlockedIndices(N) )]
    %
    % Where N is the number of unlocked stars in the model.
    %----------------------------------------------------------------------       
    unlockedIndices = find(~[obj.contributingStars(:).lockRaDec]);
    catalogPositions = [ ...
        rowvec([obj.contributingStars(unlockedIndices).catalogRaDegrees]) ; ...
        rowvec([obj.contributingStars(unlockedIndices).catalogDecDegrees]) ...
        ];
    catalogPositions = catalogPositions(:);

    % Set a hard limit on the allowed change in sky position.
    highBounds = catalogPositions + hardLimitInPixels * degreesPerPixel; 
    lowBounds  = catalogPositions - hardLimitInPixels * degreesPerPixel;

    
    %----------------------------------------------------------------------                
    % Perform the minimization.
    %----------------------------------------------------------------------   
    options = optimset( ...
        'MaxIter', obj.configStruct.raDecMaxIter, ...
        'Display', 'iter', ...
        'FunValCheck', 'on',...
        'TolFun', obj.configStruct.raDecTolFun, ...    % Stop if the function value changes by less than this amount.
        'TolX',   obj.configStruct.raDecTolX ...       % Stop if the param vector moves by less than this amount.
    );
        
    switch obj.configStruct.raDecFitMethod
        case 'lsqnonlin'
            objectiveFunc = @(x)compute_weighted_residual(x, obj);
            fitPositions  = lsqnonlin(objectiveFunc, catalogPositions, ...
                lowBounds, highBounds, options);
            
        case 'nlinfit'
            % Note that the SOC version of nlinfit() - kepler_nonlinear_fit_soc() - was
            % hanging up during trials. Therefore it is not used here.
            
            % Here we pass a dummy array to the objective function so that
            % it conforms to nlinfit's expectations.
            objectiveFunc = @(x, dummy) compute_weighted_residual(x, obj); 

            % Determine the length of the vector returned by the objective
            % function. This is the total number of non-gapped observations
            % across all pixels and cadences.
            nObservations = length(objectiveFunc(catalogPositions));
            
            % Since f() returns weighted residuals, we want them to be as
            % close to zero as possible. Therefore a vector of zeros is
            % passed as the "observed" data.
            desiredResiduals = zeros(nObservations, 1);
            fitPositions = nlinfit([], desiredResiduals, objectiveFunc, ...
                catalogPositions, options);
  
        otherwise
            error('Invalid fitting method specified: %s', ...
                    obj.configStruct.raDecFitMethod);
    end
    
    
    %----------------------------------------------------------------------
    % Update unlocked source positions.
    %----------------------------------------------------------------------    
    for iUpdate = 1:length(unlockedIndices)
        starIndex = unlockedIndices(iUpdate);
        
        raIndex  = 2*iUpdate - 1;
        decIndex = 2*iUpdate;
        
        obj.contributingStars(starIndex).raDegrees  = fitPositions(raIndex);
        obj.contributingStars(starIndex).decDegrees = fitPositions(decIndex);
    end
    

    %----------------------------------------------------------------------
    % Do a final fit of the model amplitudes.
    %----------------------------------------------------------------------    
    apertureModelObject.basisOutOfDate     = true;         
    apertureModelObject.centroidsOutOfDate = true;
    obj.fit_amplitudes_to_observations();
end

%**************************************************************************
% Compute the weighted chi-square residuals of the aperture model and the
% observed pixels, given a hypothetical configuration of stars. The weight
% applied to the residuals is determined from the hypothetical
% configuration and its relationship to the catalog star positions.
%
% INPUTS
%     unlockedRaDec       : A vector of (ra, dec) pairs in the following
%                           format: 
% 
%                           [ ra(  unlockedIndices(1) ); ...
%                             dec( unlockedIndices(1) ); ...
%                             ra(  unlockedIndices(2) ); ...
%                             dec( unlockedIndices(2) ); ...
%                                                  :  
%                             ra(  unlockedIndices(N) ); ...
%                             dec( unlockedIndices(N) )]
%
%                           Where N is the number of UNLOCKED stars in the
%                           model. 
%
%     apertureModelObject : An apertureModelClass object.
%
% OUTPUTS
%     weightedResiduals   : An (nPixels*nCadences)-by-1 vector of weighted
%                           chi-square residuals for all non-gapped pixels
%                           and cadences:  
%
%                           R(i) = w*((observed(i)-modeled(i))/sigma(i))^2
%
%                           where i indexes a non-gapped measurement.
%**************************************************************************
function weightedResiduals = ...
    compute_weighted_residual(unlockedRaDec, apertureModelObject)
    
    unlockedIndices = ...
        find(~[apertureModelObject.contributingStars(:).lockRaDec]);
       
    % Insert the hypothetical star positions.
    for iUpdate = 1:length(unlockedIndices)
        starIndex = unlockedIndices(iUpdate);
        
        raIndex  = 2*iUpdate - 1;
        decIndex = 2*iUpdate;
        
        apertureModelObject.contributingStars(starIndex).raDegrees = ...
            unlockedRaDec(raIndex);
        apertureModelObject.contributingStars(starIndex).decDegrees = ...
            unlockedRaDec(decIndex);
    end
    
    apertureModelObject.basisOutOfDate      = true;         
    apertureModelObject.centroidsOutOfDate  = true;

    % Update basis vectors, and fit amplitudes at each cadence.
    apertureModelObject.fit_amplitudes_to_observations();
        
    % Evaluate the aperture model for all (modeled) cadences.
    modelValues = apertureModelObject.evaluate();
    
    % Get observed pixel values and uncertainties for all (modeled)
    % cadences.     
    [observedValues, sigmas, gaps] = ...
        apertureModelObject.get_observed_values_and_sigmas();
        
    % Compute the weight of the hypothetical configuration.
    starArray = apertureModelObject.contributingStars;
    ra  = [starArray(:).raDegrees];
    dec = [starArray(:).decDegrees];
    catalogRa  = [starArray(:).catalogRaDegrees];
    catalogDec = [starArray(:).catalogDecDegrees];
    restoringCoef = apertureModelObject.configStruct.raDecRestoringCoef;
    repulsiveCoef = apertureModelObject.configStruct.raDecRepulsiveCoef;
    
    w = apertureModelClass.compute_source_configuration_energy(ra, dec, ...
        catalogRa, catalogDec, restoringCoef, repulsiveCoef);
    
    % If using nlinfit, we cannot directly constrain the solution. We
    % therefore do the following to limit the movement of stars to be
    % (approximately) less than raDecMaxDeltaPixels from their catalog
    % positions. 
    if strcmpi(apertureModelObject.configStruct.raDecFitMethod, 'nlinfit')
        absDistDegrees = apertureModelClass.angular_separation_degrees( ...
            [ra(:), dec(:)], [catalogRa(:), catalogDec(:)]);
        absDistPixels = absDistDegrees ./ apertureModelClass.DEGREES_PER_PIXEL;
        
        maxDelta = apertureModelObject.configStruct.raDecMaxDeltaPixels;
        tw       = apertureModelClass.SIGMOID_TRANSITION_WIDTH_PIXELS;
        a        = apertureModelClass.SIGMOID_TRANSITION_VALUE;
        b        = -log( (1-a)/a );
        sigmoid  = 1.0 / (1.0 + exp(-(2*b/tw)*(max(absDistPixels) - maxDelta)) );
        
        % Since sigmoid is in the range [0,1], the following expression
        % returns a value in the range [w,MAX_CONFIGURATION_WEIGHT]:
        w = w + sigmoid * (apertureModelClass.MAX_CONFIGURATION_WEIGHT - w);               
    end
    
    % Calculate the weighted residual values.
    weightedResiduals = ...
        colvec( (w + 1) * ((observedValues(~gaps) - modelValues(~gaps)) ./ sigmas(~gaps)) .^2 );  
        
    % Restore the catalog star positions.
    for iUpdate = 1:length(unlockedIndices)
        starIndex = unlockedIndices(iUpdate);        
        apertureModelObject.contributingStars(starIndex).raDegrees  = ...
            apertureModelObject.contributingStars(starIndex).catalogRaDegrees;
        apertureModelObject.contributingStars(starIndex).decDegrees = ...
            apertureModelObject.contributingStars(starIndex).catalogDecDegrees;
    end

    % Set the out-of-date flags.
    apertureModelObject.basisOutOfDate      = true;         
    apertureModelObject.centroidsOutOfDate  = true;
end

% %**************************************************************************
% % Compute the absolute angular distance in degrees between corresponding
% % points in the two sets of arrays. 
% %
% % INPUTS
% %     raDegrees1  : An N-length array of right ascensions.
% %     decDegrees1 : An N-length array of declinations.
% %     raDegrees2  : An N-length array of right ascensions.
% %     decDegrees2 : An N-length array of declinations.
% %
% % OUTPUTS
% %     absDistDegrees : An N-length array of absolute angular distances
% %                      (degrees) between corresponding points in the first
% %                      and second input arrays.
% %
% %**************************************************************************
% function absDistDegrees = angular_distance_degrees(raDegrees1, decDegrees1, ...
%                                             raDegrees2, decDegrees2)
%     degrees2Rads   = pi/180;
%     
%     raRads1  = degrees2Rads * raDegrees1;
%     raRads2  = degrees2Rads * raDegrees2;
%     decRads1 = degrees2Rads * decDegrees1;
%     decRads2 = degrees2Rads * decDegrees2;
%     
%     arclength = acos( cos(pi/2 - decRads1) .* cos(pi/2 - decRads2) + ...
%         sin(pi/2 - decRads1) .* sin(pi/2 - decRads2) .* ...
%         cos(raRads1 - raRads2) );
%     
%     absDistDegrees = abs(arclength / degrees2Rads);
% end

%********************************** EOF ***********************************


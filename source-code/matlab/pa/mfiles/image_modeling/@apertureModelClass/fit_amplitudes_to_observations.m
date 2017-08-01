function fit_amplitudes_to_observations(obj)
%**************************************************************************
% function fit_amplitudes_to_observations(obj)
%**************************************************************************
% Fit the aperture model to the observed pixels on each cadence.
% 
% The model of pixel p at cadence c is given by
% 
%      V
%     SUM( coefficients(c,v) * basisVectors(p,v,c))
%     v=1
% 
% where v = 1, 2, ..., V indexes each basis vector. There is one basis
% vector for each star contributing flux to the aperture and one
% to represent a constant offest.  
% 
% INPUTS
%     (none)
%
% OUTPUTS
%     Updates the nCadences-by(nStars+1) 'coefficients' matrix. Note that
%     coefs(c, end)contains the background flux coefficient for cadence
%     'c'. 
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
    
    nCadences     = obj.get_num_cadences();
    nBasisVectors = obj.get_num_contributing_stars() + 1; 
        
    %--------------------------------------------------------------
    % Update the basis, if necessary.
    %--------------------------------------------------------------
    obj.update_basis();
    
                                              
    %--------------------------------------------------------------
    % Construct gap indicator arrays.
    %--------------------------------------------------------------   
    motionGapIndicators = obj.get_motion_gap_indicators();
    
    
    %--------------------------------------------------------------                
    % Extract the observed pixel values and uncertainties.
    %--------------------------------------------------------------   
    [pixelValueMat, pixelSigmaMat, pixelGapMat] = ...
        obj.get_observed_values_and_sigmas();
        
    
    %--------------------------------------------------------------
    % Fit model at each valid cadence.
    %--------------------------------------------------------------    
    for iCadence = 1:nCadences
                
        validPixels = ~pixelGapMat(:, iCadence);
        
        % If cadence is not gapped and motion polys are available ...
        if ~motionGapIndicators(iCadence) && any(validPixels)
                             
            % Obtain an nPixels-by-(nStars+1) matrix of basis vectors in
            % which each row is scaled by the uncertainty of the
            % corresponding observed pixel.
            scaledBasis = obj.basisVectors(validPixels, :, iCadence) ./ ...
                repmat(colvec(pixelSigmaMat(validPixels, iCadence)), [1,nBasisVectors]);

            % Exclude basis vectors that either contain non-finite values 
            % or are zero everywhere.
            validBvIndicators = ...
                ~( any(~isfinite(scaledBasis), 1) | all(scaledBasis == 0, 1) );                                                    
            
            % Fit the scaled basis to the observed data (also scaled by
            % uncertainty). 
            scaledObservations = ...
                colvec( pixelValueMat(validPixels, iCadence) ./ ...
                        pixelSigmaMat(validPixels, iCadence));
                    
            switch obj.configStruct.amplitudeFitMethod 
                case 'bbnnls'
                    % function out = bbnnls(A, b, x0, opt)
                    % Solve a bound-constrained least squares problem, 
                    %    min    0.5*||Ax-b||^2, s.t. x >= 0
                    % A is nPixels-by-nValidBVs, b is nPixels-by-1, and x is
                    % nValidBVs-by-1.
                    opt=solopt;
                    x0 = 0.01*ones(nnz(validBvIndicators), 1);

                    % Fit with a positive constant term.
                    A = scaledBasis(:, validBvIndicators);
                    bbnnlsOutputStruct = bbnnls(A, scaledObservations, x0, opt); 
                    coefsWithPositiveConstTerm = bbnnlsOutputStruct.x; 
                    resNormPos = norm(scaledObservations - A*coefsWithPositiveConstTerm)^2;

                    % Fit again with a negative constant term.
                    A(:,end) = -A(:,end);
                    bbnnlsOutputStruct = bbnnls(A, scaledObservations, x0, opt); 
                    coefsWithNegativeConstTerm = bbnnlsOutputStruct.x; 
                    resNormNeg = norm(scaledObservations - A*coefsWithNegativeConstTerm)^2;

                    % Choose the best model. 
                    if resNormPos <= resNormNeg
                        bestCoefs = coefsWithPositiveConstTerm;
                    else
                        % Since the constant term in our final model will be a
                        % positive vector, we need to negate the coefficient.
                        bestCoefs = coefsWithNegativeConstTerm;
                        bestCoefs(end) = - bestCoefs(end);
                    end
                    obj.coefficients(iCadence, validBvIndicators) = bestCoefs;
               
                case 'lsqnonneg'
                
                    % Fit with a positive constant term.
                    A = scaledBasis(:, validBvIndicators);
                    [coefsWithPositiveConstTerm, resNormPos] = ...
                        lsqnonneg( A, scaledObservations);

                    % Fit again with a negative constant term.
                    A(:,end) = -A(:,end);
                    [coefsWithNegativeConstTerm, resNormNeg] = ...
                        lsqnonneg( A, scaledObservations);

                    % Choose the best model. 
                    if resNormPos <= resNormNeg
                        bestCoefs = coefsWithPositiveConstTerm;
                    else
                        % Since the constant term in our final model will
                        % be a positive vector, we need to negate the
                        % coefficient.
                        bestCoefs = coefsWithNegativeConstTerm;
                        bestCoefs(end) = - bestCoefs(end);
                    end
                    obj.coefficients(iCadence, validBvIndicators) = bestCoefs;
                
                case 'unconstrained'
                    % Unconstrained fit.
                    warning(['Optimization toolbox license unavailable. ' ...
                        'Using an unconstrained fit in place of lsqnonneg().\n']);
                    obj.coefficients(iCadence, validBvIndicators) = ...
                        scaledBasis(:, validBvIndicators) \ scaledObservations;
                otherwise
                    error('Invalid fitting method specified: %s', ...
                            obj.configStruct.amplitudeFitMethod);
            end

        end
        
    end
        
end


% The following code is an alternate method that is slightly more awkward,
% but likely to be about two times faster than the two-fit method used
% above: 
%--------------------------------------------------------------
%     % Disable warnings.
%     fprintf( ['Disabling warnigns since we are intentionally ', ...
%               'passing a rank deficient matrix to lsqnonneg().\n', ...
%               'Warning state will be resored afterward.\n']);
%     warningState = warning('querey', 'all');
%     warning off all


%                 % Do constrained LS fit, requiring non-negative
%                 % coefficients on the PRF terms. We do some contortions
%                 % here to allow the constant offset term to be positive or
%                 % negative. Specifically, we add a negated copy of the
%                 % (scaled) constant basis vector to the design matrix. The
%                 % constand coefficient for the model is then the difference
%                 % of the contributions of positive and negative terms
%                 % (remember all coeffs are positive when using lsqnonneg).
%                 %
%                 % In doing this, we are adding a basis vector that is a
%                 % multiple of another basis vector and introducing a rank
%                 % deficiency. Since we're only interested in the *sum* of
%                 % these two dependent vectors, this should be ok and
%                 % warnings can be ignored.
%                 
%                 
%                 m = scaledBasis(:, validBvIndicators);
%                 m = [m, -m(:,end)];
%                 coefs = lsqnonneg( m, scaledObservations);
%                 constCoefPos = coefs(end-1);
%                 constCoefNeg = coefs(end);
%                 constCoef = constCoefPos - constCoefNeg;
%                 obj.coefficients(iCadence, validBvIndicators) = ...
%                     [coefs(1:end-2); constCoef];


%     % Restore the original warning state.
%     warning(warningState);

function [correctedPixels, uncertaintyStruct, calIntermediateStruct, calTransformStruct] = ...
    correct_for_nonlinearity(pixelArrayToCorrect, polyStruct, ...
    numberOfExposures, nCadences, missingCadences, calIntermediateStruct, calTransformStruct, variableName, pouEnabled)
% function [correctedPixels, uncertaintyStruct, calIntermediateStruct, calTransformStruct] = ...
%     correct_for_nonlinearity(pixelArrayToCorrect, polyStruct, ...
%     numberOfExposures, nCadences, missingCadences, calIntermediateStruct, calTransformStruct, variableName, pouEnabled)
%
% This function corrects pixels for nonlinearity
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


uncertaintyStruct = repmat(struct('linearityPolyfitParameters', [], ...   % polyStruct with polyfit inputs
    'linearityCorrection', [], ...                                        % array same size as pixels
    'linearityPolyfitParametersPrime', [], ...                            % polyDerStruct with polyder inputs
    'derivLinearityCorrection', [], ...                                   % array same size as pixels
    'TBlkCorrToNonlinCorr', []), nCadences, 1);                           % array same size as pixels

correctedPixels = zeros(size(pixelArrayToCorrect));

tic
for cadenceIndex = 1:nCadences

    if numel(numberOfExposures) > 1
        numberOfExposures = numberOfExposures(cadenceIndex);
    end


    % correct for linearity only for cadences with valid pixels
    if isempty(missingCadences) || (~isempty(missingCadences) && ~any(ismember(missingCadences, cadenceIndex)))

        if pouEnabled
            % copy calTransformStruct into shorter temporary structure
            tStruct = calTransformStruct(:,cadenceIndex);
        end

        pixelsToCorrect = pixelArrayToCorrect(:, cadenceIndex);

        % linearity model is valid for a single read DN value; scale for
        % number of long or short cadence coadds
        pixelsToCorrect = pixelsToCorrect ./ numberOfExposures;

        %------------------------------------------------------------------
        % evaluate polynomial for nonlinearity correction using weighted_polyval
        % uncertainties in polynomial coeffts are neglected in error propagation
        %------------------------------------------------------------------
        %  output struct from FC used as input to weighted polyval
        % polyStruct.coeffs = linearityPolyCoeffts(:);
        % polyStruct.covariance = ClinearityFit;
        % polyStruct.order = 5;
        % polyStruct.maxDomain = maxDomain;
        % polyStruct.xIndex = xIndex;
        % polyStruct.type = type;
        % polyStruct.offsetx = offsetx;
        % polyStruct.scalex = scalex;
        % polyStruct.originx = originx;

        [linearityCorrection] = weighted_polyval(pixelsToCorrect', polyStruct(cadenceIndex));

        % save polynomial fit parameters and corrections to tmp struct
        uncertaintyStruct(cadenceIndex).linearityPolyfitParameters = polyStruct(cadenceIndex);
        uncertaintyStruct(cadenceIndex).linearityCorrection = linearityCorrection;

        % coefficients from weighted_polyval are in opposite order needed for polyder
        linearityPolyDerCoeffts = flipud(polyder(flipud(polyStruct(cadenceIndex).coeffs))')*polyStruct(cadenceIndex).scalex;

        % re-define struct for weighted_polyval for derivative
        polyderStruct = polyStruct(cadenceIndex);

        % use coeffts for poly derivative, and update poly order
        polyderStruct.coeffs = linearityPolyDerCoeffts(:);
        polyderStruct.order = polyStruct(cadenceIndex).order - 1;

        %------------------------------------------------------------------
        % evaluate derivative of polynomial for uncertainty propagation
        %------------------------------------------------------------------
        [derivLinearityCorrection] = weighted_polyval(pixelsToCorrect, polyderStruct);

        % save polyder coefficients and uncertainties to tmp struct
        uncertaintyStruct(cadenceIndex).linearityPolyfitParametersPrime = polyderStruct;
        uncertaintyStruct(cadenceIndex).derivLinearityCorrection = derivLinearityCorrection;

        % collect uncertainty terms: pixels x = x/numberOfExposures,  p(x) is linearity correction
        % TBlkCorrToNonlinCorr = dp(x)/dx *x + p(x)

        TBlkCorrToNonlinCorr = derivLinearityCorrection(:) .* pixelsToCorrect(:) + linearityCorrection(:);

        % save transform to uncertainty struct
        uncertaintyStruct(cadenceIndex).TBlkCorrToNonlinCorr = TBlkCorrToNonlinCorr;

        %------------------------------------------------------------------
        % apply linearity correction term to pixels and re-scale for numberOfExposures
        %------------------------------------------------------------------
        correctedPixels(:, cadenceIndex) = linearityCorrection(:) .* pixelsToCorrect(:) * numberOfExposures;

        if pouEnabled

            % for the x chain only (disableLevel == 1)
            % variableName = variableName .* linearityCorrection(:) --> type 'scaleV'
            disableLevel = 1;
            tStruct = append_transformation(tStruct, 'scaleV', variableName, disableLevel, linearityCorrection(:));

            % for the Cx chain only (disableLevel == 2)
            % variableName = variableName .* TBlkCorrToNonlinCorr --> type 'scaleV'
            disableLevel = 2;
            tStruct = append_transformation(tStruct, 'scaleV', variableName, disableLevel, TBlkCorrToNonlinCorr);


            % copy  shorter temporary structure into calTransformStruct
            calTransformStruct(:,cadenceIndex) = tStruct;
        end
    end
end

return;

function modelPixelMat = evaluate(obj, cadences)
%**************************************************************************
% function modelPixelMat = evaluate(obj, cadences)
%**************************************************************************
% Evaluate the aperture model at the specified cadences. The model of pixel
% p at cadence c is given by 
%                          
%     modelPixelMat(c,p) = sum( coefficients(c,:) .* basisVectors(p,:,c) )
%
% Note that this function doesn not fit the model, but evaluates the model
% using the existing coefficients. Basis vectors will be updated if the
% obj.basisOutOfDate flag is set, which will be the case if either the PRF
% model or the motion model have changed since the last update.
%
% INPUTS
%     cadences            : An N-length array of cadence indices for which 
%                           to evaluate the model.
%
% OUTPUTS
%     modelPixelMat       : An nPixels-by-N matrix of modeled pixel values,
%                           where N is the length of the 'cadences' input
%                           argument.
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
    SUM_DIMENSION = 2;
    
    nCadences  = obj.get_num_cadences();
    nPixels    = obj.get_num_pixels(); % # pixels in total aperture.
        
    % Ensure cadences is a row vector containing values in the valid range.
    if ~exist('cadences', 'var')
        cadences = rowvec(1:nCadences); 
    else
        if any(cadences < 1 | cadences > nCadences)
            error('Requested cadences outside valid range.');
        end
        cadences = rowvec(cadences);
    end
    
    % Update the basis if it is out of date. 
    obj.update_basis();
    
    % Evaluate the model for each cadence specified.
    modelPixelMat = zeros(nPixels, length(cadences));
    for iCadence = 1:length(cadences)
        cadenceNumber = cadences(iCadence);
        modelPixelMat(:, iCadence) = ...
            sum( repmat(obj.coefficients(cadenceNumber,:), [nPixels, 1]) ...
                 .* obj.basisVectors(:, :, cadenceNumber), SUM_DIMENSION );

% I used the following code to check the above code on 4/18/14. Results 
% were identical -RLM
% -------------------
%         modelPixelArray = zeros(nPixels, 1);
%         nBasisVectors = numel(obj.contributingStars) + 1;
%         for iVector = 1:nBasisVectors
%             c = obj.coefficients(cadenceNumber, iVector);
%             bv = obj.basisVectors(:, iVector, cadenceNumber);
%             modelPixelArray = modelPixelArray + c * bv;
%         end
%         modelPixelMat(:, iCadence) = modelPixelArray;
    end
end

%********************************** EOF ***********************************

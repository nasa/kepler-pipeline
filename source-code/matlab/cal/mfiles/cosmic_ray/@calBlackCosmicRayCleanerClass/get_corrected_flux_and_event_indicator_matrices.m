function [correctedFluxMat, eventIndicatorMat] = ...
         get_corrected_flux_and_event_indicator_matrices(obj, returnSparse)
%**************************************************************************
% function [correctedFluxMat, eventIndicatorMat] = ...
%        get_corrected_flux_and_event_indicator_matrices(obj, returnSparse)
%**************************************************************************
% This function returns matrices for use with the 8.3 CAL function
% correct_black_pix_for_cosmic_rays() 
%
% INPUTS:
%     returnSparse      : If true, construct and return sparse matrices.
%
% OUTPUTS:
%     correctedFluxMat  : An nCadence-by-nCcdRows real matrix whose columns
%                         contain corrected pixel values.
%     eventIndicatorMat : A logical matrix of indicators identifying 
%                         entries in correctedFluxMat that have had a
%                         cosmic ray correction applied. 
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
    if ~exist('returnSparse', 'var')
        returnSparse = false;
    end

    % Process any unprocessed targets.
    if ~all([obj.isCleaned])
        obj.clean();
    end

    nPixels   = obj.nCcdRows;
    nCadences = length(obj.timestamps);
    resultPixelArray = obj.disassemble_collateral_targets( obj.targetArray );    
    
    if returnSparse == true
        correctedFluxMat  = sparse(nCadences, nPixels);
        eventIndicatorMat = sparse(false(nCadences, nPixels)); 
    else
        correctedFluxMat  = zeros(nCadences, nPixels);
        eventIndicatorMat = false(nCadences, nPixels);
    end
        
    for iPixel = 1:numel(resultPixelArray)
        row = resultPixelArray(iPixel).ccdRow;
        correctedFluxMat(  :, row ) = resultPixelArray(iPixel).values;
        eventIndicatorMat( :, row ) = ...
            resultPixelArray(iPixel).cosmicRaySignal > 0;
    end

end

%********************************** EOF ***********************************
function destPoly = unpack_background_polynomial( inputsStruct )
% destPoly = unpack_background_polynomial( inputsStruct)
%    INPUTS:
%       This is the subset of the inputsStruct that this function finds
%       interesting.
%       unpackBackgroundBlob - logical. this should be set to true
%       cadenceType          - string.  This should be 'long' or 'LONG'
%       ccdModule            - int.  This should match the ccdModule in
%                              the background blob.
%       ccdOutput            - int.  This should match the ccdOutput in the
%                              background blob.
%       backgroundInputs     - struct. Contains background blob file info
%           backgroundBlobs  - struct.  The blob file series.
%           pixelCoordinates - struct array.  This should be empty.
%    OUTPUTS:
%       backgroundPolynomial - struct.
%           ccdRowOffset     - int. ccd row coordinate offset
%           ccdColOffset     - int. ccd column coordinate offset
%           ccdRowScale      - int. ccd row coordinate scale
%           ccdColScale      - int. ccd column coordinate scale
%           ccdRowOrigin     - int. ccd row coordinate origin
%           ccdColOrigin     - int. ccd column coordinate origin
%           polynomials      - 1d array of struct.  one per cadence
%               coeffs       - 1d array of double.
%               covarianceCoeffs - 2d array of double
%               cadence      - int. the absolute cadence number
%               gap          - logical.  When true coeffs and
%                              covarianceCoeffs are undefined.
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

initDestPoly = struct(            'ccdRowOffset', 0, ...
                                  'ccdColOffset', 0, ...
                                  'ccdRowScale', 0, ...
                                  'ccdColScale', 0, ...
                                  'ccdRowOrigin', 0, ...
                                  'ccdColOrigin', 0, ...
                                  'polynomials', []);
                              
if ~ inputsStruct.unpackBackgroundBlob
    destPoly = initDestPoly;
else
    if ~ strcmpi(inputsStruct.cadenceType, 'long')
        error('Invalid cadence type %s\n  Expected long cadence.', inputsStruct.cadenceType);
    end
    if isempty(inputsStruct.backgroundInputs.backgroundBlobs)
        error('Missing background blobs.');
    end
    
    srcPolyStruct = poly_blob_series_to_struct(inputsStruct.backgroundInputs.backgroundBlobs);
    % not interpolating the background since we want to archive
    % interpolated values, generally speaking.
    
    nCadences = length(srcPolyStruct);
    for m = 1:nCadences
        if srcPolyStruct(m).backgroundPolyStatus
            firstSrcPoly = srcPolyStruct(m).backgroundPoly;
            srcCcdModule = srcPolyStruct(m).module;
            srcCcdOutput = srcPolyStruct(m).output;
            break
        end
    end
    
    if ~ (exist('firstSrcPoly', 'var') == 1)
        error('No good background polynomials.')
    end
    
    if inputsStruct.ccdModule ~= srcCcdModule || inputsStruct.ccdOutput ~= srcCcdOutput
       error('Expected ccdModule/ccdOutput (%d, %d), but found (%d, %d).', inputsStruct.ccdModule, inputsStruct.ccdOutput, srcCcdModule, srcCcdOutput)
    end
    
   
    
    nCoeff = length(firstSrcPoly.coeffs);
    initPolynomial = struct('coeffs', zeros(nCoeff, 1), ...
                            'covarianceCoeffs', zeros(nCoeff*nCoeff, 1), ...
                            'cadence', 0, ...
                            'gap', false);
    
    %TODO:  make sure x and y to row, col are correct.
    destPoly = initDestPoly;
    destPoly.ccdRowScale = firstSrcPoly.scalex;
    destPoly.ccdColScale = firstSrcPoly.scaley;
    destPoly.ccdRowOffset = firstSrcPoly.offsetx;
    destPoly.ccdColOffset= firstSrcPoly.offsety;
    destPoly.ccdRowOrigin = firstSrcPoly.originx;
    destPoly.ccdColOrigin = firstSrcPoly.originy;
    destPoly.polynomials = repmat(initPolynomial, nCadences, 1);
    for m = 1:nCadences
        mthSrcPolynomial = srcPolyStruct(m).backgroundPoly;
        destPoly.polynomials(m).coeffs = mthSrcPolynomial.coeffs;
        destPoly.polynomials(m).covarianceCoeffs = mthSrcPolynomial.covariance(:);
        destPoly.polynomials(m).cadence = srcPolyStruct(m).cadence;
        destPoly.polynomials(m).gap = ~ srcPolyStruct(m).backgroundPolyStatus;
    end
end  % matches ~ inputsStruct.unpackBackgroundBlob
return


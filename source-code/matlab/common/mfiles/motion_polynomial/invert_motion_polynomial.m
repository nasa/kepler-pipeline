function [ra, dec, covarianceRaDec, errRowCol] = invert_motion_polynomial(row, col, motionPolyStruct, covarianceRowCol, fcConstants, tolerance)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  function [ra, dec, covarianceRaDec, errRowCol] = invert_motion_polynomial(row, col, motionPolyStruct, covarianceRowCol, fcConstants, tolerance)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%  This function is an inverted function of the motion polynomial evaluation. With a given motion polynomial of a module/output, it solves for
%  the source position (ra, dec) in the sky for a given position (row, column) at the module/output.
% 
%  Inputs:
%    row                given row value (pixel, 1-based)
%    col                given column value (pixel, 1-based)
%    motionPolyStruct   motion polynomials structure
%    covarianceRowCol   2x2 covaraiance matrix of the inputs row and col (pixel^2)
%    fcConstants        FC constants structure
%    tolerance          (optional) tolerance of the error of the solution in the row and column frame (pixel).
%                       Default value is 1e-10. 
%
%  Outputs:
%    ra                 solution of right ascension (deg)
%    dec                solution of declination (deg)
%    covarianceRaDec    2x2 covariance matrix of the solution of ra and dec (deg^2)
%    errRowCol          error of the solution in the row and column frame (pixel)
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

if ~( nargin==5 || nargin==6 )
    error('invert_motionPoly must be called with 5 or 6 input arguments.');
end

if ( ~exist('tolerance', 'var') || isempty(tolerance) )
    tolerance = 1e-10;
end

% Set defaul values of outputs
ra              = -1;
dec             = -1;
covarianceRaDec = zeros(2,2);
errRowCol       = -1;

% Define limits in rows and columns for science pixels
rowStart = fcConstants.MASKED_SMEAR_END  + 2;       % 1-based
rowEnd   = fcConstants.VIRTUAL_SMEAR_START;         % 1-based
colStart = fcConstants.LEADING_BLACK_END + 2;       % 1-based
colEnd   = fcConstants.TRAILING_BLACK_START;        % 1-based

% Check the validity of the inputs
if ( row<rowStart || row>rowEnd )
    disp(['invert_motionPoly: input row value should be in the range from ' num2str(rowStart) ' to ' num2str(rowEnd)]); 
    return 
end
if ( col<colStart || col>colEnd )
    disp(['invert_motionPoly: input col value should be in the range from ' num2str(colStart) ' to ' num2str(colEnd)]); 
    return
end
if (motionPolyStruct.rowPolyStatus~=1)
    disp('invert_motionPoly: invalid rowPoly in the input motionPolyStruct');
    return
end
if (motionPolyStruct.colPolyStatus~=1)
    disp('invert_motionPoly: invalid colPoly in the input motionPolyStruct');
    return
end
if (tolerance<=0)
    disp('invert_motionPoly: input tolerance should be positive');
    return
end


%
% Equation:
%
%   [ row ]                    [ ra  ]
%   [     ] = v0 + jacobianM * [     ] + higherOrderTerms
%   [ col ]                    [ dec ] 
%

jacobianM(1,1) = motionPolyStruct.rowPoly.coeffs(2)*motionPolyStruct.rowPoly.scalex;
jacobianM(1,2) = motionPolyStruct.rowPoly.coeffs(3)*motionPolyStruct.rowPoly.scaley;
jacobianM(2,1) = motionPolyStruct.colPoly.coeffs(2)*motionPolyStruct.colPoly.scalex;
jacobianM(2,2) = motionPolyStruct.colPoly.coeffs(3)*motionPolyStruct.colPoly.scaley;
v0(1,1)        = motionPolyStruct.rowPoly.coeffs(1) - jacobianM(1,1)*motionPolyStruct.rowPoly.originx - jacobianM(1,2)*motionPolyStruct.rowPoly.originy; 
v0(2,1)        = motionPolyStruct.colPoly.coeffs(1) - jacobianM(2,1)*motionPolyStruct.colPoly.originx - jacobianM(2,2)*motionPolyStruct.colPoly.originy;

% Solve for the solution (ra, dec) with iterations
invJacobianM = inv(jacobianM);
raDec   = invJacobianM*([row col]'-v0);
iterationCounter = 0;
iterationLimit   = 20;
while iterationCounter<iterationLimit
    
    rowBuf = weighted_polyval2d(raDec(1), raDec(2), motionPolyStruct.rowPoly);
    colBuf = weighted_polyval2d(raDec(1), raDec(2), motionPolyStruct.colPoly);
    diffV(1,1) = rowBuf - row;
    diffV(2,1) = colBuf - col;
    errRowCol = sqrt(diffV'*diffV);

    if ( errRowCol<tolerance )
        break;
    end

    raDec = raDec - invJacobianM*diffV;
    iterationCounter = iterationCounter + 1;
    
end

% Determine output solution of ra and dec
ra  = raDec(1);
dec = raDec(2);

% Determine output errRowCol
[rowBuf, rowUncertainty, designMatrixRow] = weighted_polyval2d(ra, dec, motionPolyStruct.rowPoly);
[colBuf, colUncertainty, designMatrixCol] = weighted_polyval2d(ra, dec, motionPolyStruct.colPoly);
diffV(1,1) = rowBuf - row;
diffV(2,1) = colBuf - col;
errRowCol  = sqrt(diffV'*diffV);

covarianceMotionPoly = diag([designMatrixRow*motionPolyStruct.rowPoly.covariance*designMatrixRow' designMatrixCol*motionPolyStruct.colPoly.covariance*designMatrixCol']);
covarianceRaDec      = invJacobianM * ( covarianceRowCol + covarianceMotionPoly ) * invJacobianM';

return

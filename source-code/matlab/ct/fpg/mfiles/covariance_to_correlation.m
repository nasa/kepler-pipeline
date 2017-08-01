function correlationMatrix = covariance_to_correlation(covarianceMatrix)
%
% COVARIANCE_TO_CORRELATION -- convert a covariance matrix to a correlation matrix
%
% correlationMatrix = covariance_to_correlation(covarianceMatrix) returns the correlation
%    matrix which is equivalent to the caller-supplied covariance matrix.  The
%    relationship between the two is as follows:
%
%        correlationMatrix(i,i) = sqrt(covarianceMatrix(i,i)) for all i
%
%        correlationMatrix(i,j) = covarianceMatrix(i,j)/sqrt( covarianceMatrix(i,i) * 
%                                                             covarianceMatrix(j,j) )
%
%    Thus, the diagonal of the correlation matrix is the estimated total error represented
%    by the covariance matrix, while the off-diagonal terms are normalized to lie between
%    -1 and 1, with 0 representing no correlation between the coefficients and +/- 1
%    representing full correlation.
%
% Version date:  2008-May-30.
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
%=========================================================================================

  nRow = size(covarianceMatrix,1) ; nCol = size(covarianceMatrix,2) ;
  if (nRow ~= nCol)
      error(' covariance_to_correlation requires a square matrix!') ;
  end
  
  correlationMatrix = zeros(nRow) ;
  for count = 1:nRow
      correlationMatrix(count,count) = sqrt(covarianceMatrix(count,count)) ;
  end
  
  for i = 2:nRow
      for j = 1:i-1
          correlationMatrix(i,j) = covarianceMatrix(i,j) ...
              / correlationMatrix(i,i) / correlationMatrix(j,j) ;
          correlationMatrix(j,i) = correlationMatrix(i,j) ;
      end
  end
 
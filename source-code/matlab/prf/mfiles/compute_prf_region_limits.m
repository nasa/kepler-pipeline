function [rowRange, colRange, row, col] = compute_prf_region_limits( fcConstants, ...
    regionFraction )
%
% [rowRange, colRange] = compute_prf_region_limits( fcConstants, regionFraction ) --
% compute the min and max rows/columns to be used for PRF fitting, for all regions (4
% corners + center, in that order) based on the focal plane constants and the requested
% region fraction
%
% [rowRange, colRange, row, column] = compute_prf_region_limits( fcConstants,
% regionFraction ) also returns the point at which each PRF is located.
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

% get the relevant row and column parameters out of the fcConstants

  nRowsImaging = fcConstants.nRowsImaging;
  nColsImaging = fcConstants.nColsImaging;
  nLeadingBlack = fcConstants.nLeadingBlack;
  nMaskedSmear = fcConstants.nMaskedSmear;

% The # of rows and # of columns is the # of imaging rows/columns * the regionFraction

  nRows = round(nRowsImaging * regionFraction) ;
  nCols = round(nColsImaging * regionFraction) ;

% the limits depend on the corner of interest

  rowRange = zeros(5,2) ; colRange = zeros(5,2) ;
  
  rowRange(1,1) = 1 ; rowRange(1,2) = nRows ;
  rowRange(2,1) = nRowsImaging-nRows+1 ; rowRange(2,2) = nRowsImaging ;
  rowRange(3,:) = rowRange(2,:) ;
  rowRange(4,:) = rowRange(1,:) ;
  rowRange(5,1) = 1+round( (nRowsImaging-nRows)/2 ) ;
    rowRange(5,2) = nRowsImaging-round( (nRowsImaging-nRows)/2 ) ;
    
  colRange(1,1) = 1 ; colRange(1,2) = nCols ;
  colRange(2,:) = colRange(1,:) ;
  colRange(3,1) = nColsImaging-nCols+1 ; colRange(3,2) = nColsImaging ;
  colRange(4,:) = colRange(3,:) ;
  colRange(5,1) = 1+round( (nColsImaging-nCols)/2 ) ;
  colRange(5,2) = nColsImaging-round( (nColsImaging-nCols)/2 ) ;
  
  row(1) = 0.5 ; 
  row(2) = row(1) + nRowsImaging ;
  row(3) = row(2) ;
  row(4) = row(1) ;
  row(5) = row(1) + nRowsImaging / 2 ;
  
  col(1) = 0.5 ;
  col(2) = col(1) ;
  col(3) = col(1) + nColsImaging ;
  col(4) = col(3) ;
  col(5) = col(1) + nColsImaging / 2 ;
    
  rowRange = rowRange + nMaskedSmear ;
  colRange = colRange + nLeadingBlack ;
  row = row + nMaskedSmear ;
  col = col + nLeadingBlack ;
  

function [row, column, value, residual, uncertainty, ndof] = get_prf_residuals( prfStructure )
%
% [row, column, value, residual, uncertainty, ndof] = get_prf_residuals( prfStructure ) -- 
%   returns the row and column position of each point used in a PRF fit, along with its
%   value, fit residual, uncertainty, and the number of degrees of freedom in the fit.
%
% Version date:  2008-October-14.
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
%     2008-October-14, PT:
%         return the values used in the PRF.
%
%=========================================================================================

  row = [] ; column = [] ; residual = [] ; uncertainty = [] ; ndof = 0 ;
  value = [] ;
  subPixelData = prfStructure.subPixelData ;
  nRows = sqrt(size(subPixelData,1)) ;
  nCols = sqrt(size(subPixelData,1)) ;
  
% loop over the pixel index, the sub-rows, and the sub-columns

  for iPixel = 1:size(subPixelData,1)
      [rowInteger, colInteger] = ind2sub([nRows,nCols],iPixel) ;
      for iSubRow = 1:size(subPixelData,2)
          for iSubCol = 1:size(subPixelData,3)
              
              thisSubPix = subPixelData(iPixel,iSubRow, iSubCol) ;
              
%             some of the sub-pixel regions contain points which lie off the pixel and in
%             neighboring pixels -- these are used in the fit but not the residual
%             calculation.  We omit these by looking at the residual vector length.

              nPoints = length(thisSubPix.residuals) ;
              row = [row ; rowInteger - thisSubPix.subRows(1:nPoints)] ;
              column = [column ; colInteger - thisSubPix.subCols(1:nPoints)] ;
              value = [value ; thisSubPix.values(1:nPoints)] ;
              residual = [residual ; thisSubPix.residuals] ;
              uncertainty = [uncertainty ; thisSubPix.uncertainties(1:nPoints)] ;
              ndof = ndof + (1+thisSubPix.selectedOrder) * (2+thisSubPix.selectedOrder) / 2 ;
              
          end
      end
  end
          
% Right now the row and column are defined in a 1-based coordinate system with (1,1) at
% the center of a corner pixel.  We want to go to a 0-based system with (0,0) at the very
% corner of the corner pixel, so subtract 0.5 from row and from column.
  
  row = row - 0.5 ;
  column = column - 0.5 ;
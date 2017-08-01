function [dRow dCol] = fpgTestDataCheck(fpgTestObject,cadenceList)
%
% fpgTestDataCheck -- Checks to make sure that the motion polynomials in the fpgTestObject
% argument are consistent with the geometry and pointing of the spacecraft which are also
% encoded in the fpgTestObject for a selected set of cadences.  If the second argument
% (list of cadences) is left out, all cadences are in the fpgTestObject are used.  Returns
% a set of row and column errors in pixels (basically row_orig - row_from_poly, and
% similarly for column).  Each return is actually 2 column vectors, with the actual
% difference between original and poly row and column and the error estimate returned from
% weighted_polyval2d.
%
% version date:  2008-apr-16.
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
%
%=========================================================================================

% figure out how many cadences in the original data object

  pointingErrors = get(fpgTestObject,'pointingErrors') ;
  nCadence = size(pointingErrors,2) ;
  
% handle a missing list of cadences  
  
  if (nargin == 1)
      cadenceList = 1:nCadence ;
  end
  if (isempty(cadenceList))
      cadenceList = 1:nCadence ;
  end
  
% unpack list of cadences and compare to size of fpgTestObject

  if ( (min(cadenceList) < 1) | (max(cadenceList) > nCadence) )
      error('fpg:fpgTestDataCheck:badCadenceList', ...
          'List of cadences in fpgTestDataCheck not consistent with fpgTestData object') ;
  end

  % initialize the row and column error information
  
  dRow = [] ; dCol = [] ;
  
% get the static pointing error, the MJD, and the raDec2PixClass object

  staticPointingError = get(fpgTestObject,'overallOrientationError') ;
  mjd = get(fpgTestObject,'mjd') ;
  rdpo = get(fpgTestObject,'raDec2PixObject') ;
  
% get the initial row and column information

  origRowCol = get(fpgTestObject,'posRowCol') ;
  origRow = origRowCol(:,1) ; origCol = origRowCol(:,2) ;
  ovec = ones(length(origRow),1) ;
  
% get the row and column polynomials

  rowPoly = get(fpgTestObject,'rowPoly') ;
  colPoly = get(fpgTestObject,'colPoly') ;
  
% get the expected pointing and pointing errors for each cadence

  dPointing = get(fpgTestObject,'cadencedOrientation') ;
  pointingError = get(fpgTestObject,'pointingErrors') ;
  
% loop over cadences (loops in matlab, bad programmer!) and mod/outs, and convert the row
% and column into RA and Dec; use the motion polynomials to convert back to row and
% column; form the vectors of differences.

  for iCadence = cadenceList
      for iModOut = 1:84
          
          [module,output] = channel2ModuleOutput(iModOut) ;
          
          [ra dec] = pix_2_ra_dec_relative(rdpo, module*ovec, output*ovec, ...
              origRow, origCol, mjd, ...
              staticPointingError(1)+pointingError(1,iCadence) + dPointing(1,iCadence), ...
              staticPointingError(2)+pointingError(2,iCadence) + dPointing(2,iCadence), ...
              staticPointingError(3)+pointingError(3,iCadence) + dPointing(3,iCadence)) ;
          
          [rowFromPoly,errFromPoly] = weighted_polyval2d(ra,dec,rowPoly(iModOut,iCadence)) ;
          
          dRow1 = [rowFromPoly - origRow errFromPoly] ;
          dRow = [dRow ; dRow1] ;
          
          [colFromPoly,errFromPoly] = weighted_polyval2d(ra,dec,colPoly(iModOut,iCadence)) ;
          
          dCol1 = [colFromPoly - origCol errFromPoly] ;
          dCol = [dCol ; dCol1] ;
          
      end
      
  end
  
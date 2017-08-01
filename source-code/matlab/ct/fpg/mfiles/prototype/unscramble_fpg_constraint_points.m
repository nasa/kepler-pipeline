function [mod, out, rowPointer, colPointer, cadence] = unscramble_fpg_constraint_points( fitterArgs )
%
% UNSCRAMBLE_FPG_CONSTRAINT_POINTS -- determine the mod/out of each constraint point in
% the focal point geometry fit, and determine which constraint points are rows and which
% are columns
%
% [mod, out, rowPointer, colPointer] = unscramble_fpg_constraint_points( fitterArgs )
%    takes as its argument a fitterArgs data structure.  It returns an ordered list of the
%    module and output of each constraint point, and also a list of pointers into the
%    constraintPoints data structure which indicates which of the constraintPoints are
%    row values and which are column values.  Thus, unscramble_fpg_constraint_points
%    permits the mapping between the constraint points and the original mod, out, row/col
%    positions to be determined.
%
% [..., cadence] = unscramble_fpg_constraint_points( fitterArgs ) also returns the cadence
%    number of each constraint point.
%
% See also:  fpg_fitterArgs fpg_constraintPoints.
%
% Version date:  2008-may-28.
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

% Modification history:
%
%     2008-May-28, PT:
%         add cadence # vector as an optional return.
%
%=========================================================================================

% dimension the returned vectors

  mod = zeros(fitterArgs.nConstraintPoints/2,1) ;
  out = mod ;
  rowPointer = mod ; 
  colPointer = mod ;
  cadence    = mod ;
  
% loop over long cadences; extract the necessary pointer information and module / output
% information from the RADecModOut data structure.  We can make use of the fact that,
% within any cadence, the row values come first, followed by their corresponding column
% values.

  iStart = 0 ;
  iStop  = 0 ;
  nPointsAlready = 0 ;
  for iCadence = 1:length(fitterArgs.RADecModOut)

%     calculate the number of (row,col) pairs used on this cadence, and the indexing into
%     the return arrays
      
      nPointsThisCadence = size(fitterArgs.RADecModOut(iCadence).matrix,1) ;
      iStart = iStop + 1 ;
      iStop = iStart + nPointsThisCadence - 1 ;
      
      mod(iStart:iStop)     = fitterArgs.RADecModOut(iCadence).matrix(:,3) ;
      out(iStart:iStop)     = fitterArgs.RADecModOut(iCadence).matrix(:,4) ;
      cadence(iStart:iStop) = iCadence ;
      
%     figure out where the rows and columns must be, remembering that the columns in the
%     constraintPoints vector follow the rows
      
      rowPointer(iStart:iStop) = nPointsAlready+iStart:nPointsAlready+iStop ;
      colPointer(iStart:iStop) = nPointsAlready+nPointsThisCadence+iStart: ...
                                 nPointsAlready+nPointsThisCadence+iStop ;
                      
%     total up the # of points which have now been found
                      
      nPointsAlready = nPointsAlready + nPointsThisCadence ;
      
  end % for-loop over cadences
  
% and that's it!

%
%
%
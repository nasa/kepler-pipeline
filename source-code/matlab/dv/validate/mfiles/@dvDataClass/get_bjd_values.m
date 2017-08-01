function [bjdStruct, bjd0, bjdUser] = get_bjd_values( dvDataObject, iTarget, bcmjdUser )
%
% get_bjd_values -- return a struct of barycentric-corrected Julian times (BJDs) for a
% selected target
%
% [bjdStruct, bjd0] = get_bjd_values( dvDataObject, iTarget ) returns the barycentric-
%    corrected Julian times (BJDs) for a selected target.  It also returns the integer
%    portion of the BJD for the start of the unit of work (note that, since barycentric
%    correction is different for each target, the BJD of the UOW start is also different
%    for each target).
%
% [... , bjdUser] = get_bjd_values( ... , bcmjdUser ) also returns a vector of BJDs which
%    correspond to the user-supplied vector of barycentric-corrected modified Julian
%    dates.
%
% Version date:  2010-February-24.
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

% Check that the user-supplied target # is in range, and a scalar

  if ~isscalar( iTarget ) || iTarget <= 0 || ...
          iTarget > length( dvDataObject.targetStruct )
      error('dv:getBjdValues:iTargetInvalid', ...
          'get_bjd_values:  invalid iTarget value' ) ;
  end
  
% get the conversion constant

  mjdToJd = dvDataObject.raDec2PixModel.mjdOffset ;
  
% copy the relevant bcmjd structure over to be the bjd structure

  bjdStruct = dvDataObject.barycentricCadenceTimes(iTarget) ;
  
% apply the correction to BJD; note that the barycentric-corrected MJDs are assumed to all
% be valid values here, which is the case if the dvCadenceTimes struct got its zero values
% filled (for missing cadences) back before the bcmjds were calculated.

  bjdStruct.startTimestamps = bjdStruct.startTimestamps + mjdToJd ;
  bjdStruct.midTimestamps   = bjdStruct.midTimestamps   + mjdToJd ;
  bjdStruct.endTimestamps   = bjdStruct.endTimestamps   + mjdToJd ;
  
% determine the BJD offset to be used for plotting

  bjd0 = floor( min( bjdStruct.startTimestamps ) ) ;
  
% If the user supplied some vector of bcmjds, apply the offset to it as well

  if exist ( 'bcmjdUser', 'var' ) && ~isempty( bcmjdUser )
      bjdUser = bcmjdUser + mjdToJd ;
  else
      bjdUser = [] ;
  end
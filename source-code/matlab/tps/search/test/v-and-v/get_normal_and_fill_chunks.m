function [normalChunks, fillChunks] = get_normal_and_fill_chunks( gapInfo, fillInfo, ...
    nCadences, oneBased )
%
% get_normal_and_fill_chunks -- determine congiguous regions of normal and filled data
% based on gap and fill information
%
% [normalChunks, fillChunks] = get_normal_and_fill_chunks( gapInfo, fillInfo, ...
%    nCadences, oneBased ) uses gapInfo (either gapIndices or gapIndicators) and fillInfo
%    (either fillIndices or fillIndicators) to determine regions of contiguous normal data
%    and regions of contiguous fill data.  The function returns two cell arrays, each of
%    which contains vectors of indices of contiguous data or fill.  Argument nCadences is
%    the number of samples total, oneBased is a logical which determines whether any
%    indices vectors are zero- or one-based.
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

%=========================================================================================

  if oneBased
      offset = 0 ;
  else
      offset = 1 ;
  end
  
  normalIndicators = true(nCadences,1) ;
  
% gapInfo and fillInfo can be either indices or indicators

  gapIndicators  = get_indicators_from_info( gapInfo, nCadences, offset ) ;
  fillIndicators = get_indicators_from_info( fillInfo, nCadences, offset ) ;
  
  normalIndicators(gapIndicators) = false ;
  normalIndicators(fillIndicators) = false ;
  
  normalChunks = identify_contiguous_integer_values( find(normalIndicators) ) ;
  fillChunks   = identify_contiguous_integer_values( find(fillIndicators) ) ;

return

%=========================================================================================

% subfunction which handles indicator vs info options

function indicators = get_indicators_from_info( info, nCadences, offset )

  if islogical( info ) && length( info ) == nCadences
      indicators = info ;
  else
      indicators = false(nCadences,1) ;
      indicators(info+offset) = true ;
  end
  
return


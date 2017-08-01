function colCCD = convert_to_ccd_column( out, col, baseString )
%
% CONVERT_TO_CCD_COLUMN convert the column number from a module output to the equivalent
% column number on the CCD.
%
% colCCD = convert_to_ccd_column( out, col, baseString ) takes a Kepler output number and 
%    column number and converts to the equivalent column number on the overall CCD.  On
%    any given output, the column number increases monotonically as one goes from the
%    readout point towards the CCD center; since the readouts are in the corners, this
%    means that a CCD does not have a well-defined column coordinate system (ie, on mod 2,
%    out 1, CCD # increases from col 1 to col 1112.5; at col 1112.5 the out changes from 1
%    to 2; as one continues towards the mod 2, out 2 readout, the col # now decreases).
%    Function convert_to_ccd_column converts to a well-defined column coordinate for each
%    CCD, which increases monotonically from the odd-numbered output's readout point to
%    the even-numbered output's readout point.
%
% The user is required to specify whether the coordinates in col are one- or zero-based.
%    This is accomplished with the baseString, which can be either 'one-based' or
%    'zero-based'.  
%
% Version date:  2008-September-19.
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
%     2008-September-19, PT:
%         force user to specify one-based or zero-based coordinates.
%     2008-May-29, PT:
%         change to use 1111.5 as the center point of the CCD, from 1112.5.
%
%=========================================================================================

% check input validity first

  if ( (~isvector(out)) | (~isvector(col)) )
      error(' Arguments to convert_to_ccd_column must be vectors') ;
  end
  if ( (~isnumeric(out)) | (~isnumeric(col)) )
      error(' Arguments to convert_to_ccd_column must be numeric') ;
  end
  if ( (~isreal(out)) | (~isreal(col)) )
      error(' Arguments to convert_to_ccd_column must be real') ;
  end
  if ( length(out) ~= length(col) )
      error(' Arguments to convert_to_ccd_column must have the same length') ;
  end
  if ( any(round(out) ~= out) )
      error(' First argument to convert_to_ccd_column must be integer values') ;
  end
  if ( any(out < 1) | any(out > 4) )
      error(' First argument to convert_to_ccd_column must be between 1 and 4') ;
  end
  if ( nargin < 3 )
      error(' convert_to_ccd_column requires 3 arguments') ;
  end
  
% check one vs zero based

  if (strcmpi(baseString,'one-based'))
      basisValue = 1 ;
  elseif (strcmpt(baseString,'zero-based'))
      basisValue = 0 ;
  else
      error(' 3rd arg in convert_to_ccd_column must be either ''one-based'' or ''zero-based'' ') ;
  end
  
% make the output column value equal the input one for now

  colCCD = col ;
  
% find the even-numbered outputs and their indices

  oddOutValue = mod(out,2) ; 
  evenOutValueIndex = find(~oddOutValue) ;
  
% convert the column numbers on even-numbered outputs to a monotonic system

  colCCD(evenOutValueIndex) = 2*(1111.5+basisValue) - colCCD(evenOutValueIndex) ;
  
% and that's it!

%
%
%
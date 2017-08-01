function [out, col] = convert_from_ccd_column( ccdNumber, colCCD, baseString )
%
% convert_from_ccd_column -- convert the column number from a CCD to the equivalent column
%    number in a module/output
%
% [out, col] = convert_from_ccd_column( ccdNumber, colCCD, baseString ) takes a vector of
% ccd numbers (1-42), a vector of CCD columns, and a base string ('one-based' or
% 'zero-based') and determines, for each member of the vectors, the output number and the
% column number in mod/out coordinates.
%
% Version date:  2009-February-03.
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

% check input validity first

  if ( (~isvector(ccdNumber)) || (~isvector(colCCD)) )
      error(' Arguments to convert_to_ccd_column must be vectors') ;
  end
  if ( (~isnumeric(ccdNumber)) || (~isnumeric(colCCD)) )
      error(' Arguments to convert_to_ccd_column must be numeric') ;
  end
  if ( (~isreal(ccdNumber)) || (~isreal(colCCD)) )
      error(' Arguments to convert_to_ccd_column must be real') ;
  end
  if ( length(ccdNumber) ~= length(colCCD) )
      error(' Arguments to convert_to_ccd_column must have the same length') ;
  end
  if ( any(round(ccdNumber) ~= ccdNumber) )
      error(' First argument to convert_to_ccd_column must be integer valued') ;
  end
  if ( any(ccdNumber < 1) || any(ccdNumber > 42) )
      error(' First argument to convert_to_ccd_column must be between 1 and 42') ;
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

  col = colCCD ;
  
% compute the location of the center of the CCD

  ccdCenterColumn = 1111.5 + basisValue ;
  
% determine the low- and high-channel numbers and output numbers

  highChannel = 2*ccdNumber ;
  lowChannel  = highChannel-1 ;
  [mod,lowOut] = convert_to_module_output(lowChannel) ;
  [mod,highOut] = convert_to_module_output(highChannel) ;
  
% find the coordinates which are on the high mod/out as opposed to the low one

  out = lowOut ;
  out( colCCD > ccdCenterColumn ) = highOut( colCCD > ccdCenterColumn ) ;
  
% do the conversion

  col( colCCD > ccdCenterColumn ) = ...
      2* ccdCenterColumn - colCCD( colCCD > ccdCenterColumn ) ;
  
return

% and that's it!

%
%
%

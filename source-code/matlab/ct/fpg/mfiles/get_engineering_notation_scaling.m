function [scaleFactor, prefix] = get_engineering_notation_scaling( dataMatrix )
%
% GET_ENGINEERING_NOTATION_SCALING -- return the required scaling and prefix to convert a
% data matrix to engineeing notation
%
% [scaleFactor, prefix] = get_engineering_notation_scaling( dataMatrix ) examines the scale
%    of values in the data matrix to determine an appropriate engineering notation scaling
%    for the matrix (ie, convert from its current units to nano-units, micro-units,
%    milli-units, etc).  The necessary scaling is returned in scalefac, and the prefix
%    ("micro", "nano", etc) is supplied in prefix.  If the max value of dataMatrix is less
%    than 1e-24 ("yocto") or greater then or equal to 1e+25 ("yotta"), it will be returned
%    unscaled.
%
% Example:
%
%    [scaleFactor, prefix] = get_engineering_notation_scaling( 1.0e-6 ) returns
%       scaleFactor == 1e6 (since 1e6 * 1.0e-6 brings the data into the range of unit
%       values), and prefix == 'micro' (since plotting scaleFactor * 1e-6 results in a
%       plot of micro-units).
%
% Version date:  2008-May-28.
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

% set default return

  scaleFactor = 1 ; prefix = [] ;

% convert the data matrix to a vector and find the value with the max absolute value

  maxValue = max(abs(dataMatrix(:))) ;
  
% if maxValue isn't zero, examine its base-10 logarithm to figure out what scale factor
% and prefix are appropriate.  

  if (maxValue > 0)
      
      maxValueLog10 = log10(maxValue)+1 ;
      nZeroBlocks = floor(maxValueLog10/3) ;
      
      switch nZeroBlocks          
          case 8
              scaleFactor = 1e-24 ;
              prefix = 'yotta' ;
          case 7 
              scaleFactor = 1e-21 ;
              prefix = 'zetta' ;
          case 6 
              scaleFactor = 1e-18 ;
              prefix = 'exa' ;
          case 5
              scaleFactor = 1e-15 ;
              prefix = 'peta' ;
          case 4
              scaleFactor = 1e-12 ;
              prefix = 'tera' ;
          case 3
              scaleFactor = 1e-9 ;
              prefix = 'giga' ;
          case 2
              scaleFactor = 1e-6 ;
              prefix = 'mega' ;
          case 1
              scaleFactor = 1e-3 ;
              prefix = 'kilo' ;
          case 0
              scaleFactor = 1 ;
              prefix = [] ;
          case -1
              scaleFactor = 1e3 ;
              prefix = 'milli' ;
          case -2
              scaleFactor = 1e6 ;
              prefix = 'micro' ;
          case -3
              scaleFactor = 1e9 ;
              prefix = 'nano' ;
          case -4
              scaleFactor = 1e12 ;
              prefix = 'pico' ;
          case -5
              scaleFactor = 1e15 ;
              prefix = 'femto' ;
          case -6
              scaleFactor = 1e18 ;
              prefix = 'atto' ;
          case -7
              scaleFactor = 1e21 ;
              prefix = 'zepto' ;
          case -8
              scaleFactor = 1e24 ;
              prefix = 'yocto' ;
          otherwise
              warning('Requested data out of bounds, no rescaling possible') ;
      end
      
  end
  
% and that's it!

%
%
%
function obj = fpgTestData( arg1 )
%
% fpgTestData -- constructor for the fpgTestData class.
%
% fpgTestData(object) duplicates an existing fpgTestData object and returns
% it to the user.  If an object of another class is given as the input
% argument, an error will result.
%
% fpgTestData() returns a blank fpgTestData object.
% 
% The user-set members of fpgTestData are:
%
%                calendarDate:  date in 'dd-mmm-yyyy hh:mm:ss' format 
%                   randState:  desired state to use for the flat random number generator
%                  randnState:  desired state to use for the gaussian random number 
%                               generator
%                   posRowCol:  npos x 2 matrix of nominal row,col positions to use for
%                               fitting the motion polynomial
%         centroidErrorPixels:  RMS centroiding error, in pixels 
%                    ccdError:  vector of RMS dRow, dCol, dRot errors [pix,pix,deg]
%                 dPlateScale:  fractional plate scale error
%     overallOrientationError:  Pointing errors [deg,deg,deg] to be applied to all
%                               cadences
%         cadencedOrientation:  3 x N_LC matrix of dRA, dDec, dRoll [deg,deg,deg] for the 
%                               N_LC long cadences to be generated.  At least one of the
%                               orientations must be [0 ; 0 ; 0].
%        cadencePointingError:  vector of errors applied to non-reference pointing
%                               cadences; the first 3 values are RMS additive errors in
%                               RA, Dec, Roll [deg,deg,deg]; last 2 values are
%                               multiplicative scale factor for dRA and dDec.
% 
% The software-set members of fpgTestData are:
%
%                 rowPoly:  84 x N_LC array of data structures, with format given by the
%                           output format of weighted_polyval2d.m.  Row polynomials for
%                           each mod/out on each cadence.
%                 colPoly:  84 x N_LC array of column polynomials, same format as rowPoly.
%          pointingErrors:  Pointing errors used on each cadence.
%         raDec2PixObject:  the raDec2PixClass object used in data generation.
%                     mjd:  Modified Julian Date used in data generation.
%
% Version date:  2008-apr-14.
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

%==========================================================================

% argument checking:  too many arguments

  if (nargin > 1)
      error(' fpgTestData takes <= 1 arguments!') ;
  end
  
% one argument means return the fpgTestData object passed by the caller,
% but first make sure that it's in fact an fpgTestData object!
  
  if (nargin == 1)
      if (isa(arg1,'fpgTestData'))
          obj = arg1 ;
          return ;
      else
          error(' fpgTestData argument must be an fpgTestData object!') ;
      end
  end
  
% no arguments -- set up the required members with blanks

  obj = class(fpgTestDataStruc,'fpgTestData') ;
function motionPolynomials = retrieve_motion_polys_for_fpg( mjdRange,  ...
       raDec2PixModelFakeData, pointingFakeData, mjdRefCadence ) 
%
% retrieve_motion_polys_for_fpg -- function which performs retrieval of real motion
% polynomials, or generation of fakedata ones, for focal plane geometry in interactive
% mode
%
% motionPolynomials = retrieve_motion_polys_for_fpg( mjdRange ) retrieves all the motion
%    polynomials which are valid for the range of times mjdRange(1) to mjdRange(2).
%
% motionPolynomials = retrieve_motion_polys_for_fpg( mjdRange, raDec2PixModelFakeData,
%    pointingFakeData, mjdRefCadence ) generates fakedata motion polynomials.  Argument
%    raDec2PixModelFakeData is an raDec2PixClass object with the geometry model to be used
%    for data generation; pointingFakeData is a 3 x nCadences array with the pointing
%    offsets from nominal, in degrees, for each cadence; mjdRefCadence is the approximate
%    MJD of the reference cadence (the exact MJD is determined by get_mjdRefCadence).
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

% Modification History:
%
%     2008-September-19, PT:
%         update raDec2PixClass constructor call.
%
%=========================================================================================

% if there is only 1 argument, then we want the real thing

  if (nargin == 1)
      
      motionPolynomials = retrieve_motion_polys( mjdRange(1), mjdRange(2) ) ;
      
  else % generate fake motion polynomials
      
      nCadences = size(pointingFakeData,2) ;
      dMjd = (mjdRange(2) - mjdRange(1)) / nCadences ;
      mjdMidTime = mjdRange(1) + dMjd * ([0:nCadences-1] + 0.5) ;
      [mjdRefCadence, refCadence] = get_mjdRefCadence( mjdRefCadence, mjdMidTime ) ;
      raDec2PixObjectFakeData = raDec2PixClass(raDec2PixModelFakeData,'one-based') ;
      
      rowGrid = [50 275 500 725 950] ; colGrid = rowGrid ;
      sigCentroid = 20e-6 ;
      
      motionPolynomials = generate_fakedata_motion_polynomials( raDec2PixObjectFakeData, ...
          mjdRange(1), dMjd, pointingFakeData, rowGrid, colGrid, sigCentroid, refCadence ) ;
      
  end
  
% and that's it!

%
%
%


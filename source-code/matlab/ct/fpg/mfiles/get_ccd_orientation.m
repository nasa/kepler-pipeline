function orientation = get_ccd_orientation( module, output )
%
% get_ccd_orientation -- determine the rotational orientation of CCDs based on module and
% output values.
%
% orientation = get_ccd_orientation( module, output ) takes a vector of module values and
%    a vector of output values and returns a vector of orientation values.  The
%    orientation vector is zero-based, with 0 representing the orientation of the CCD with
%    module 2, outputs 1 and 2 ; 1 representing the orientation of the CCD with module 6,
%    outputs 3 and 4 (90 degree clockwise rotation, viewed with X' into page) ; 2
%    representing the orientation of the CCD with module 2, outputs 3 and 4 (180 degree
%    rotation); and 3 representing the orientation of the CCD with module 6, outputs 1 and
%    2 (270 degree clockwise rotation, viewed with X' into page).
%
% Version date:  2008-July-10.
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

% convert to CCD #

  ccdNum = ceil( convert_from_module_output( module, output ) / 2 ) ;
  
% make a zero vector of equal length

  orientation = zeros(size(ccdNum)) ;
  
% find the non-zero orientations and set them

  orientation1Ccd = [8 13 15 18 20 22 23 25 28 30 35] ;
  orientation2Ccd = [2 4 6 10 12 31 33 37 39 41] ;
  orientation3Ccd = [7 14 16 17 19 21 24 26 27 29 36] ;
  
  orientation(ismember(ccdNum,orientation1Ccd)) = 1 ;
  orientation(ismember(ccdNum,orientation2Ccd)) = 2 ;
  orientation(ismember(ccdNum,orientation3Ccd)) = 3 ;

% and that's it!

%
%
%

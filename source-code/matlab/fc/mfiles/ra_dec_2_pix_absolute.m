function [module output row column] = ra_dec_2_pix_absolute(ra, dec, mjds, raPointing, decPointing, rollPointing, aberrateFlag)
%        [module output row column] = ra_dec_2_pix_absolute(ra, dec, mjds, raPointing, decPointing, rollPointing, aberrateFlag)
%
% Returns the pixelspace positions of the N sky coordinates specified by (ra, dec), at the M times specified by mjds.
% The raPointing, decPointing, and rollPointing must be the same length as mjds.
% The size of the outputs will be NxM.
%
% INPUTS:
%   ra  -- The RA of the sky coordindate(s) in degrees.  A one-or-more element vector with a length the same size as dec.
%   dec -- The RA of the sky coordindate(s) in degrees.  A one-or-more element vector with a length the same size as ra.
%   mjds --The modified julian date of for the coordinate transformation.  Must be the same size as raPointing, decPointing, and rollPointing.  
%   raPointing --The pointing RA of the spacecraft for the vector of Julian dates given in the mjds argument.  Must be the same size as mjds.
%   decPointing --The pointing declination of the spacecraft for the vector of Julian dates given in the mjds argument.  Must be the same size as mjds.
%   rollPointing --The pointing roll of the spacecraft for the vector of Julian dates given in the mjds argument.  Must be the same size as mjds.
%
% OUTPUTS:
%   module -- the Kepler CCD module the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
%   output -- the Kepler CCD outupt the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
%   row -- the Kepler pixel row the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
%   column -- the Kepler CCD column the sky coordinate falls upon.  The size of this output is NxM, where N is the length of ra, and M is the length of mjds.
% 
%   N.B.: The row and column outputs are on the accumulation memory silicon (they include the collateral regions). 
%
%         If the instance of the raDec2PixObject that is being executed is zero-based (as determined by the constructor
%         argument and the is_zero_based(raDec2PixObject) method) the center of the science pixel closest to the readout
%         node is (20.0, 12.0), and the center of the first pixel in accumulation memory is (0.0, 0.0).
%
%         If the instance of the raDec2PixObject that is being executed is one-based (as determined by the constructor
%         argument and the is_one_based(raDec2PixObject) method) the center of the science pixel closest to the readout
%         node is (21.0, 13.0), and the center of the first pixel in accumulation memory is (1.0, 1.0).
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

% This "shadow function" was requested by KSOC-1143 so that running "doc <function name>" would print out the above helptext, so users will not need to type "doc raDec2PixClass.<function name>".


function pixelWeight = assign_pixel_CR_probability( pixelRow, pixelCol, fcConstants )
%
% assign_pixel_CR_probability -- assign the relative probabilities of a CR hit to a set of
% pixels based on their location.
%
% pixelWeight = assign_pixel_CR_probability( pixelRow, pixelColumn, fcConstants ) takes a
%    list of pixel row and column values (zero-based) and an fcConstants data structure
%    and assigns pixel cosmic ray hit probabilities to the pixels.  This is necessary
%    because physical pixels can be hit at any time during integration or readout, but
%    virtual smear pixels can be hit only during readout, and leading or trailing black
%    pixels can be hit only during readout of the readout row.  
%
% Version date:  2008-November-21.
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

% hard-coded integration time and readout time:  these only need to be approximately
% correct for test purposes

  integrationTimeSeconds = 6.12 ;
  readoutTimeSeconds     = 0.52 ;
  exposureTimeSeconds = readoutTimeSeconds + integrationTimeSeconds ;
  
% extract the zero-based row and column boundaries of interest for ease of use

  leadingBlackStart  = fcConstants.LEADING_BLACK_START   ;
  leadingBlackEnd    = fcConstants.LEADING_BLACK_END     ;
  trailingBlackStart = fcConstants.TRAILING_BLACK_START  ;
  trailingBlackEnd   = fcConstants.TRAILING_BLACK_END    ;
  virtualSmearStart  = fcConstants.VIRTUAL_SMEAR_START   ;
  nRows              = fcConstants.VIRTUAL_SMEAR_END + 1 ;
  
% assign the pixelWeight vector initially to be ones

  pixelWeight = ones(size(pixelRow)) ;
  
% find the virtual smear pixels and assign them a relative probability given by the ratio
% of the readout time to the total exposure time of each exposure

  virtualSmearIndex = find( pixelRow >= virtualSmearStart & ...
                            pixelCol > leadingBlackEnd    & ...
                            pixelCol < trailingBlackStart ) ;
  pixelWeight(virtualSmearIndex) = readoutTimeSeconds / exposureTimeSeconds ;
  
% the leading and trailing black are even less likely to get hit, since they are only
% exposed during readout of the readout row

  leadingBlackIndex = find( pixelCol <= leadingBlackEnd ) ;
  pixelWeight(virtualSmearIndex) = readoutTimeSeconds / exposureTimeSeconds / nRows ;
  trailingBlackIndex = find( pixelCol >= trailingBlackStart ) ;
  pixelWeight(trailingBlackIndex) = readoutTimeSeconds / exposureTimeSeconds / nRows ;
  
return

% and that's it!

%
%
%

function quarterlyStitchingObject = fill_timestamps_for_gapped_cadences( ...
    quarterlyStitchingObject )
%
% fill_timestamps_for_gapped_cadences -- private method which fills in missing timestamps
% and cadence numbers for quarterlyStitchingClass
%
% quarterlyStitchingObject = fill_timestamps_for_gapped_cadences( quarterlyStitchingObject
% ) fills in cadence numbers and timestamps for cadences which are marked as gapped using
% linear interpolation.  It is a private method of the quarterlyStitchingClass and should
% be invoked only by the class constructor.
%
% Version date:  2010-September-10.
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

% locate the gapped and ungapped cadences

  cadenceTimes = quarterlyStitchingObject.cadenceTimes ;
  gappedCadences = find( cadenceTimes.gapIndicators ) ;
  ungappedCadences = find( ~cadenceTimes.gapIndicators ) ;
  
% perform linear interpolation of the ungapped timestamps and cadence #'s to the gapped
% ones

  cadenceTimes.startTimestamps(gappedCadences) = interp1( ungappedCadences, ...
      cadenceTimes.startTimestamps(ungappedCadences), gappedCadences, 'linear', 'extrap' ) ;
  cadenceTimes.midTimestamps(gappedCadences) = interp1( ungappedCadences, ...
      cadenceTimes.midTimestamps(ungappedCadences), gappedCadences, 'linear', 'extrap' ) ;
  cadenceTimes.endTimestamps(gappedCadences) = interp1( ungappedCadences, ...
      cadenceTimes.endTimestamps(ungappedCadences), gappedCadences, 'linear', 'extrap' ) ;
  cadenceTimes.cadenceNumbers(gappedCadences) = interp1( ungappedCadences, ...
      cadenceTimes.cadenceNumbers(ungappedCadences), gappedCadences, 'linear', 'extrap' ) ;
  
  quarterlyStitchingObject.cadenceTimes = cadenceTimes ;
  
return
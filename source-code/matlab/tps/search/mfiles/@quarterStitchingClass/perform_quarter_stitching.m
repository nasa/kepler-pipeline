function quarterStitchingObject = perform_quarter_stitching( quarterStitchingObject )
%
% perform_quarter_stitching -- concatenate and condition multi-quarter time series
%
% quarterStitchingObject = perform_quarter_stitching( quarterStitchingObject )
% concatenates and conditions multi-quarter time series.  The processing performed is as
% follows:
%
% ==> The individual quarters are median-subtracted, and optionally median-divided
%     depending on the value of the medianNormalizationFlag
% ==> The edges of each data segment are detrended
% ==> Harmonics are removed quarter-by-quarter and edge detrending is repeated
% ==> inter-quarter gaps are filled.
%
% Version date:  2011-May-26.
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
%    2011-May-26, PT:
%        remove first detrending (prior to harmonic removal).  
%    2010-October-22, PT:
%        add call to undo_median_normalization.
%
%=========================================================================================

% all this needs to do is perform the correct steps in the correct order, so:

  quarterStitchingObject = median_correct_time_series( quarterStitchingObject ) ;
  quarterStitchingObject = correct_attitude_tweak_discontinuities( quarterStitchingObject ) ;
  
  harmonicsStruct = quarterStitchingObject.harmonicsIdentificationParametersStruct ;
  nHarmonics      = harmonicsStruct.maxHarmonicComponents ;
  if nHarmonics > 0
      quarterStitchingObject = remove_phase_shifting_harmonics( quarterStitchingObject ) ;
  else
      disp(  [ '    Skipping harmonics removal ... ' ] ) ;
  end
  
  quarterStitchingObject = correct_attitude_tweak_discontinuities( quarterStitchingObject ) ;
  quarterStitchingObject = detrend_edges_of_data_blocks( quarterStitchingObject ) ;
  quarterStitchingObject = undo_median_normalization( quarterStitchingObject ) ;
  quarterStitchingObject = fill_gaps_in_time_series( quarterStitchingObject ) ;
    
return

% and that's it!

%
%
%

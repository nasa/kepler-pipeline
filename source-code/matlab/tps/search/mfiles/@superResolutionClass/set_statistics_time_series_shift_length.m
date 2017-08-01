function superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject)

% function superResolutionObject = set_statistics_time_series_shift_length( superResolutionObject)
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% Decription: Function that computes the shift length necessary for
% aligning the super res statistics time series.
% 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% check inputs
if isempty( superResolutionObject.pulseDurationInCadences )
    error( 'set_statistics_time_series_shift_length:noPulseDuration', ...
        'set_statistics_time_series_shift_length:  need pulseDuration in superResObject!' ) ;
end

superResolutionFactor = superResolutionObject.superResolutionFactor ;
pulseLength = superResolutionObject.pulseDurationInCadences ;
statisticsTimeSeriesShiftLength = zeros( superResolutionFactor, 1 ) ;
statisticsTimeSeriesShiftLength(1:superResolutionFactor) = fix( pulseLength/2 ) + 1;

%trialTransitPulseArray = superResolutionObject.trialTransitPulse ;
% for i=1:superResolutionFactor
%     trialTransitPulse = trialTransitPulseArray(:,i) ;
%     if isequal( abs(sum(trialTransitPulse(trialTransitPulse == -1))), pulseLength)
%          % this is the non super resolution pulse so just center it in the
%          % middle if the pulse has an odd number of cadences or to the right
%          % of middle if there is an even number of cadences
%          statisticsTimeSeriesShiftLength(i) = fix( pulseLength/2 ) + 1;
%      else
%          if (mod(pulseLength,2) == 0)
%              % for a super resolution pulse with an odd number of cadences
%              % just center it in the middle so it lines up with the non super
%              % resolution pulse
%              statisticsTimeSeriesShiftLength(i) = fix( pulseLength/2 ) + 1;
%          else
%              % for a super resolution pulse with an even number of cadences it
%              % should be shifed by one less to line up since the base pulse
%              % had an odd number of cadences
%              statisticsTimeSeriesShiftLength(i) = fix( pulseLength/2 ) + 1;
%          end
%      end
% end

superResolutionObject.statisticsTimeSeriesShiftLength = statisticsTimeSeriesShiftLength ;

% if we set a new shiftLength then zero out any existing super resolution
% time series
if ~isempty( superResolutionObject.correlationTimeSeriesHiRes )
    superResolutionObject.correlationTimeSeriesHiRes = [] ;
end
if ~isempty( superResolutionObject.normalizationTimeSeriesHiRes )
    superResolutionObject.normalizationTimeSeriesHiRes = [] ;
end

return
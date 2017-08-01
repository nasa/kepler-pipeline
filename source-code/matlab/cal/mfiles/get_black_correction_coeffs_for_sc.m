function [blackCorretionStructForSC] = ...
    get_black_correction_coeffs_for_sc(blackCorretionStructForLC, blackCorretionStructForSC, shortsPerLong)
% function [blackCorretionStructForSC] = get_black_correction_coeffs_for_sc(blackCorretionStructForLC, blackCorretionStructForSC, shortsPerLong)
%
% Interpolate fit coefficeints and convaiance of the 1D black fit at long
% cadence timestamps onto short cadence timestamps and rescale so when the
% model is evaluated the values are per SC instead of per LC. The interpolation
% method is set in this function, hard coded below (linear is the default).
% Coeffecients and covariance for any short cadence timestamps outside the
% range of long cadence tiemstamps provided are extrapolated using the
% 'nearest' method.  
%
% INPUT:   blackCorrectionStructForLC.timestamp: [nLongCadencesx1 double]
%                                    .gapIndicators: [nLongCadencesx1 logical]
%                                    .original: [nLongCadencesx1x6 double]
%                                    .originalCovariance: [nLongCadencesx1x6x6 double]
%                                    .smoothed: [nLongCadencesx1x6 double]
%                                    .smoothedCovariance: [nLongCadencesx1x6x6 double]
%
%          blackCorrectionStructForSC.timestamp: [nShortCadencesx1 double]
%                                    .gapIndicators: [nShortCadencesx1 logical]
%                                    .original: [nShortCadencesx1x6 double]
%                                    .originalCovariance: [nShortCadencesx1x6x6 double]
%                                    .smoothed: [nShortCadencesx1x6 double]
%                                    .smoothedCovariance: [nShortCadencesx1x6x6 double]
%
%                                     With valid data in the timestamp and gapIndicators fields.
%
%          shortsPerLong             number of short cadences per long cadence[scalar or nShortCadencesx1 double] 
%
% OUTPUT:  blackCorrectionStructForSC.timestamp: [nShortCadencesx1 double]
%                                    .gapIndicators: [nShortCadencesx1 logical]
%                                    .original: [nShortCadencesx1x6 double]
%                                    .originalCovariance: [nShortCadencesx1x6x6 double]
%                                    .smoothed: [nShortCadencesx1x6 double]
%                                    .smoothedCovariance: [nShortCadencesx1x6x6 double]
%
%                                    With original and smoothed fields updated with interpolated values.
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


% hard coded
interpolationMethod = 'linear';


% extract gap indicators and timestamps
validIndicesLC = ~blackCorretionStructForLC.gapIndicators;
lcTimestamps = blackCorretionStructForLC.timestamp(validIndicesLC);
validIndicesSC = ~blackCorretionStructForSC.gapIndicators;
scTimestamps = blackCorretionStructForSC.timestamp;

% adjust scTimestamps so any SC timestamps outside the LC timestamp
% range will effectively be interpolated using 'nearest'
minLcTime = min(lcTimestamps);
maxLcTime = max(lcTimestamps);
scBelowLcRange = scTimestamps < minLcTime;
scAboveLcRange = scTimestamps > maxLcTime;
scTimestamps(scBelowLcRange) = minLcTime;
scTimestamps(scAboveLcRange) = maxLcTime;

% extract stuff to be interpolated
originalCoeffs = blackCorretionStructForLC.original(validIndicesLC,:);
CoriginalCoeffs = blackCorretionStructForLC.originalCovariance(validIndicesLC,:,:);
smoothedCoeffs = blackCorretionStructForLC.smoothed(validIndicesLC,:);
CsmoothedCoeffs = blackCorretionStructForLC.smoothedCovariance(validIndicesLC,:,:);

% interpolate coefficients
blackCorretionStructForSC.original = interp1( lcTimestamps, originalCoeffs, scTimestamps, interpolationMethod);
blackCorretionStructForSC.smoothed = interp1( lcTimestamps, smoothedCoeffs, scTimestamps, interpolationMethod);

% interpolate covariance
blackCorretionStructForSC.originalCovariance = interp1(lcTimestamps, CoriginalCoeffs, scTimestamps, interpolationMethod);
blackCorretionStructForSC.smoothedCovariance = interp1(lcTimestamps, CsmoothedCoeffs, scTimestamps, interpolationMethod);

% rescale coeffs and covariance for SC
if( isscalar(shortsPerLong) )
    blackCorretionStructForSC.original = blackCorretionStructForSC.original./shortsPerLong;
    blackCorretionStructForSC.originalCovariance = blackCorretionStructForSC.originalCovariance./(shortsPerLong.^2);
    blackCorretionStructForSC.smoothed = blackCorretionStructForSC.smoothed./shortsPerLong;
    blackCorretionStructForSC.smoothedCovariance = blackCorretionStructForSC.smoothedCovariance./(shortsPerLong.^2);
else
    % can only rescale for SC valid indices where shortsPerLong should be non-zero
    [nCadences, nCoeffs] = size( blackCorretionStructForSC.original);    
    
    % use repmat to get matrix dimensions correct
    blackCorretionStructForSC.original(validIndicesSC,:) = ...
                blackCorretionStructForSC.original(validIndicesSC,:)./repmat(shortsPerLong(validIndicesSC),1,nCoeffs);
    blackCorretionStructForSC.smoothed(validIndicesSC,:) = ...
                blackCorretionStructForSC.smoothed(validIndicesSC,:)./repmat(shortsPerLong(validIndicesSC),1,nCoeffs);
    
    % can't avoid loop for 3D matrix
    for iCadence = 1:nCadences
        if( validIndicesSC(iCadence) )
            blackCorretionStructForSC.originalCovariance(iCadence,:,:) = ...
                        blackCorretionStructForSC.originalCovariance(iCadence,:,:)./(shortsPerLong(iCadence).^2);
            blackCorretionStructForSC.smoothedCovariance(iCadence,:,:) = ...
                        blackCorretionStructForSC.smoothedCovariance(iCadence,:,:)./(shortsPerLong(iCadence).^2);  
        end
    end

end

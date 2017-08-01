function [blackCorrectionStruct] = get_smoothed_black_coeffs(blackCorrectionStruct)
% function [blackCorrectionStruct] = get_smoothed_black_coeffs(blackCorrectionStruct)
%
% Smooth the original 1D black fit coefficients and covariance contained in blackCorrectionStructusing over cadences a median filter. The
% filter length is set to DEFAULT_FILTER_LENGTH (100) unless the number of cadences (nCadences) < 1.5 * DEFAULT_FILTER_LENGTH in which case
% the filter length is set to nCadence / 1.5. If nCadences <  ABSOLUTE_MIN_LENGTH (5) no smoothing of the coefficients or covariance is
% performed. The original coefficient and covariance data is returned in the smoothed coefficients and smoothed covariance fields.
%
% INPUT:    blackCorrectionStruct.timestamp: [150x1 double]
%                                .gapIndicators: [nCadencesx1 logical]
%                                .original: [nCadencesx1x6 double]
%                                .originalCovariance: [nCadencesx1x6x6 double]
%                                .smoothed: [nCadencesx1x6 double]
%                                .smoothedCovariance: [nCadencesx1x6x6 double]
%           With valid data in the timestamp, gapIndicators, original and
%           originalCovariance fileds
%
% OUTPUT:   blackCorrectionStruct.timestamp: [150x1 double]
%                                .gapIndicators: [nCadencesx1 logical]
%                                .original: [nCadencesx1x6 double]
%                                .originalCovariance: [nCadencesx1x6x6 double]
%                                .smoothed: [nCadencesx1x6 double]
%                                .smoothedCovariance: [nCadencesx1x6x6 double]
%           With  smoothed fields updated.
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


% KSOC-3773 - Add ABSOLUTE_MIN_LENGTH
% hard coded
DEFAULT_FILTER_LENGTH = 100;
ABSOLUTE_MIN_LENGTH = 5;


% extract coefficients and covariance
coefficients = blackCorrectionStruct.original;
covariance = blackCorrectionStruct.originalCovariance;
nCadences = size(coefficients,1);

% KSOC-3773 - Add support for data sets shorter than ABSOLUTE_MIN_LENGTH
if nCadences < ABSOLUTE_MIN_LENGTH
    
    % return original unsmoothed data for data set less than ABSOLUTE_FILTER_LENGTH
    blackCorrectionStruct.smoothed = coefficients;
    blackCorrectionStruct.smoothedCovariance = covariance;
    
else
    
    % KSOC-3773
    % adjust median filter length to be no more than 2/3 of data length
    medianFilterLength = max( [ ABSOLUTE_MIN_LENGTH, min([DEFAULT_FILTER_LENGTH, floor(nCadences / 1.5) ]) ]);

    % smooth coefficients
    paddedCoefficients = [coefficients(medianFilterLength:-1:1,:);...
                          coefficients;...
                          coefficients(end-(medianFilterLength-1):end,:)];

    filteredData = medfilt1_soc(paddedCoefficients,medianFilterLength);
    extractedData = filteredData(medianFilterLength+1:end-medianFilterLength,:);
    blackCorrectionStruct.smoothed = extractedData;

    % smooth covariance    
    paddedCovariance = [covariance(medianFilterLength:-1:1,:,:);...
                        covariance;...
                        covariance(end-(medianFilterLength-1):end,:,:)];

    filteredData = medfilt1_soc(paddedCovariance,medianFilterLength);
    extractedData = filteredData(medianFilterLength+1:end-medianFilterLength,:,:);
    blackCorrectionStruct.smoothedCovariance = extractedData;
end

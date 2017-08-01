%%  compute_thresholds 
% Calculates detection thresholds based on extreme value theory
% 
%   Revision History:
%
%       Version 0   - 3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%%
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
function thresholdStruct = compute_thresholds(obj, nCadencesFull, nCadencesNear, faslePositiveRate)
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |thresholdStruct     -| Threshold output structure
% * |.full      -| 'faslePositiveRate' Threshold for max. value of 'nCadencesFull' normally
% distributed samples 
% * |.fullMid  -| 50% Threshold for max. value of 'nCadencesFull' normally
% distributed samples 
% * |.near      -| 'faslePositiveRate' Threshold for max. value of 'nCadencesNear' normally
% distributed samples
% * |.nearMid  -| 50% Threshold for max. value of 'nCadencesNear' normally
% distributed samples
% * |.diff      -| 'faslePositiveRate' Threshold for sum of: 
%                        max. value of 'nCadencesFull' normally distributed samples +
%                        min. value of 'nCadencesNear' normally distributed samples
% * |.diffMid  -| 50% Threshold for sum of: 
%                        max. value of 'nCadencesFull' normally distributed samples +
%                        min. value of 'nCadencesNear' normally distributed samples
% Function Arguments:
%
% * |nCadencesFull      -|  Number of samples in full time series
% * |nCadencesNear      -|  Number of samples in time series window
% * |faslePositiveRate             -|  false positive rate for normally distributed samples
%
%% 2.0 CODE
%

% Anonymous function to calculate the probability distribution function for the sum
%                        max. value of 'nCadencesFull' normally distributed samples +
%                        min. value of 'nCadencesNear' normally distributed samples
f = @(z)sum(diff(1-cdf('norm',-10:.01:10,0,1).^nCadencesFull).*diff(1-cdf('norm',(-10:.01:10)-z,0,1).^(nCadencesNear-1)));

%% 2.1 FULL THRESHOLDS
%
% Cumulative distribution function (CDF) for max. value in a set of 'nCadencesFull' 
% standardized normally distributed samples
cdfFull       = (1-cdf('norm',0.01:0.01:7,0,1).^nCadencesFull);
% value where the probability of max. of samples having that value or greater is
% less than 'faslePositiveRate'
thresholdStruct.full     = find(cdfFull < faslePositiveRate,1,'first')*0.01;
% value where the probability of max. of sample having that value or greater is
% less than 50% (median expectation)
thresholdStruct.fullMid = find(cdfFull < 0.5,1,'first')*0.01;

%% 2.2 NEAR THRESHOLDS
%
% Cumulative distribution function (CDF) for max. value in a set of 'nCadencesNear' 
% standardized normally distributed samples
cdfNear       = (1-cdf('norm',0.01:0.01:7,0,1).^(nCadencesNear-1));
% value where the probability of max. of samples having that value or greater is
% less than 'faslePositiveRate'
thresholdStruct.near     = find(cdfNear < faslePositiveRate,1,'first')*0.01;
% value where the probability of max. of sample having that value or greater is
% less than 50% (median expectation)
thresholdStruct.nearMid = find(cdfNear < 0.5,1,'first')*0.01;

%% 2.2 COMBINED THRESHOLDS
%
% Probability distribution function (PDF) for sum of max. value in a set of 
% 'nCadencesNear' standardized normally distributed samples + max. value in a set of 'nCadencesNear' 
% standardized normally distributed samples
pdfDiff=zeros(1000,1);
for z1=1:1000
    pdfDiff(z1) = f(z1*.01-5); % calculate over range from -5 to 5
end
% Cumulative distribution function (CDF) for sum above
cdfDiff        = 1-cumsum(pdfDiff);
% value where the probability of sum having that value or greater is
% less than 'faslePositiveRate'
thresholdStruct.diff     = find(cdfDiff < faslePositiveRate,1,'first')*0.01-5;
% value where the probability of sum having that value or greater is
% less than 50% (median expectation)
thresholdStruct.diffMid = find(cdfDiff < 0.5,1,'first')*0.01-5;

%%
end


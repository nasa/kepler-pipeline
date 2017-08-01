function [meanData, stdData, inlierMask] = columnwise_robust_mean_std(data, inlierWeightThreshold)
% function [mean, std, inlierMask] = columnwise_robust_mean_std(data, inlierWeightThreshold)
% Robust estimation of mean and standard deviation
%
% This function is based on robust_mean_std but does *not* transpose the incoming data to be row major.
% INPUT:    data                    == 2D array; double
%           inlierWeightThreshold   == optional robust weight threshold. Outliers will have weight < inlierWeightThreshold
% OUTPUT:   meanData                == robust mean
%           stdData                 == robust standard deviation
%           inlierMask              == 2D array; logical
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

% Revision history;
% 6/4/2013 - Original rev. BC


% size up data
[nRows, nCols]  = size(data);
xVec            = (1:nRows)';

if ( nargin == 1 )
    % set default outlier threshold - full range is [0, 1.0]
    inlierWeightThreshold = 0.8;
end

% initialize
inlierMask      = false(nRows, nCols);

% turn off warning
warning('off', 'stats:statrobustfit:IterationLimit');

% operate on columns
for k = 1:nCols
    % call MATLAB robust fit for detection of outliers
    [~, stats]  = robustfit(xVec, data(:, k));

    % set mask
    inlierMask(:, k) = stats.w > inlierWeightThreshold;
end

% assemble output
inlierArray = data .* inlierMask;
inlierCount = sum(inlierMask, 1);
meanData    = sum( inlierArray, 1 ) ./ inlierCount;
stdData     = sqrt( sum( ( inlierArray - repmat(meanData, nRows, 1) .* inlierMask ).^2, 1 ) ./ ( inlierCount - 1) );


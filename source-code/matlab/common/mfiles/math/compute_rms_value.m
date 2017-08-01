function rmsValue = compute_rms_value( timeSeries, gapIndicators, doRobustCalculation )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function rmsValue = compute_rms_value(timeSeries, gapIndicators, doRobustCalculation)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Function that computes the rms of of an input time series either using
% means and standard deviations or else using medians and MAD equivalent
% standard deviations
%
% Inputs: timeSeries: a real-valued time series
%         gapIndicators: a logical vector the same size as timeSeries that
%             indicates which cadences to exclude from the calculation
%         doRobustCalculation: boolean that controls whether to perform the
%             robust version of the RMS calculation
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
if ~exist('gapIndicators', 'var') || isempty(gapIndicators)
    gapIndicators = false( nCadences, 1 );
end

if ~exist('timeSeries', 'var') || isempty(timeSeries(~gapIndicators)) || any(isinf(timeSeries(~gapIndicators))) ...
    || any(isnan(timeSeries(~gapIndicators)))
    error( 'common:compute_rms_values:badInputTimeSeries', ...
        'compute_rms_values: timeSeries must contain real values.' );
end

if ~isreal(timeSeries(~gapIndicators))
    warning( 'common:compute_rms_values:imaginaryInputTimeSeries', ...
        'compute_rms_values: timeSeries has imaginary values.' );
end

nCadences = length(timeSeries);

if exist('gapIndicators','var') && ~isempty(gapIndicators) && ...
        ~isequal(length(gapIndicators), nCadences)
    error('common:compute_rms_values:gapIndicatorsLength', ...
        'compute_rms_values: gapIndicators must be same length as timeSeries.' );
end

if exist('doRoubstCalculation','var') && ~isempty(doRobustCalculation)  && ...
        (~isequal(length(doRobustCalculation),1) || ~islogical(doRobustCalculation) )
    error('common:compute_rms_values:doRobustCalculation', ...
        'compute_rms_values: doRobustCalculation must be a single boolean.' );
end

% do robust calculation by default
if ~exist('doRobustCalculation','var') || isempty(doRobustCalculation) || ...
        ~islogical(doRobustCalculation)
    doRobustCalculation = true;
end

% get rid of gaps
timeSeries = timeSeries( ~gapIndicators );

% compute the RMS
if doRobustCalculation
    rmsValue = sqrt( median(timeSeries)^2 + (1.4826 * mad(timeSeries,1))^2 );
else
    rmsValue = sqrt( median(timeSeries)^2 + var(timeSeries) );
end

return

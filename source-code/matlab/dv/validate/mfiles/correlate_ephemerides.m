function correlation = correlate_ephemerides(period1,epoch1,duration1,period2,epoch2,duration2,kjdStart,kjdEnd)

%==========================================================================
% Compute a correlation function for pairs of objects, based on
% their transit parameters, in a specified time window
%==========================================================================
% Inputs: all inputs exist, with meaningful values
%   period1, period2 -- transit period in days
%   epoch1, epoch2   -- mid-transit time of first transit, in KJD system
%   duration1, duration2 -- transit duration in days
%   period1/epoch1/duration1 can be column vectors of the same length
%     (i.e. n1x1), describing an ordered set of transiting objects
%   period2/epoch2/duration2 can be column vectors of the same length,
%     (i.e. n2x1), describing a second ordered set of transiting objects
%   kjdStart -- start time of comparison window in KJD
%   kjdEnd -- end time of comparison window in KJD
%==========================================================================
% Outputs
%   correlation -- the dot product of the normalized transit indicators;
%   for each pair of transiting objects. If the input transit parameters
%   are column vectors, correlation is a matrix with dimension n1xn2.
%==========================================================================
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

% Lengths of transit parameter vectors
lp1 = length(period1);
le1 = length(epoch1);
ld1 = length(duration1);
lp2 = length(period2);
le2 = length(epoch2);
ld2 = length(duration2);

% Check that the input transit parameter vectors are of the same size
if(lp1==le1&&le1==ld1&&lp2==le2&&le2==ld2)
    
    % Construct transit indicator functions for the two objects
    indicatorSwitch = 'Y';
    
    % samplingIntervalDays is the unit of the transit sampling grid in
    % days; it should be much smaller than the transit duration
    samplingIntervalDays = 0.0033; % ~5 minutes
    ephem1 = make_ephemeris(period1,duration1,epoch1,kjdStart,kjdEnd,indicatorSwitch,samplingIntervalDays);
    ephem2 = make_ephemeris(period2,duration2,epoch2,kjdStart,kjdEnd,indicatorSwitch,samplingIntervalDays);
    
    % Normalize the transit indicator vectors to be correlated; make sure
    % not to produce NaN's in the event that there are no transits
    indicator1 = vertcat(ephem1.indicator);
    scale1 = 1./sqrt(sum(indicator1, 2));
    scale1(isinf(scale1) | isnan(scale1)) = 0;
    indicator1 = scalecol(scale1, indicator1);
    
    indicator2 = vertcat(ephem2.indicator);
    scale2 = 1./sqrt(sum(indicator2, 2));
    scale2(isinf(scale2) | isnan(scale2)) = 0;
    indicator2 = scalecol(scale2, indicator2);
    
    % The correlation is the dot product of the transit indicator
    % functions for the two objects
    correlation = indicator1 * indicator2';
else
    fprintf('Input error: Transit period, epoch and duration vectors must be of the same length!\n')
end

return
function [runTimeInHours,timePerPeriodInSeconds] = estimate_run_time( nCadences, nInjections, nPeriods, ...
    nDurations, minPeriodCutoffInDays, overheadPerInjectionInSeconds, ...
    overheadPerDurationInSeconds, overheadPerPeriodInSeconds, ...
    timeVsNumTransitsSlope, periodSamplingMethod)
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

% project the run time based on current results
% usage:
% runTimeInHours = estimate_run_time(69810,50,2,2,30,30,5,20.513,2.1233,'log')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step1: First use the run-time data to generate the best-fit line to the
% elapsedTime vs. nTransits
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% nTransits = 69810/48.939./injResults.injectedPeriodDays;
% [sortednTransits,sortIndex] = sort(nTransits);
% sortedTimes = injResults.elapsedTime(sortIndex);
% filteredTimes = medfilt1(sortedTimes,100);
% 
% % trim ends to remove the effect of the filter window
% filteredTimes=filteredTimes(sortednTransits>=3);
% sortednTransits = sortednTransits(sortednTransits>=3);
% sortednTransits = sortednTransits(1:end-55);
% filteredTimes=filteredTimes(1:end-55);
% 
% figure
% plot(sortednTransits,filteredTimes,'-o')

% the best-fit line here gives me:
% elapsedTime = 2.1233 * (nCadences/48.939) / PeriodInDays + 20.513

% so: overheadPerPeriodInSeconds = 20.513
%     timeVsNumTransitsSlope = 2.1233

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Step2: now for each injection there is some amount of overhead. By running
% several targets I have observed something like ~30s of overhead per
% injection and then about 5s of overhead per duration.  The elapsedTime
% captures the periodSearch time
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Step3: Now I have to use the periodSamplingMethod to generate the equation for
% computing the run time for the period search over the selected set of
% periods. 
%
% First, let the PDF for period sampling be constant in log Period.  The
% PDF is then constant with a value of 1/(log(T_max/T_min).  This random
% variable must be transformed to period space then to numTransits space.
% After doing the transformations, the new PDF is 
% 1/( numTransits * ln(T_max/T_min) )
% to get the elapsed time per period I then do the integral of:
% timeVsNumTransitsSlop * integral ( numTransits * PDF ) from nTransits min
% to nTransits max.  Note that this time does not include the overhead that
% the y-intercept gives so that is added in separately.
%
% The total time is given below.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cadencesPerDay = 48.939;
maxPeriodInDays = nCadences/cadencesPerDay/2;

totalOverheadInSeconds = nInjections * overheadPerInjectionInSeconds + ...
    nInjections * nDurations * overheadPerDurationInSeconds + ...
    nInjections * nDurations * nPeriods * overheadPerPeriodInSeconds ;


if strmatch(periodSamplingMethod,'log')
    timePerPeriodInSeconds = timeVsNumTransitsSlope * (nCadences/cadencesPerDay) * ...
        (1/minPeriodCutoffInDays - 1/maxPeriodInDays) / log(maxPeriodInDays/minPeriodCutoffInDays);
elseif strmatch( periodSamplingMethod, 'linear')
    timePerPeriodInSeconds = timeVsNumTransitsSlope * (nCadences/cadencesPerDay) * ...
        log(maxPeriodInDays/minPeriodCutoffInDays) / (maxPeriodInDays - minPeriodCutoffInDays);
else
    error('unknown period sampling method!\n');
end

runTimeInHours = totalOverheadInSeconds + nInjections * nDurations * nPeriods * timePerPeriodInSeconds;
runTimeInHours = runTimeInHours / 3600;

return
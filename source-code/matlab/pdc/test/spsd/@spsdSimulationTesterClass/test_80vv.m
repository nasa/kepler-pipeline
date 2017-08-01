function resultsAnalysis = test_80vv(obj, sensitivityDropsPpm)
% SOC 8.0 SPSD V&V simulation test.
%
% Script to test SPSD detection and correction performance by simulating
% and inserting SPSD events into "clean" 12th magnitude targets on a single
% channel.
%
% Assumes that the current workspace contains variables 'inputsStruct' and 
% 'spsdCorrectedFluxObject'. inputsStruct is assumed to contain a *clean*
% targetDataStruct (i.e., one without any SPSD events in its flux time
% series). MAP basis vectors are obtained from spsdCorrectedFluxObject. 
%
% If a variable named 'sensitivityDropsPpm' is present in the current
% workspace, a test case will be created and analyzed for each of the
% specified sensitivity drops (parts per million). Otherwise test cases are
% created with default sensitivity drops of 100, 500, 1000, 5000, 10000,
% and 20000 ppm. 
% 
% If a logical variable named 'RetainCorrectedFluxObj' is present in the
% current workspace, then it's value will determine whether the
% spsdCorrectedFluxClass object for each simulation run remains in the
% workspace (default=false).
%
% RESULTS
% -------
% The principle results are a decision matrix and a resultsAnalysis 
% structure for each test case along with a plot of hit and false alarm
% probabilities vs. drop size.
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

    RECOVERY_FRACTION = 0.4;  % The fraction of the sensitivity drop that is recovered. [0,1]
    TIME_CONST = 0.05;        % Time constant of the exponential recovery.

    %----------------------------------------------------------------------
    % Initialization
    %----------------------------------------------------------------------
    saveEventParams = obj.eventParams;
    
    % If sensitivityDropsPpm is in the workspace, use it. Otherwise set default
    % values.
    if ~exist('sensitivityDropsPpm', 'var')
        sensitivityDropsPpm = [100 500 1000 5000 10000 20000];
    end

    kepIds = [obj.cleanTargetDataStruct.keplerId];
    mags   = [obj.cleanTargetDataStruct.keplerMag];
    paramStruct = obj.get_default_event_param_struct();
    paramStruct.keplerIds = kepIds(mags >= 11.5 & mags <= 12.5); % Inject events in 12th magnitude stars ONLY.
    paramStruct.recoveryFraction = [RECOVERY_FRACTION,  RECOVERY_FRACTION];
    paramStruct.recoverySpeed    = [TIME_CONST,         TIME_CONST];

    pHit = zeros(size(sensitivityDropsPpm));
    pFA  = zeros(size(sensitivityDropsPpm));

    %----------------------------------------------------------------------
    % Perform test for each step size
    %----------------------------------------------------------------------
    for i = 1:length(sensitivityDropsPpm)        
        ppm = sensitivityDropsPpm(i);
        drop = ppm/1e6; % Convert to fractional sensitivity drop.

        paramStruct.dropSize = [drop drop];
        obj.set_event_params(paramStruct);
        resultsAnalysis(i) = obj.test();

        pHit(sensitivityDropsPpm == ppm) = resultsAnalysis(i).performance.Phit;
        pFA(sensitivityDropsPpm == ppm)  = resultsAnalysis(i).performance.Pfa;

    end

    resultsAnalysis.sensitivityDropsPpm = sensitivityDropsPpm;
    
    % Restore event parameters.
    obj.set_event_params(saveEventParams);
    
    %----------------------------------------------------------------------
    % Generate performance plot
    %----------------------------------------------------------------------
    pHit(1) = max(pHit(1), 0.000001); % Make non-zero for log plotting.
    fpRateLimit = obj.spsdParams.spsdDetectionConfigurationStruct.falsePositiveRateLimit;

    hold off
    loglog(sensitivityDropsPpm, pHit,'b*-');
    grid on
    hold on
    loglog(sensitivityDropsPpm, pFA, 'r*-');

    axis([1e2 2e4 1e-5 1]);
    title({'\bf\fontsize{12}Estimated hit and false alarm probabilities vs. sensitivity drop'; 'Mod.out 13.1'});
    xlabel('Sensitivity Drop (ppm)','fontsize',12);
    ylabel('Est. Probability','fontsize',12);
    line([sensitivityDropsPpm(1) sensitivityDropsPpm(end)],[fpRateLimit fpRateLimit],'LineStyle','--', 'Color', 'r', 'LineWidth', 1);
    legend('Simulation P(hit)', 'Simulation P(false alarm)', 'false alarm rate limit');

end
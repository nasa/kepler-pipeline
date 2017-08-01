% compare_window_function_vs_threshold
% compare window functions with different thresholds
%==========================================================================
% !!!!! Usage notes -- before running this on one of the Groups below,
% run get_transit_injection_diagnostics.m on each of the targets in that
% group at each threshold in thresholdRange
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

% Constants
cadencesPerDay = 48.9390982304706;
superResolutionFactor = 3;

% Get grouplabel
groupLabel = input('Group label: Group1, Group2, Group3, Group4, Group6, KSOC4886, KIC3114789, GroupA, GroupB, KSOC-4930, KSOC-4964-1, KSOC-4964-2, KSOC-4964-4: -- ','s');

% Specify threshold range
thresholdRange = cell(1,6);
thresholdRange{1} = -1;
thresholdRange{2} = 0;
thresholdRange{3} = 0.25;
thresholdRange{4} = 0.5;
thresholdRange{5} = 0.75;
thresholdRange{6} = 0.85;
thresholdRange{7} = 0.95;

% Specify Data directory
% diagnosticDir = strcat('/codesaver/work/transit_injection/diagnostics/',groupLabel,'/');

% Directories for injection data and diagnostics
[topDir, diagnosticDir] = get_top_dir(groupLabel)

% Load the injection output file
load(strcat(topDir,'tps-injection-struct.mat'));

% Specify radius and impactParameter limits for empirical window function
minPlanetRadius = 3;
maxImpactParameter = 0.3;

% get Unique keplerIds
keplerIdList = unique(tpsInjectionStruct.keplerId);
keplerIdList = keplerIdList(:)';


% Specify Target
% keplerId = input('KeplerId = ');

% Loop over targets
for keplerId = keplerIdList
    
    
    % Get empirical window function
    [binCenters, NNtce, NNall] = get_empirical_window_function(groupLabel,keplerId,minPlanetRadius,maxImpactParameter);
    
    % Window functions
    figure
    hold on
    grid on
    box on
    
    %==========================================================================
    % Plot window functions at selected thresholds
    
    % setup plot
    iPulse = 6; % pulse number 6 is 3 hours
    colors = 'bkmgbcy';
    markers = cell(7);
    markers{1} = '--';
    markers{2} = '-';
    markers{3} = '-';
    markers{4} = '-';
    markers{5} = '-';
    markers{6} = '-';
    markers{7} = '-';
    linewidths = [2, ones(1,6)];
    
    
    % Loop over thresholds
    skip = true;
    if(~skip)
        for iThreshold = 1:length(thresholdRange)
            
            % Get window function data for this threshold from diagnostics file
            diagnosticsFile = strcat(diagnosticDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(keplerId),'-threshold-',num2str(thresholdRange{iThreshold}),'.mat');
            load(diagnosticsFile);
            
            
            % Plot the data
            plot(tpsDiagnosticStruct(iPulse).periodsWindowFunction./cadencesPerDay./superResolutionFactor, ...
                tpsDiagnosticStruct(iPulse).windowFunction,strcat(colors(iThreshold),markers{iThreshold}),'LineWidth',linewidths(iThreshold))
            
            % Prepare for next diagnostic struct
            clear tpsDiagnosticStruct
        end
    end
    
    % threshold = 0.5
    iThreshold = 4;
    
    % Get window function data for this threshold from diagnostics file
    diagnosticsFile = strcat(diagnosticDir,'tps-diagnostic-struct-',groupLabel,'-KIC-',num2str(keplerId),'-threshold-0.5.mat');
    load(diagnosticsFile);
    
    
    % Plot the data
    plot(tpsDiagnosticStruct(iPulse).periodsWindowFunction./cadencesPerDay./superResolutionFactor, ...
        tpsDiagnosticStruct(iPulse).windowFunction,strcat(colors(iThreshold),markers{iThreshold}),'LineWidth',linewidths(iThreshold))
    
    % Plot empirical window function
    plot(binCenters,NNtce(1:end-1)./NNall(1:end-1),'r-','LineWidth',3);
    
    % Finish plot
    xlabel('Period [days]')
    ylabel('Numerical Window Function')
    title(['Window Function Comparison, KIC',num2str(keplerId)])
    % legend('original WF duty=1','thresh=0 duty=.90','thresh=.25 duty=.89','thresh=0.5 duty=.87','thresh=.75 duty=.85','thresh=.85 duty=.83','thresh=.95 duty=.80','Location','Best')
    % legend('duty=1','thresh=0 duty=.90','thresh=.25 duty=.89','thresh=0.5 duty=.87','thresh=.75 duty=.85','thresh=.85 duty=.83','thresh=.95 duty=.80',['Empirical,R>',num2str(minPlanetRadius),',b<',num2str(maxImpactParameter)],'Location','Best')
    legend('thresh=0.5','empirical','Location','Best')
    set(gca,'FontSize',12)
    set(findall(gcf,'type','text'),'FontSize',12)
    plotName = strcat(diagnosticDir,'windowFunctionComparisonKIC',num2str(keplerId));
    print('-dpng','-r150',plotName)
    
end




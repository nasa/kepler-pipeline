function plot_modout_mes_contribution_counts( tceStruct, targetIndicator, skyGroupToModOutStruct, ...
    nQuarters, nCadences, textOnPlotFlag, autoScaleFlag, scaleMin, scaleMax )

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function plot_modout_mes_contribution_counts( tceStruct, targetIndicator, skyGroupToModOutStruct, ...
%    nQuarters, nCadences, textOnPlotFlag, autoScaleFlag, scaleMin, scaleMax )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Decription: This function generates a plot of mes contribution counts by
%              modout by quarter.
% 
%
% Inputs:
%        tceStruct:  The usual tceStruct that TPS uses except that it needs
%            to be augmented to include a vector of skygroups whose length is
%            equal to that of the vector of Kepler ID's.  
%            targetIndicator:  A boolean indicator vector equal in length to
%            the tceStruct.keplerId vector that determines which targets get
%            used to make the plot.
%        skyGroupToModOutStruct:  A struct that contains 4 arrays:
%            ccdModule: [84xnQuarters] list of modules by skygroup by
%                       quarter
%            ccdOutput: [84xnQuarters] list of outputs by skygroup by
%                       quarter
%            modOut: [84xnQuarters] cell array which is the concatenation
%                    of the previous two arrays
%            skyGroup: [84,1] list of skygroups that are not necessarily in
%                    order but the order should match the order of the previous
%                    arrays.
%        nQuarters:  The number of quarters
%        nCadences:  The number of cadences in the UOW
%        textOnPlotFlag:  Flag that determines whether to print the counts
%            information on the plots
%        autoScaleFlag:  Flag to determine whether to autoscale.  If we are
%            not autoscaling then scaleMin and scaleMax must be specified
%        scaleMin/Max:  The min/max for plots when not autoscaling so they
%            are all on the same scale
%
% Outputs: Plot
%
% sample:
% plot_modout_mes_contribution_counts( tceStruct, indicator, skyGroupToModOut, 12, 51412, false, true )
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


% if autoScaleFlag is false but no limits are given, then set it to true
if (~autoScaleFlag && ...
        ( (~exist('scaleMin','var') || isempty(scaleMin)) || ...
        (~exist('scaleMax','var') || isempty(scaleMax)) ) )
    autoScaleFlag = true ;
end


% hard-code a list of quarter start/end cadences so we only consider
% contributions from intra-quarter data

quarterData = ...
    [[1,1639]; ...
    [1873,6214]; ...
    [6301,10669]; ...
    [10810,15206]; ...
    [15270,19902]; ...
    [19966,24362]; ...
    [24406,28779]; ...
    [29554,32831]; ...
    [33133,37900]; ...
    [37946,42517]; ...
    [42564,47316]; ...
    [47370,51412]; ...
    [51448,55867]; ...
    [55921,60676]; ...
    [60783,65561]; ...
    [66420,69810]; ...
    [69873,71427]];

cadenceQuarters = zeros(nCadences,1);
for i=1:nQuarters
    cadenceQuarters(quarterData(i,1):quarterData(i,2))=i;
end

nTargets = sum(targetIndicator);
targetIndex = find(targetIndicator);

figHandle = figure;
jFrame = get(figHandle,'JavaFrame') ;
pause(1);
set(jFrame,'Maximized',true);
pause(1);
hold on;

nRows = ceil(nQuarters/4);

for iQuarter=1:nQuarters
    modOutIndicator = zeros(84,1);
    for i=1:nTargets
        transitCadenceIndicators=false(nCadences,1);
        tceIndex = targetIndex(i);
        
        % determine which cadences contributed to the MES - just assume a
        % superResolutionFactor of 3
        transitCadences=ceil(tceStruct.indexOfSesAdded{tceIndex}/3);
        transitCadenceIndicators(transitCadences) = true;

        % figure out which mod outs contributed to the tce - note that the
        % function convert_to_module_output has the mod-out of Q0 for each
        % skygroup so I need to reference Q0
        skyGroup = tceStruct.skyGroup(tceIndex);
        skyGroupIndex = skyGroupToModOutStruct.skyGroup == skyGroup;
        contributingQuarters = cadenceQuarters(transitCadenceIndicators);
        
        % count only 1 contribution per quarter per target
        contributingQuarters = unique(contributingQuarters);
        contributingQuarters = contributingQuarters(contributingQuarters~=0);
        
        for j=1:length(contributingQuarters)
            % determine the conversion index
            if contributingQuarters(j)==iQuarter
                
                for k=1:84   
                    modOutIndex = 0;
                    if strcmp(skyGroupToModOutStruct.modOut{skyGroupIndex,contributingQuarters(j)},skyGroupToModOutStruct.modOut{k,4})
                        modOutIndex=skyGroupToModOutStruct.skyGroup(k);
                        break;
                    end
                    
                end
                modOutIndicator(modOutIndex) = modOutIndicator(modOutIndex) + 1;
            end
            
        end
        
    end
    
    titleStr = strcat('Q',num2str(iQuarter));
    if autoScaleFlag
        display_focal_plane_metric_subplot(modOutIndicator,textOnPlotFlag,nRows,4,iQuarter,titleStr);
        pause(1);
    else
        display_focal_plane_metric_subplot_scale(modOutIndicator,textOnPlotFlag,nRows,4,iQuarter,titleStr,scaleMin,scaleMax)
        pause(1);
    end
    
end



return
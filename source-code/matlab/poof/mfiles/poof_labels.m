function buttonFig_h = poof_labels(tadStruct, handle1_ax_h)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function buttonFig_h = poof_labels(tadStruct, handle1_ax_h)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% provides radio buttons for labeling the axes of handle1_ax_1 with 
% target labels and optimal apertures from  tadStruct
%
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

% get all possible labels in tadStruc
cnt =0;
targets = tadStruct.targets;
numTargets = length(targets);

for t = 1:numTargets
    
    if ~isempty(targets(t).labels) && isfield(targets(t), 'labels')
        
        numLabels = length(targets(t).labels);
        
        if numLabels ~= 0
            for iLabels = 1:numLabels
                tempLabel = char(targets(t).labels(iLabels));
                cnt = cnt+1;
                mylabels{cnt} = tempLabel; %#ok<AGROW>
            end
        end
        
    end
end

if exist('mylabels', 'var')
    uniqueLabels = unique(mylabels);
else
    uniqueLabels = '';
end

% get optimal apertures from tadStruct in the form a vector
% note that this will be 0-based due to plotting lines over an existing
% image that is 0-based
cnt =1 ;
for t =1:numTargets 
    numOffsets = length(targets(t).offsets);

    referenceRow = targets(t).referenceRow;
    referenceColumn = targets(t).referenceColumn;

    for p=1:numOffsets
        r = referenceRow + targets(t).offsets(p).row;
        c = referenceColumn + targets(t).offsets(p).column;
        optimalApertures(cnt, 1) = c; %#ok<AGROW>
        optimalApertures(cnt, 2) = r; %#ok<AGROW>
        cnt = cnt+1;
    end
end
optimalApertures = unique(optimalApertures, 'rows');


% set the radio button dimensions
radioButtonWidth = 150;
radioButtonHeight = 30;
firstColStart = 10;
secondColStart = 180;



% set the figure dimensions
figOffsetX = 900;
figOffsetY = 100;
figWidth = 350;
figHeight = (length(uniqueLabels)+2)*(radioButtonHeight+2);
figTopOffset = radioButtonHeight;
figureDim = [figOffsetX figOffsetY figWidth figHeight];



% create figure with handle and make invisible while being created
buttonFig_h =figure('units', 'pixels', 'position', figureDim,...
    'tag', 'labelsFigure', 'numbertitle', 'off', ...
    'name', 'Poof Labels & Optimal Apertures', 'visible', 'off');
% make automatically created axes invisible
set(gca, 'visible', 'off')



% create button for the optimal Aperture on the right hand side
optimalApRadioButton_h = uicontrol(buttonFig_h, 'style', 'radiobutton',...
    'string', 'OPTIMAL APERTURES', 'units', 'pixels', ...
    'position', [secondColStart, figHeight-1*(radioButtonHeight+2)-figTopOffset ...
        radioButtonWidth radioButtonHeight], 'callback', @optiAp_callback ,...
        'enable', 'off', 'tag', 'labelsForRadio'); %#ok<NASGU>

    
    
% create cell array with positions for each uniqueLabels
buttonPositionCell = cell(length(uniqueLabels),1);
for n = 1:length(uniqueLabels)
    buttonPositionCell{n} = [firstColStart ...
        figHeight-n*(radioButtonHeight+2)-figTopOffset ...
        radioButtonWidth radioButtonHeight];
end



% create handle names and callback functions for buttons
handleName = cell(length(uniqueLabels),1);
for n = 1:length(uniqueLabels)
    handleName{n} = [uniqueLabels{n} '_h'];
end



% create radio button with associated handles
string2 = 'uicontrol(buttonFig_h,''style'', ''radiobutton'', ''string'',''';
string4 = ''', ''units'', ''pixels'', ''position'',[';
string6 = '],''horizontalAlignment'', ''center'', ''callback'', @radioButton_callback,';
string7 = '''enable'', ''off'', ''tag'', ''labelsForRadio'')';


% use eval to create dynamic uicontrols
for n = 1:length(uniqueLabels)
    string3= uniqueLabels{n};
    string5 = num2str(buttonPositionCell{n});
    totalString =[string2 string3 string4 string5 string6 string7];
    eval(totalString)
end



% normalize all components so that resizing figure still looks good
list = allchild(buttonFig_h);
foundlist = findall(list, 'units', 'pixels');
for n = 1:length(foundlist)
    set(foundlist(n), 'units', 'normalized')
end



% make visible now that all components have been initialized
set(buttonFig_h, 'visible', 'on')

%--------------------------------------------------------------------------
% TWO CALLBACK FUNCTION BELOW

    function radioButton_callback(radioButton, evd) %#ok<DEFNU,INUSD>
        
        val = get(gco, 'value');
        label = get(gco, 'string');
        if val % pressed
            labeledTargets=false(length(targets),1);
            for i = 1:length(targets)
                if strfind(colvec(char(targets(i).labels)')',label)
                    labeledTargets(i,1)=true;
                end
            end
            colorLabel = uisetcolor;
            if colorLabel == 0
                set(gco, 'value', 0, 'foregroundcolor', 'k')
                return
            end
            set(gco, 'foregroundcolor' , colorLabel)
            label_h =line([targets(labeledTargets).referenceColumn],...
                [targets(labeledTargets).referenceRow], 'tag', ...
                label,'parent',handle1_ax_h);
            set(label_h,'linestyle','none','marker','o','color',...
                colorLabel,'markersize',8)
            
        else % depressed
            set(gco, 'foregroundcolor', 'k')
            list = allchild(handle1_ax_h);
            label_h = findall(list, 'tag', label);
            set(label_h, 'visible', 'off')
        end
        
    end



    function optiAp_callback(optimalApRadioButton_h , evd) %#ok<INUSD>
       
        val = get(gco, 'value');
        if val % pressed
            colorLabel = uisetcolor;
            if colorLabel == 0
                set(gco, 'value', 0, 'foregroundcolor', 'k')
                return
            end
            set(gco, 'foregroundcolor' , colorLabel)

            optiLine_h = line(optimalApertures(:,1),...
                optimalApertures(:,2), 'parent',handle1_ax_h, ...
                'linestyle','none','marker','.', ...
                'markersize', 20, 'tag', 'optimalAp', ...
                'color', colorLabel); %#ok<NASGU>
            
        else % depressed
            set(gco, 'foregroundcolor', 'k')
            list = allchild(handle1_ax_h);
            optiLine_h = findall(list, 'tag', 'optimalAp');

            set(optiLine_h, 'visible', 'off')
        end

    end

        
%--------------------------------------------------------------------------           
end % end of the main body





   





















  
function h = plot_aperture_sizes( targetStruct, maxApertureSize, colorVar, colorbarLabel, colorTickLabel)
%************************************************************************** 
% h = plot_aperture_sizes( targetStruct, maxApertureSize, colorVar, ...
%     colorbarLabel, colorTickLabel)
%**************************************************************************  
% Plot the sizes of the PA optimal aperture actually used for photometry
% against those (from TAD) in the PA input structures.
%
% INPUTS
%     targetStruct
%     maxApertureSize
%     colorVar
%     colorbarLabel
%     colorTickLabel
%
% OUTPUTS
%     h : A figure handle.
%
% USAGE EXAMPLES
%     >> targetArray = convert_cdpp_fov_struct_to_target_array( ...
%        paCoaClass.compile_FOV_statistics(0, dataPath) )
% 
% [~, usedApertureType] = ismember(targetStruct.chosenAperture, {'TAD', 'SNR', 'CDPP', 'Union','Haloed' });
%**************************************************************************  
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
    MARKER_SIZE = 50;

    if ~exist('maxApertureSize', 'var') || isempty(maxApertureSize)
       maxApertureSize = max( [max([targetStruct.pa2TadApertureSize]), max([targetStruct.usedApertureSize])]);
    end
    
    if ~exist('colorVar', 'var')
       colorVar = targetStruct.keplerMag;
    end
    
    if ~exist('colorbarLabel', 'var')
       colorbarLabel = 'Magnitude';
    end
    
    if ~exist('colorTickLabel', 'var')
       colorTickLabel = '';
    end
    
    nTargets = numel(targetStruct);
    
    pa2Tad = colvec([targetStruct.pa2TadApertureSize]) + rand(nTargets, 1) - 0.5;
    used   = colvec([targetStruct.usedApertureSize])   + rand(nTargets, 1) - 0.5;
    
    % PA2-TAD vs. Used OA
    h = figure;
    scatter(pa2Tad, used, MARKER_SIZE, colorVar, 'filled', 'marker', 'o');
    grid on
    line([0 maxApertureSize], [0, maxApertureSize], 'LineStyle', '--', 'color', 'k');
    title('Aperture Size Comparison: PA2-TAD vs. Used Aperture');
    xlabel('PA2 TAD Aperture Size (pixels)');
    ylabel('Used Aperture Size (pixels)');
    xlim([0 maxApertureSize]);
    ylim([0 maxApertureSize]);
    add_colorbar(colorbarLabel, colorTickLabel);
end

%**************************************************************************  
function add_colorbar(colorbarLabel, colorTickLabel)
    hcb = colorbar;
    yLabelHandle = get(hcb,'ylabel');
    set(yLabelHandle ,'String', colorbarLabel );
    if ~isempty(colorTickLabel)
        set(hcb,'YTickMode', 'manual');
        set(hcb,'YTickLabelMode', 'manual'); 
        set(hcb,'YLimMode', 'manual'); 
        set(hcb,'YMinorTick', 'off');
        
        yTickPoints = 1:1:numel(colorTickLabel);
        set(hcb,'YTick', yTickPoints');
        set(hcb,'YTickLabel', colorTickLabel);
    end
end


function Z = collect_dawg_background_metrics( pathName, channelList, quarter )
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

if ~exist('channelList', 'var')
    channelList = 1:84;
end

% If a quarter was not specified, passing an empty array to get_group_dir()
% will cause it to default to the earliest available quarter under
% 'pathName'.
if ~exist('quarter', 'var')
    quarter = [];
end

% PA filenames
PA_DAWG_BACKGROUND = 'pa-dawg-background.mat';
BACKROUND_FIELD_NAME = 'backgroundMetricsStruct';

% initialize storage
Z = ...
    repmat(struct('module',0,...
                    'output',0,...
                    'cadences',[],...
                    'gapIndicators',[],...
                    'meanFittedValue',[],...
                    'medianNormalizedResidual',[],...
                    'madNormalizedResidual',[],...
                    'extremeOutlierCount',[],...
                    'medianNormalizedPixelUncertainty',[],...
                    'madNormalizedPixelUncertainty',[],...
                    'runParameters',struct()),...
            length(channelList),1);

for iChannel = 1:length(channelList)
    
    channel = channelList(iChannel);
    
    channelPath = get_group_dir('PA', channel, ...
        'quarter', quarter, 'rootPath', pathName, 'fullPath', true);
    channelPath = channelPath{1};
    
    channelDir = get_group_dir('PA', channel, ...
        'quarter', quarter, 'rootPath', pathName, 'fullPath', false);
    channelDir = channelDir{1};

    if( ~isempty(channelDir) )
        disp([num2str(channel),'    --   Processing ', channelDir, '...']);
        filename = fullfile(channelPath, PA_DAWG_BACKGROUND);

        if( exist(filename, 'file') )
            s = load(filename);

            % populate output
            Z(iChannel).module                              = s.(BACKROUND_FIELD_NAME).module;
            Z(iChannel).output                              = s.(BACKROUND_FIELD_NAME).output;
            Z(iChannel).cadences                            = s.(BACKROUND_FIELD_NAME).cadences;
            Z(iChannel).gapIndicators                       = s.(BACKROUND_FIELD_NAME).gapIndicators;
            Z(iChannel).meanFittedValue                     = s.(BACKROUND_FIELD_NAME).meanFittedValue;
            Z(iChannel).medianNormalizedResidual            = s.(BACKROUND_FIELD_NAME).medianNormalizedResidual;
            Z(iChannel).madNormalizedResidual               = s.(BACKROUND_FIELD_NAME).madNormalizedResidual;
            Z(iChannel).extremeOutlierCount                 = s.(BACKROUND_FIELD_NAME).extremeOutlierCount;
            Z(iChannel).medianNormalizedPixelUncertainty    = s.(BACKROUND_FIELD_NAME).medianNormalizedPixelUncertainty;
            Z(iChannel).madNormalizedPixelUncertainty       = s.(BACKROUND_FIELD_NAME).madNormalizedPixelUncertainty;
            Z(iChannel).runParameters                       = s.(BACKROUND_FIELD_NAME).runParameters;
        else                    
            disp([filename,' not found.']);
        end
    end
end


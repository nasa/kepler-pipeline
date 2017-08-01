function M = batch_plot_pa_motion_vs_fit(varargin)
%**************************************************************************
% M = batch_plot_pa_motion_vs_fit(varargin)
%**************************************************************************
% INPUTS
%     All inputs are optional attribute/value pairs. Valid attribute and
%     values are:
%    
%     Attribute      Value
%     ---------      -----
%     'pathName'     The full path to the directory containing task
%                    directories for the pipeline instance. Note that this
%                    path must have a sub-direcory named 'uow' that
%                    contains symlinks to the other task direcories
%                    (default is the current working directory).
%     'channelList'  An array of channel numbers in the range [1:84]
%                    (default = [1:84]).
%     'quarter'      An optional quarter number in the range [0, 17]. If
%                    empty or unspecified, the earliest quarter processed
%                    by the pipeline instance is used (default = []).
%     'plotsOn'      A logical flag indicating (default = false).
%
% OUTPUTS
%     M              A struct array. 
%     |-.ccdModule
%     |-.ccdOutput
%     |-.rowCadences
%     |-.colCadences
%     |-.fittedRow
%     |-.fittedCol
%     |-.rowResidual
%      -.colResidual
%
% NOTES
%
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

    %----------------------------------------------------------------------
    % Parse and validate arguments.
    %----------------------------------------------------------------------
    parser = inputParser;
    parser.addParamValue('channelList', [1:84], @(x)isnumeric(x) &&  min(size(x)) == 1 && all(ismember(x, 1:84)) );
    parser.addParamValue('quarter',         [], @(x)isempty(x) || isnumeric(x) && x>=0 && x<=17 );
    parser.addParamValue('pathName',       '.', @(s)isdir(s)       );
    parser.addParamValue('plotsOn',      false, @(x)islogical(x)   );
    parser.parse(varargin{:});

    channelList = parser.Results.channelList;
    quarter     = parser.Results.quarter;
    pathName    = parser.Results.pathName;
    PLOTS_ON    = parser.Results.plotsOn;
    %----------------------------------------------------------------------
    
    paOutputDirMask = 'pa-*';

    M = struct('ccdModule',[],...
        'ccdOutput',[],...
        'rowCadences',[],...
        'colCadences',[],...
        'fittedRow',[],...
        'fittedCol',[],...
        'rowResidual',[],...
        'colResidual',[]);

    D = dir([pathName,paOutputDirMask]);

    counter = 0;

    for channel = rowvec(channelList)

        % find matching channel directories from map file
        channelDir = get_group_dir( 'PA', channel, ...
            'quarter', quarter, 'rootPath', pathName, 'fullPath', true); 

        if( ~isempty(channelDir) )
            channelMatch = strcmp({D.name}',channelDir);

            if( any(channelMatch) )
                % find directories that match channel
                channelIdx = find(channelMatch);
                disp(['-----   Processing channel ',num2str(channel),'...']);

                for idx = rowvec(channelIdx)

                    counter = counter + 1;

                    M(counter) = plot_pa_motion_vs_fit([pathName,D(channelIdx).name,filesep], PLOTS_ON);
                end
            end
        end
    end


end

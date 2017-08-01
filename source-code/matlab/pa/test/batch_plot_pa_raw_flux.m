function [F, S] = batch_plot_pa_raw_flux( varargin )
%**************************************************************************
% [F, S] = batch_plot_pa_raw_flux( varargin )
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
%     'waitTime'     A scalar specifying the length of the pause between
%                    plots if plotting is enabled (default = 0.01). 
%
% OUTPUTS
%     F              A nChannels-by-1 cell array (where nChannels is the
%                    length of the channelList array). MORE DOCUMENTATION
%                    REQUIRED!!
%
%     S              A struct array containing an element for each channel
%     |              processed.
%     |-.ccdModule
%     |-.ccdOutput
%     |-.taskFileDirectory
%     |-.nTargets
%     |-.negativeFluxIndex
%     |-.negativeFluxKeplerId
%     |-.negativeFluxKeplerMag
%     |-.negativeFluxOutputFile
%     |-.normalizedFlux
%     |-.uncertaintyOverShotNoise
%      -.uncertaintyOverStdDev
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
parser.addParamValue('quarter',         [], @(x)isempty(x) || isnumeric(x) && x>=0 && x<=17  );
parser.addParamValue('pathName',       '.', @(s)isdir(s)             );
parser.addParamValue('plotsOn',      false, @(x)islogical(x)         );
parser.addParamValue('waitTime',      0.01, @(x)isnumeric(x) && x>=0 );
parser.parse(varargin{:});

channelList = parser.Results.channelList;
quarter     = parser.Results.quarter;
pathName    = parser.Results.pathName;
PLOTS_ON    = parser.Results.plotsOn;
WAIT_TIME   = parser.Results.waitTime;
%----------------------------------------------------------------------


% P1 = [1156   180   715   920];
P2 = [ 625   850   560   250];
P3 = [ 625   515   560   250];
P4 = [ 625   185   560   250];


paOutputDirMask = 'pa-*';

% set up empty output structures
S = repmat(struct('ccdModule',[],...
                        'ccdOutput',[],...
                        'taskFileDirectory',[],...
                        'nTargets',[],...
                        'negativeFluxIndex',[],...
                        'negativeFluxKeplerId',[],...
                        'negativeFluxKeplerMag',[],...
                        'negativeFluxOutputFile',[],...
                        'normalizedFlux',[],...
                        'uncertaintyOverShotNoise',[],...
                        'uncertaintyOverStdDev',[]),...
                        length(channelList),1);
               
F = cell(length(channelList),1);

% compile list of output directories
D = dir([pathName,paOutputDirMask]);
D = D([D.isdir]);


counter = 0;

for channel = rowvec(channelList)

    % find matching channel directories from map file
    channelDir = get_group_dir('PA', channel, ...
        'quarter', quarter, 'rootPath', pathName);

    if( ~isempty(channelDir) )
        channelMatch = strcmp({D.name}',channelDir);

        if( any(channelMatch) )
            % find directories that match channel
            channelIdx = find(channelMatch);
            disp(['-----   Processing channel ',num2str(channel),'...']);

            for idx = rowvec(channelIdx)
                counter =counter + 1;
                [F{counter}, S(counter)] = plot_pa_raw_flux_all( [pathName,D(channelIdx).name], WAIT_TIME, PLOTS_ON );
            end                
        end
    end
end



% generate summary plots
summaryChannel = convert_from_module_output([S.ccdModule],[S.ccdOutput]);
S_normalizedFlux = [S.normalizedFlux];
S_unc_over_shot = [S.uncertaintyOverShotNoise];
S_unc_over_std = [S.uncertaintyOverStdDev];

nChannels = length(summaryChannel);

if(nChannels > 1)
    % median flux / expected flux
    h2= figure(2);
    set(h2,'Position',P2);
    subplot(4,1,1);
    plot(summaryChannel,[S_normalizedFlux.median],'o');
    grid;
    ylabel('\bf\fontsize{12}MEDIAN');
    title('\bf\fontsize{12}MEDIAN FLUX/EXPECTED FLUX DISTRIBUTION SUMMARY');

    subplot(4,1,2);
    plot(summaryChannel,[S_normalizedFlux.min],'o');
    grid;
    ylabel('\bf\fontsize{12}MIN');

    subplot(4,1,3);
    plot(summaryChannel,[S_normalizedFlux.max],'o');
    grid;
    ylabel('\bf\fontsize{12}MAX');

    subplot(4,1,4);
    plot(summaryChannel,[S_normalizedFlux.mad],'o');
    grid;
    ylabel('\bf\fontsize{12}MAD');
    xlabel('\bf\fontsize{12}channel');
    set(get(gcf,'Children'),'FontWeight','bold');
    set(get(gcf,'Children'),'FontSize',12);
    


    % median uncertainty / shot noise
    h3 = figure(3);
    set(h3,'Position',P3);
    subplot(4,1,1);
    plot(summaryChannel,[S_unc_over_shot.median],'o');
    grid;
    ylabel('\bf\fontsize{12}MEDIAN');
    title('\bf\fontsize{12}MEDIAN UNCERTAINTY/SHOT NOISE DISTRIBUTION SUMMARY');
    subplot(4,1,2);
    plot(summaryChannel,[S_unc_over_shot.min],'o');
    grid;
    ylabel('\bf\fontsize{12}MIN');
    subplot(4,1,3);
    plot(summaryChannel,[S_unc_over_shot.max],'o');
    grid;
    ylabel('\bf\fontsize{12}MAX');
    subplot(4,1,4);
    plot(summaryChannel,[S_unc_over_shot.mad],'o');
    grid;
    ylabel('\bf\fontsize{12}MAD');
    xlabel('\bf\fontsize{12}channel');
    set(get(gcf,'Children'),'FontWeight','bold');
    


    % median uncertainty / std dev
    h4 = figure(4);
    set(h4,'Position',P4);
    subplot(4,1,1);
    plot(summaryChannel,[S_unc_over_std.median],'o');
    grid;
    title('\bf\fontsize{12}MEDIAN UNCERTAINTY/STD DEV DISTRIBUTION SUMMARY');
    ylabel('\bf\fontsize{12}MEDIAN');
    subplot(4,1,2);
    plot(summaryChannel,[S_unc_over_std.min],'o');
    grid;
    ylabel('\bf\fontsize{12}MIN');
    subplot(4,1,3);
    plot(summaryChannel,[S_unc_over_std.max],'o');
    grid;
    ylabel('\bf\fontsize{12}MAX');
    subplot(4,1,4);
    plot(summaryChannel,[S_unc_over_std.mad],'o');
    grid;
    ylabel('\bf\fontsize{12}MAD');
    xlabel('\bf\fontsize{12}channel');
    set(get(gcf,'Children'),'FontWeight','bold');
    set(get(gcf,'Children'),'FontSize',12);
    
end



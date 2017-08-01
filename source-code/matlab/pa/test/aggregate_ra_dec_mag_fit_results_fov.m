function fovRaDecMagFitResults = ...
    aggregate_ra_dec_mag_fit_results_fov( paRootTaskDir, channelOrModout, quarter)
%**************************************************************************
% fovRaDecMagFitResults = ...
%     aggregate_ra_dec_mag_fit_results_fov( paRootTaskDir, channelOrModout)
%**************************************************************************  
% Aggregate raDecMagFitResults arrays from all state files under
% paRootTaskDir. 
%
% INPUTS
%     paRootTaskDir   : The full path to the directory containing task 
%                       directories for the pipeline instance (this is the
%                       directory containing the uow/ subdirectory). 
%     channelOrModout : An optional array of channels or Nx2 matrix of
%                       mod.outs to ba aggregated. If unspecified or empty,
%                       all channels are aggregated by default.
%     quarter         : An optional quarter specification for multi-quarter
%                       runs. If unspecified or empty, the earliest
%                       available quarter is processed.
%
% OUTPUTS
%     fovRaDecMagFitResults : An aggregated struct array containing PA-COA
%                       RA/Dec/Mag fitting resutls for the specified
%                       channels. 
% NOTES
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

    if ~exist('channelOrModout', 'var') || isempty(channelOrModout)
        channelOrModout = colvec(1:84);
    end
    
    if ~exist('quarter', 'var') || isempty(quarter)
        quarter = [];
    end
    
    fovRaDecMagFitResults = [];
    
    %----------------------------------------------------------------------
    % Get paths to results for each channel.
    %----------------------------------------------------------------------
    groupDirCellArray = get_group_dir( 'PA', channelOrModout, ...
            'rootPath', paRootTaskDir, 'quarter', quarter);
    isValidGroupDir = cellfun(@(x)~isempty(x), groupDirCellArray);
    if ~any(isValidGroupDir)
        return
    end
    
    groupDirCellArray = groupDirCellArray(isValidGroupDir);
    if size(channelOrModout, 2) == 2
        modouts  = channelOrModout(isValidGroupDir, :);
        channels = convert_from_module_output( ...
            channelOrModout(isValidGroupDir,1), channelOrModout(isValidGroupDir,2));
    else
        channels = channelOrModout(isValidGroupDir);
        [m, o]  = convert_to_module_output(channelOrModout(isValidGroupDir, :));
        modouts = [m,o];
    end

    %----------------------------------------------------------------------
    % Assemble RA, Dec, magnitude fitting results for all channels.
    %----------------------------------------------------------------------
    nChannels = length(channels); 
    for iChannel = 1:nChannels
        channelDir = groupDirCellArray{iChannel};
        
        fprintf('Loading channel %d of %d directory = %s ... \n', ...
            iChannel, nChannels, channelDir);
                        
        % Obtain 
        load( fullfile(channelDir, 'pa_state.mat'), 'raDecMagFitResults');
        if exist('raDecMagFitResults', 'var')
            module = modouts(iChannel, 1);
            output = modouts(iChannel, 2);
            
            [raDecMagFitResults.ccdModule] = deal(module);
            [raDecMagFitResults.ccdOutput] = deal(output);
            
            fovRaDecMagFitResults = [fovRaDecMagFitResults, raDecMagFitResults];
        end
        clear raDecMagFitResults
    end
    
end

%********************************** EOF ***********************************
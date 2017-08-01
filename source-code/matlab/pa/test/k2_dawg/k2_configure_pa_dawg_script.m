function configStruct = k2_configure_pa_dawg_script()
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
        
    % =====================================================================
    % User-defined parameters.
    % =====================================================================
    
    % The various analyses may be enabled/disabled with the following flags:
    configStruct.analysisFlags.evaluateBackgroundFits             = true; % Long cadence only.
    configStruct.analysisFlags. evaluateMotionFits                = true; % Long cadence only.
    configStruct.analysisFlags.evaluateReactionWheelZeroCrossings = true;
    configStruct.analysisFlags.evaluateFlux                       = true;
    configStruct.analysisFlags.evaluateCentroids                  = true;
    configStruct.analysisFlags.evaluateCosmicRays                 = true;
    configStruct.analysisFlags.evaluateArga                       = true;
    configStruct.analysisFlags.evaluatePaCoa                      = true;

    % Which campaign are we DAWGing?
    configStruct.campaign = 3;
    
    % Specify the set of channels to process, if they are available.
    channels = 1:84;
    
    % corresponding data type (labels for output directories). Must contain
    % either 'lc', 'sc', or both.
    configStruct.dataType = {'lc'};

    % Specify the task file directories. These are the top-level
    % directories containing a uow/ subdirectory.
    configStruct.lcRootTaskDir = '/path/to/lc/pa2';
    configStruct.scRootTaskDir = '/path/to/sc/pa';

    % Specify the root directory for V&V prep products.    
    configStruct.dawgPrepRoot = '/path/to/tmp';

    % Specify the directory containing copies of the spice files needed for raDec2Pix
    configStruct.spiceFileDirectory = '/path/to/data/spice';
        
    % Where to find the reference PDF for use on cosmic ray figures. This
    % can be checked out from:
    % svn+ssh://host/path/to/test-data/condPdfStruct.mat
    configStruct.cosmicRayPdf = '/path/to/condPdfStruct.mat';
    
    % Plotting centroids taks a long time - turn it off here to speed
    % things up.
    configStruct.plotCentroids = false;

    % =====================================================================
    % Derived parameters.
    % =====================================================================
    
    % Process only LC channels for which a group dir exists.
    if ~isempty(configStruct.lcRootTaskDir)
        groupDirs = get_group_dir('PA', colvec([1:84]), 'rootPath', configStruct.lcRootTaskDir);
        nonEmptyIndices = find(~cellfun(@isempty,groupDirs));
        configStruct.lcChannels = intersect(nonEmptyIndices, channels);
    else
        configStruct.lcChannels = [];
    end

    % Process only SC channels for which a group dir exists.
    if ~isempty(configStruct.scRootTaskDir)
        groupDirs = get_group_dir('PA', colvec([1:84]), 'rootPath', configStruct.scRootTaskDir);
        nonEmptyIndices = find(~cellfun(@isempty,groupDirs));
        configStruct.scChannels = intersect(nonEmptyIndices, channels);
    else
        configStruct.scChannels = [];
    end

    % path to task file directories. Note that we assume only one LC and
    % one SC directory.
    longCadenceIndex  = find(~cellfun(@isempty, strfind(lower(configStruct.dataType), 'lc')), 1);
    shortCadenceIndex = find(~cellfun(@isempty, strfind(lower(configStruct.dataType), 'sc')), 1);

    configStruct.pathName = {};
    if ~isempty(longCadenceIndex)
        configStruct.pathName{longCadenceIndex} = configStruct.lcRootTaskDir;
    end
    if ~isempty(shortCadenceIndex)
        configStruct.pathName{shortCadenceIndex} = configStruct.scRootTaskDir;
    end
            
    % Where to put the cosmic ray figures:
    configStruct.cosmicRayDestDir = fullfile(configStruct.dawgPrepRoot, ...
        'cosmic_ray', sprintf('c%d',configStruct.campaign));
end


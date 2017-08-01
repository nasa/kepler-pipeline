function dvResultsStruct = ...
    create_directories_for_dv_figures(dvDataObject, dvResultsStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dvResultsStruct = create_directories_for_dv_figures(dvDataObject)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Generates a tree of directories to place DV figures.
% Creates the directories in the current workspace.
% 
% When the directories are created for each target, 
% a dvFiguresRootDirectory string is placed in
% dvResultsStruct.targetResultsStruct(iTarget).
%
% This function should be called in data_validation.m before calls to
% the other tests
%
% The tree is arranged as follows:
%
%   target-012345678
%          summary-plots
%          planet-01
%               planet-search-and-model-fitting-results
%                       all-transits-fit
%                       even-transits-fit
%                       odd-transits-fit
%               centroid-test-results
%               binary-discrimination-test-results
% 
%   target-012345679
%          summary-plots
%          planet-01 ...
%
% If multiplePlanetSearch is enabled in DV, and additional planets are
% detected, then conduct_additional_planet_search.m will add additional
% planet-# directories as necessary.
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

targetStruct = dvDataObject.targetStruct;

for iTarget = 1 : length(targetStruct)

    % Make top-level target directory and directory for summary plots.
    dvFiguresRootDirectory = sprintf('target-%09d', targetStruct(iTarget).keplerId);

    % Suppress warnings if directory already exists.
    warning off all;
    mkdir(fullfile(dvFiguresRootDirectory, 'summary-plots'));
    warning on all;

    % Create subdirectories for each planet.
    for planetNumber = 1:length(dvResultsStruct.targetResultsStruct(iTarget).planetResultsStruct);
        create_per_planet_figure_directories(dvDataObject, dvFiguresRootDirectory, planetNumber);
    end
    
    % Return top-level directory.
    dvResultsStruct.targetResultsStruct(iTarget).dvFiguresRootDirectory = dvFiguresRootDirectory;

end

return

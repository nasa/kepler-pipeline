function generate_pdc_dawg_figures(rootTaskDir, dawgDir, modOutGroups)
%**************************************************************************
% generate_pdc_dawg_figures(rootTaskDir, dawgDir, modOutGroups)
%**************************************************************************
% Generate PA DAWG figures for K2. These are the diagnostic figures from
% sections 2.2 and 2.8 of the PDC validation tes plan.
%
% INPUTS
%     rootTaskDir  : The full path to the directory containing task 
%                    directories for the pipeline instance. This is the
%                    parent directory of the uow/ directory.
%     dawgDir      : The directory in which to place the results. If
%                    unspecified, results will be placed in the current
%                    working directory. 
%     modOutGroups : An nGroups-by-2 matrix, each row of which specifies a
%                    valid module output group. Valid groups are:
%
%                        2, 1
%                        6, 1
%                        9, 1
%                       10, 1
%                       12, 2
%                       12, 4
%                       13, 1
%                       22, 1
% OUTPUTS
%     (none)
%
% NOTES
%     Make sure that matlab/pdc/tools is on your Matlab path,
%     otherwise validate_crowding_metric_and_flux_fraction () will not be
%     found.
%
% USAGE
%     To generate figures for all groups of module outputs for C7 and place
%     them under /path/to/c7_dawg/pdc, issue the
%     following commands:
%
%     >> rootTaskDir = '/path/to/c7/pipeline_results/c7_archive_ksop-2553/lc';
%     >> dawgDir = '/path/to/c7_dawg/pdc';
%     >> generate_pdc_dawg_figures(rootTaskDir, dawgDir)
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

    originalWorkingDir = pwd;
    
    if ~exist('dawgDir', 'var')
        dawgDir = pwd;
    end
    
    if ~exist('modOutGroups', 'var')
        modOutGroups = [ ...
             2, 1; ...
             6, 1; ...
             9, 1; ...
            10, 1; ...
            12, 2; ...
            12, 4; ...
            13, 1; ...
            22, 1; ...
        ];
    end

    % Generate figures for each specified mod.out group.
    for iGroup = 1:size(modOutGroups, 1)
        taskDir = cell2mat(get_group_dir('PDC', [12 2], 'rootPath', rootTaskDir));
        groupSubdir = sprintf('group_%d.%d', modOutGroups(iGroup, 1), modOutGroups(iGroup, 2));

        % -----------------------------------------------------------------
        % Section 2.2
        % -----------------------------------------------------------------
        sectionSubdir = 'section_2.2';
        srcDir = fullfile(taskDir, 'map_plots', 'no_BS');
        destDir = fullfile(dawgDir,groupSubdir, sectionSubdir);
        if ~exist(destDir, 'dir')
            mkdir(destDir);
        end

        
        % -----------
        % Stellar variability figure.
        % -----------
        filename = 'stellar_variability_histogram.fig';
        openfig(fullfile(srcDir, filename))
        set(gcf,'color','white')
        saveas(gcf, fullfile(destDir, filename));
        close(gcf)

        % -----------
        % Singular values figure.
        % -----------
        filename = 'singular_values.fig';
        openfig(fullfile(srcDir, filename))
        
        set(gcf,'color','white')
        grid on
        xlabel('Singular Value Index')
        ylabel('Singular Value')

        saveas(gcf, fullfile(destDir, filename));
        close(gcf)

        % -----------
        % Basis vector figure.
        % Remove all but the first four basis vectors from the basis vector plot.
        % -----------
        filename = 'basis_vectors.fig';
        openfig(fullfile(srcDir, filename))
        
        children = get(gca,'children');
        delete(children(5:end));
        legend('1','2','3','4');
        title('First four of twelve basis vectors');
        set(gcf,'color','white')
        xlabel('Cadence')
        set(gcf, 'Position', [87 390 1081 378]);

        saveas(gcf, fullfile(destDir, filename));
        close(gcf)
        
        % ----------- Switch Source Directories ----
        srcDir = fullfile(taskDir, 'goodness_metric_plots');
        copyfile( fullfile(srcDir, 'correlation_histogram.fig'), destDir);
        copyfile( fullfile(srcDir, 'goodness_metric.fig'),       destDir);
        copyfile( fullfile(srcDir, 'goodness_percentiles.fig'),  destDir);

        % -----------
        % CDPP figure.
        % -----------
        filename = 'quasi-CDPP_vs_kepMag.fig';
        openfig(fullfile(srcDir, filename))
        
        set(gcf,'color','white')
        grid on
        a = findobj(get(gcf, 'Children'), 'Type', 'axes', '-not', 'Tag', 'legend');
        set(a, 'YScale', 'log');
        xlabel('KeplerMag')
        ylabel('quasi-CDPP (ppm)')
        
        saveas(gcf, fullfile(destDir, filename));
        close(gcf)

        % -----------------------------------------------------------------
        % Section 2.8
        % -----------------------------------------------------------------
        sectionSubdir = 'section_2.8';
        destDir = fullfile(dawgDir,groupSubdir, sectionSubdir);
        if ~exist(destDir, 'dir')
            mkdir(destDir);
        end
        
        cd(taskDir)
        validate_crowding_metric_and_flux_fraction()
        set(gcf,'color','white')
        cd(originalWorkingDir)
        
        saveas(gcf, fullfile(destDir, 'verify_crowding_and_flux_fraction.fig'));
        close(gcf)

    end

    cd(originalWorkingDir)
end



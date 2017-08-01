%% test_generate_figure_names
%
% function [self] = test_generate_figure_names(self)
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testDvFunctionsClass('test_generate_figure_names'));
%%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
function [self] = test_generate_figure_names(self)

initialize_soc_variables();

target = 6541920;
dvFiguresRootDirectory = fullfile(socTestDataRoot, ...
    'dv', 'unit-tests', 'report', sprintf('target-%09d', target));

% Test matrix columns are planet (0 for summary figure), directory,
% pattern, expected figure count, expected first figure name.
testCases = {
    1 'binary-discrimination-test-results' sprintf('%09d-01-eclipsing-binary-discrimination-tests.fig', target) 1 sprintf('%09d-01-eclipsing-binary-discrimination-tests.fig', target);
    1 'bootstrap-results' sprintf('%09d-01-bootstrap-false-alarm.fig', target) 1 sprintf('%09d-01-bootstrap-false-alarm.fig', target);
    1 'centroid-test-results' sprintf('%09d-01-folded-transit-fit-fluxWeighted-centroids.fig', target) 1 sprintf('%09d-01-folded-transit-fit-fluxWeighted-centroids.fig', target);
    1 'centroid-test-results' sprintf('%09d-01-transit-fit-fluxWeighted-centroids-*.fig', target) 6 sprintf('%09d-01-transit-fit-fluxWeighted-centroids-01.fig', target);
    1 'dashboard-plot' sprintf('%09d-01-dashboard-plot.fig', target) 1 sprintf('%09d-01-dashboard-plot.fig', target);
    1 'difference-image' '' 13 sprintf('%09d-01-candidate-model-light-curve.fig', target);
    1 'pixel-correlation-test-results' '' 6 sprintf('%09d-01-pixel-correlation-statistic-01-020.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-histo-all-and-unused.fig', target) 1 sprintf('%09d-01-all-histo-all-and-unused.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-histo-used.fig', target) 1 sprintf('%09d-01-all-histo-used.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-robust-weights.fig', target) 1 sprintf('%09d-01-all-robust-weights.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-unwhitened-*.fig', target) 4 sprintf('%09d-01-all-unwhitened-01-020.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-unwhitened-filtered-zoomed.fig', target) 1 sprintf('%09d-01-all-unwhitened-filtered-zoomed.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-unwhitened-zoomed.fig', target) 1 sprintf('%09d-01-all-unwhitened-zoomed.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-whitened.fig', target) 1 sprintf('%09d-01-all-whitened.fig', target);
    1 'planet-search-and-model-fitting-results/all-transits-fit' sprintf('%09d-01-all-whitened-zoomed.fig', target) 1 sprintf('%09d-01-all-whitened-zoomed.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-histo-all-and-unused.fig', target) 1 sprintf('%09d-01-odd-even-histo-all-and-unused.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-histo-used.fig', target) 1 sprintf('%09d-01-odd-even-histo-used.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-robust-weights.fig', target) 1 sprintf('%09d-01-odd-even-robust-weights.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-unwhitened-*.fig', target) 4 sprintf('%09d-01-odd-even-unwhitened-01-020.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-unwhitened-filtered-zoomed.fig', target) 1 sprintf('%09d-01-odd-even-unwhitened-filtered-zoomed.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-unwhitened-zoomed.fig', target) 1 sprintf('%09d-01-odd-even-unwhitened-zoomed.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-whitened.fig', target) 1 sprintf('%09d-01-odd-even-whitened.fig', target);
    1 'planet-search-and-model-fitting-results/odd-even-transits-fit' sprintf('%09d-01-odd-even-whitened-zoomed.fig', target) 1 sprintf('%09d-01-odd-even-whitened-zoomed.fig', target);
    0 'summary-plots' sprintf('%09d-00-flux-with-harmonics-dv-fit-*.fig', target) 2 sprintf('%09d-00-flux-with-harmonics-dv-fit-01-020.fig', target);
    0 'summary-plots' sprintf('%09d-00-flux-with-harmonics-tps-*.fig', target) 2 sprintf('%09d-00-flux-with-harmonics-tps-01-020.fig', target);
    0 'summary-plots' sprintf('%09d-00-fluxWeighted-centroids-cloud.fig', target) 1 sprintf('%09d-00-fluxWeighted-centroids-cloud.fig', target);
    0 'summary-plots' sprintf('%09d-00-raw-flux-*.fig', target) 2 sprintf('%09d-00-raw-flux-01-020.fig', target);
    0 'summary-plots' sprintf('%09d-00-residual-ses-*.fig', target) 8 sprintf('%09d-00-residual-ses-015-025.fig', target);
    };

% Test the function. Safely. So we can restore the working directory
% later.
for i = 1 : size(testCases, 1)
    testData = testCases(i,:);
    planet = testData{1};
    directory = testData{2};
    pattern = testData{3};
    expectedCount = testData{4};
    expectedFilename = testData{5};
    
    planetString = sprintf('planet-%02d', planet);
    if (planet == 0)
        planetString = '';
    end
    
    if (isempty(pattern))
        result = generate_figure_names(dvFiguresRootDirectory, planet, directory);
    else
        result = generate_figure_names(dvFiguresRootDirectory, planet, directory, pattern);
    end
    assert_equals(expectedCount, length(result), ...
        sprintf('Expected %d, but was %d for %s', expectedCount, length(result), expectedFilename));
    assert_equals(fullfile(dvFiguresRootDirectory, planetString, ...
        directory, expectedFilename), result{1});
end

end

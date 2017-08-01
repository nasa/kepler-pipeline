%% test_generate_fitter_results_table
%
% function [self] = test_generate_fitter_results_table(self)
%
%  Example
%  =======
%  Use a test runner to run the test method:
%      run(text_test_runner, testDvFunctionsClass('test_generate_fitter_results_table'));
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
function [self] = test_generate_fitter_results_table(self)

initialize_soc_variables();

reportTestDataDir = fullfile(socTestDataRoot, 'dv', 'unit-tests', 'report');

fprintf('\nLoading reportInputs-003001885 (fitter failed, sky group 80)\n');
load(fullfile(reportTestDataDir, 'reportInputs-003001885'));
expected = {
    'Model Chi Square' '5943' '' '';
    'Degrees of Freedom' '7075' '' '';
    'Transit Epoch' '135.3540124' '5.2540e-01' 'BKJD';
    'Eccentricity' '0.0000' '0.0000e+00' '';
    'Peri Longitude' '0.0000' '0.0000e+00' 'degrees';
    'Planet Radius' '33.2225' '2.6299e+04' 'Earth radii';
    'Planet Radius to Star Radius Ratio' '0.3663662' '2.9002e+02' '';
    'Semi-major Axis' '0.0039' '6.8645e-01' 'AU';
    'Semi-major Axis to Star Radius Ratio' '1.0002' '1.7755e+02' '';
    'Impact Parameter' '0.9997' '1.8410e+02' '';
    'Star Radius' '0.8310' '0.0000e+00' 'solar radii';
    'Transit Duration' '18.9341' '1.2769e+03' 'hours';
    'Transit Ingress Time' '321.1063' '1.0824e+08' 'hours';
    'Transit Depth' '106' '1.3996e+06' 'ppm';
    'Orbital Period' '2.6615553' '4.3705e-03' 'days';
    };
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'all', expected);
expected = {
    'Model Chi Square' '5384' '' '5384' '' '' '';
    'Degrees of Freedom' '6395' '' '6395' '' '' '';
    'Transit Epoch' '135.3151547' '2.1497e-02' '138.0667411' '2.4182e-02' '2.7826e+00' 'BKJD';
    'Eccentricity' '0.0000' '0.0000e+00' '0.0000' '0.0000e+00' '' '';
    'Peri Longitude' '0.0000' '0.0000e+00' '0.0000' '0.0000e+00' '' 'degrees';
    'Planet Radius' '31.5676' '3.1001e+07' '24.2625' '9.3156e+06' '2.2568e-07' 'Earth radii';
    'Planet Radius to Star Radius Ratio' '0.3481172' '3.4186e+05' '0.2675588' '1.0273e+05' '2.2568e-07' '';
    'Semi-major Axis' '0.0039' '8.5320e+01' '0.0039' '4.8336e+01' '5.5171e-10' 'AU';
    'Semi-major Axis to Star Radius Ratio' '1.0003' '2.2069e+04' '1.0003' '1.2502e+04' '5.5171e-10' '';
    'Impact Parameter' '0.9996' '2.3459e+04' '0.9997' '1.3166e+04' '1.1642e-09' '';
    'Star Radius' '0.8310' '0.0000e+00' '0.8310' '0.0000e+00' '' 'solar radii';
    'Transit Duration' '18.3843' '9.4233e+06' '15.8354' '2.8538e+06' '2.5888e-07' 'hours';
    'Transit Ingress Time' '258.6115' '8.2531e+09' '207.5772' '4.0082e+09' '5.5624e-09' 'hours';
    'Transit Depth' '143' '1.4244e+08' '98' '6.1199e+07' '2.9379e-07' 'ppm';
    'Orbital Period' '2.6612812' '3.2651e-04' '2.6604407' '3.5598e-04' '1.7399e+00' 'days';
    };
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'oddEven', expected);

fprintf('\nLoading reportInputs-003858884 (eclipsing binary, sky group 80)\n');
load(fullfile(reportTestDataDir, 'reportInputs-003858884'));
expected = {
    'Transit Epoch' '154.9074658' 'BKJD';
    'Transit Duration' '18.6354' 'hours';
    'Transit Depth' '410405' 'ppm';
    'Orbital Period' '25.9506720' 'days';
    };
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'all', expected);
expected = {
    'Transit Epoch' '154.9074658' '180.8581378' '25.9507' 'BKJD';
    'Transit Duration' '18.6354' '18.6354' '0.0000' 'hours';
    'Transit Depth' '410178' '410722' '543.9740' 'ppm';
    'Orbital Period' '25.9506720' '25.9506720' '0.0000' 'days';
    };
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'oddEven', expected);

fprintf('\nLoading reportInputs-003656322 (MES to SES ratio below threshold, sky group 80)\n');
load(fullfile(reportTestDataDir, 'reportInputs-003656322'));
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'all', cell(0));
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'oddEven', cell(0));

fprintf('\nLoading reportInputs-006541920 (6 planets, Kepler 11, KOI157, sky group 73)\n');
load(fullfile(reportTestDataDir, 'reportInputs-006541920'));
expected = {
    'Model Chi Square' '323' '' '';
    'Degrees of Freedom' '322' '' '';
    'Transit Epoch' '154.1620429' '1.0266e-03' 'BKJD';
    'Eccentricity' '0.0000' '0.0000e+00' '';
    'Peri Longitude' '0.0000' '0.0000e+00' 'degrees';
    'Planet Radius' '3.7683' '2.4000e+00' 'Earth radii';
    'Planet Radius to Star Radius Ratio' '0.0346023' '2.2037e-02' '';
    'Semi-major Axis' '0.2613' '4.8792e-01' 'AU';
    'Semi-major Axis to Star Radius Ratio' '56.2837' '1.0509e+02' '';
    'Impact Parameter' '0.4425' '3.3781e+00' '';
    'Star Radius' '0.9980' '0.0000e+00' 'solar radii';
    'Transit Duration' '4.0614' '7.5000e-01' 'hours';
    'Transit Ingress Time' '0.1676' '7.3098e-01' 'hours';
    'Transit Depth' '1395' '2.3257e+02' 'ppm';
    'Orbital Period' '31.9953713' '1.5514e-04' 'days';
    };
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'all', expected);
expected = {
    'Model Chi Square' '309' '' '309' '' '' '';
    'Degrees of Freedom' '320' '' '320' '' '' '';
    'Transit Epoch' '154.1639207' '1.2408e-03' '186.1527299' '1.8777e-03' '2.9157e+00' 'BKJD';
    'Eccentricity' '0.0000' '0.0000e+00' '0.0000' '0.0000e+00' '' '';
    'Peri Longitude' '0.0000' '0.0000e+00' '0.0000' '0.0000e+00' '' 'degrees';
    'Planet Radius' '3.7391' '4.5497e+00' '3.7513' '3.5416e+00' '2.1260e-03' 'Earth radii';
    'Planet Radius to Star Radius Ratio' '0.0343336' '4.1777e-02' '0.0344461' '3.2520e-02' '2.1260e-03' '';
    'Semi-major Axis' '0.2536' '9.0620e-01' '0.2679' '7.4111e-01' '1.2207e-02' 'AU';
    'Semi-major Axis to Star Radius Ratio' '54.6230' '1.9517e+02' '57.7008' '1.5962e+02' '1.2207e-02' '';
    'Impact Parameter' '0.4395' '6.5403e+00' '0.4442' '4.9761e+00' '5.7696e-04' '';
    'Star Radius' '0.9980' '0.0000e+00' '0.9980' '0.0000e+00' '' 'solar radii';
    'Transit Duration' '4.1899' '1.4433e+00' '3.9575' '1.0800e+00' '1.2889e-01' 'hours';
    'Transit Ingress Time' '0.1710' '1.4285e+00' '0.1629' '1.0528e+00' '4.6007e-03' 'hours';
    'Transit Depth' '1375' '5.1187e+02' '1382' '3.5185e+02' '1.0990e-02' 'ppm';
    'Orbital Period' '31.9950699' '8.3644e-05' '31.9960051' '2.9045e-04' '3.0938e+00' 'days';
    };
test(dvResultsStruct.targetResultsStruct(1).planetResultsStruct(1), 'oddEven', expected);

end

function test(planetResultsStruct, fitType, expectedResults)

fprintf('Testing Kepler ID %d, fit type %s\n', ...
    planetResultsStruct.keplerId, fitType);

results = generate_fitter_results_table(planetResultsStruct, fitType);
compare_arrays(expectedResults, results);

end

function compare_arrays(expected, actual)

assert_equals(size(expected), size(actual));

for m = 1 : size(expected, 1)
    for n = 1 : size(expected, 2)
        assert_equals(expected{m,n}, actual{m,n}, ...
            sprintf('Expected <%s> but was <%s> at %d, %d', ...
            expected{m,n}, actual{m,n}, m, n));
    end
end

end

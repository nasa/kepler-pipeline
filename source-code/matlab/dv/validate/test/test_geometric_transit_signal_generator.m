function test_geometric_transit_signal_generator(matlabRevision)
%
% function to test the DV v7.0 "geometric" transit model algorithms
%
%
%
% Modification History:
%
% 2010-Oct-14 EQ
%
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


if nargin == 0
    matlabRevision = '2010b';
end













% set test data directory
initialize_soc_variables;

testDataDir = [socTestDataRoot, filesep, 'dv', filesep, 'unit-tests', filesep, ...
    'transitGeneratorClass'] ;
clear soc*


%--------------------------------------------------------------------------
% test large planet signal generator
%--------------------------------------------------------------------------
disp('... testing large planet transit signal generator ... ')

% load the transit model struct
load(fullfile(testDataDir, 'transit-geometric-large-planet-test.mat')) ;

transitModelObject = transitGeneratorClass(transitModelStruct);

tic
[transitModelLightCurve, cadenceTimes]  = ...
    generate_planet_model_light_curve(transitModelObject);
elapsedTime = toc;

display(['Elapsed time: ' elapsedTime])



%---------------------------------------------------------------------
% plot the light curve
%---------------------------------------------------------------------
close all;
figure;

computedDepthPpm = max(abs(transitModelLightCurve))*1e6;

planetModel = get(transitModelObject, 'planetModel');
orbitalPeriodDays = planetModel.orbitalPeriodDays;
transitEpochBkjd  = planetModel.transitEpochBkjd;

plot((cadenceTimes-transitEpochBkjd), transitModelLightCurve+1, 'm.-')
xlabel('t - epoch (BKJD)')
ylabel('Flux relative to unobscured star')


title(['Light curve, depth = ' num2str(computedDepthPpm, '%6.1f') ' ppm  [MATLAB v' matlabRevision ']']);
grid on


%---------------------------------------------------------------------
% plot the folded light curve
%---------------------------------------------------------------------
figure;

plot(mod(cadenceTimes, orbitalPeriodDays), transitModelLightCurve+1, 'b.-')
xlabel('Folded period (days)')
ylabel('Flux relative to unobscured star')


title(['Folded light curve, depth = ' num2str(computedDepthPpm, '%6.1f') ' ppm  [MATLAB v' matlabRevision ']']);
grid on






return;



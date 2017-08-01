%==========================================================================
% function [ x_min ] = optimize_parameters( x0 )
%==========================================================================
%
% Inputs:
%     x0 : A vector of initial values:
%              x(1) : discontinuityRatioTolerance
%              x(2) : falsePositiveRateLimit
%              x(3) : transitSpsdMinmaxDiscriminator
%              x(4) : validationSignificanceThreshold
%
%
% Outputs:
%     x_min : The minimizing vector.
%
% NOTE that this function performs optimization without using MAP basis
% vectors. 
%==========================================================================
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
function [ x_min ] = optimize_parameters( x0 )

    if nargin < 1
        x0 = [ 0.7;   ... % discontinuityRatioTolerance
               0.001; ... % falsePositiveRateLimit
               0.7;   ... % transitSpsdMinmaxDiscriminator
               3      ... % validationSignificanceThreshold
             ];
    end

    options = optimset('Display','iter','MaxFunEvals', 100,'MaxIter', 100);

    x_min = fminsearch(@estimate_cost, x0, options);

end

%**
% Use simulations to estimate the expected cost, given parameters x.
%
% x(1) : discontinuityRatioTolerance
% x(2) : falsePositiveRateLimit
% x(3) : transitSpsdMinmaxDiscriminator
% x(4) : validationSignificanceThreshold
%
function C = estimate_cost(x)
    MIN_DROP_SIZE = 0.001;
    MAX_DROP_SIZE = 0.02;
    MIN_RECOVERY_SPEED = 0;
    MAX_RECOVERY_SPEED = 0.5;

    C00 = 0.0; % Cost of a correct negative decision.
    C01 = 0.5; % Cost of a miss
    C10 = 2.0; % Cost of a false alarm
    C11 = 0.0; % Cost of a hit

    persistent pdcInputStruct;
    persistent params;

    if isempty(pdcInputStruct)
        load /path/to/matlab/pdc/mfiles/spsd/test/clean_pid2817_input.mat
        pdcInputStruct = inputsStruct;

        params = create_default_param_struct(inputsStruct.targetDataStruct);
        params.nEvents = 1000;
        params.dropSize = [ MIN_DROP_SIZE MAX_DROP_SIZE ];
        params.recoverySpeed = [MIN_RECOVERY_SPEED MAX_RECOVERY_SPEED];
    end

    pdcInputStruct.spsdDetectionConfigurationStruct.discontinuityRatioTolerance     = x(1);
    pdcInputStruct.spsdDetectionConfigurationStruct.falsePositiveRateLimit          = x(2);
    pdcInputStruct.spsdDetectionConfigurationStruct.transitSpsdMinmaxDiscriminator  = x(3);
    pdcInputStruct.spsdDetectionConfigurationStruct.validationSignificanceThreshold = x(4);

    results = spsd_simulation_test(pdcInputStruct, params);

    P11 = results.performance.Phit;
    P01 = 1.0 - P11;
    P10 = results.performance.Pfa;
    P00 = 1.0 - P10;

    C = P00*C00 + P10*C10 + P01*C01 + P11*C11;

    fprintf(['Parameters:\n\tdiscontinuityRatioTolerance = %f\n', ...
             '\tfalsePositiveRateLimit = %f\n', ...
             '\ttransitSpsdMinmaxDiscriminator = %f\n', ...
             '\tvalidationSignificanceThreshold = %f\n'] ...
             ,x(1), x(2), x(3), x(4));
    fprintf('Cost = %f\n', C);

    results.performance

end
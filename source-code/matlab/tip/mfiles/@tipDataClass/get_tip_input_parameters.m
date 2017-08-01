function os = get_tip_input_parameters( tipDataObject )
%
% function os = get_tip_input_parameters( tipDataObject )
% 
% This tipDataClass method retrieves the input parameters necessary to generate transit models contained in the TIP output file. These
% input parameters are members of one of the following sets as determined by the module parameter generatingParamSetName:
%   sesDurationParamSet     == {'keplerId','inputSES','inputDurations','impactParameters','inputPhase','offsetArcSec','offsetPhase'}
%   periodRPlanetParamSet   == {'keplerId','planetRadius','orbitalPeriodDays','impactParameters','inputPhase','offsetArcSec','offsetPhase'}
% 
% Here are the units and limits for these things:
%   keplerId                N/A
%   inputSES                dimensionless? sigma? Whatever units are used in the Kepler pipeline            >= 0
%   inputDurations          hours                                                                           >= 0
%   planetRadius            Earth radii                                                                     >= 0
%   orbitalPeriodDays       days                                                                            >= 0
%   impactParameters        dimensionless                                                                   >= 0, <= 1
%   inputPhase              dimensionless                                                                   >= 0, <= 1
%   offsetArcSec            arc seconds                                                                     >= 0, < 10
%   offsetPhase             radians                                                                         >= -pi, <= pi
%
% If the module parameter enableRandomParamGen = true, for each keplerId in the tipDataObject the remaining parameters in the generating param
% set are drawn from uniform random distributions. The seed of the random stream is initialized either using the system clock or by a
% skygroup dependent module parameter randomSeedBySkygroup if randomSeedFromClockEnabled = false. 
% 
% If the module parameter enableRandomParamGen = false, the generating parameters are read from the file parameterInputFilename. This file
% must be a coma separated value text file with a header row containing the column names as listed in the param sets above and the values in
% the rows below must satisfy the conditions outlines in isvalid_tip_input_parameter_set.m. The module parameter generatingParamSetName must
% be consistent the set of parameters supplied in parameterInputFilename. Not that this file may contain more parameters than those listed
% in the generating param set but it must have at least those parameters specified by generatingParamSetName above. There is a TIP utility
% provided in order to generate parameterInputFilename in the proper format given an input struct, see make_valid_tip_input_parameter_file.m.
%
% Note if parameters are read from parameterInputFilename, the output struct will contain only those targets which are present in the
% tipDataObject. If none of the targets listed in parameterInputFilename are present in the tipDataObject a warning message will be
% displayed to stdout. If some of the targets listed in parameterInputFilename are not present in the tipDataObject a list of these targets
% will be displayed to stdout.
% 
% INPUT:
%   tipDataObject == tipDataClass object
%
% OUTPUT:
%   os == structure containing the following fields:
%           keplerId            == target ID
%           impactParameters    == impact parameter ( >= 0 , <=1 )
%           inputPhase          == normalized orbital phase ( >= 0 , <=1 )
%           offsetArcSec        == magnitude of offset of transiting source from target (in arc seconds)
%           offsetPhase         == phase locating offset transiting source measured from +RA axis at target location (>= -pi, < pi)
%           randomNumberSeed    == seed used to initialize random number stream
%       if generatingParamSetName = sesDurationParamSet
%           inputSES            == single event statistic (in whatever units this thing is measured in in the Kepler pipeline)
%           inputDurations      == transit duration (in hours)
%       if generatingParamSetName = periodRPlanetParamSet
%           planetRadius        == planet radius (in rEarth)
%           orbitalPeriodDays   == orbital period (in days)
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


% extract data needed from object 
configStruct = tipDataObject.simulatedTransitsConfigurationStruct;
skyGroupId = tipDataObject.skyGroupId;
targets = [tipDataObject.targetStarDataStruct];
inputKeplerId = colvec([targets.keplerId]);

% select only tagets with non-NaN RA and Dec
ra = [targets.raHours];
dec = [targets.decDegrees];
goodTargets = ~isnan(ra) & ~isnan(dec);
keplerId = inputKeplerId(goodTargets);
nTargets = length(keplerId);

% extract parameter input filename
parameterInputFilename = configStruct.parameterInputFilename;   % user specified parameter distributions only used if enableRandomParamGen = false

% extract simulation parameters                                                                                                            
inputSESUpperLimit              = configStruct.inputSesUpperLimit;                  % dimensionless
inputSESLowerLimit              = configStruct.inputSesLowerLimit;
inputDurationUpperLimit         = configStruct.inputDurationUpperLimit;             % hours
inputDurationLowerLimit         = configStruct.inputDurationLowerLimit;
impactParameterUpperLimit       = configStruct.impactParameterUpperLimit;           % dimensionless
impactParameterLowerLimit       = configStruct.impactParameterLowerLimit;
inputPlanetRadiusUpperLimit     = configStruct.inputPlanetRadiusUpperLimit;         % rEarth
inputPlanetRadiusLowerLimit     = configStruct.inputPlanetRadiusLowerLimit;
inputOrbitalPeriodUpperLimit    = configStruct.inputOrbitalPeriodUpperLimit;        % days
inputOrbitalPeriodLowerLimit    = configStruct.inputOrbitalPeriodLowerLimit;
generatingParamSetName          = configStruct.generatingParamSetName;
enableRandomParamGen            = configStruct.enableRandomParamGen;
offsetEnabled                   = configStruct.offsetEnabled;
offsetLowerLimitArcSec          = configStruct.offsetLowerLimitArcSec;
offsetUpperLimitArcSec          = configStruct.offsetUpperLimitArcSec;
randomSeedFromClockEnabled      = configStruct.randomSeedFromClockEnabled;
randomSeedBySkygroup            = configStruct.randomSeedBySkygroup;

% seed random number generator
if randomSeedFromClockEnabled
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',uint32(sum(clock))));
else
    RandStream.setDefaultStream(RandStream('mt19937ar','seed',uint32(randomSeedBySkygroup(skyGroupId)) ));
end

% either generate params from random distribution or read from file
if enableRandomParamGen    
    
    % write target list
    os.keplerId = keplerId;
    
    % generate random distributions for common parameters
    os.impactParameters = rand(nTargets,1) .* (impactParameterUpperLimit - impactParameterLowerLimit)  + impactParameterLowerLimit;
    os.inputPhase       = rand(nTargets,1);
    if offsetEnabled
        os.offsetArcSec = rand(nTargets,1) .* (offsetUpperLimitArcSec - offsetLowerLimitArcSec) + offsetLowerLimitArcSec;
        os.offsetPhase  = rand(nTargets,1) .* 2 .* pi - pi;
    else
        % call rand twice discarding output to keep random numbers in sync with the offsetEnabled = true case
        rand(nTargets,1);
        rand(nTargets,1);
        % set the offset to zero for all targets
        os.offsetArcSec = zeros(nTargets,1);
        os.offsetPhase  = zeros(nTargets,1);
    end
    
    % generate random distributions for set specific parameters
    switch generatingParamSetName
        case 'sesDurationParamSet'
            os.inputSES       = rand(nTargets,1) .* (inputSESUpperLimit - inputSESLowerLimit) + inputSESLowerLimit;
            os.inputDurations = rand(nTargets,1) .* (inputDurationUpperLimit - inputDurationLowerLimit) + inputDurationLowerLimit;
        case 'periodRPlanetParamSet'
            os.planetRadius      = rand(nTargets,1) .* (inputPlanetRadiusUpperLimit - inputPlanetRadiusLowerLimit) + inputPlanetRadiusLowerLimit;
            os.orbitalPeriodDays = rand(nTargets,1) .* (inputOrbitalPeriodUpperLimit - inputOrbitalPeriodLowerLimit) + inputOrbitalPeriodLowerLimit; 
    end
else
    os = read_simulated_transit_parameters( parameterInputFilename );
end

% error on invalid input parameters set
if ~isvalid_tip_input_parameter_set(os, generatingParamSetName)
    error('Invalid tip input parameter set produced.');
end

% find outputStruct target indices in tipDataObject
[tf, targetIndices] = ismember(os.keplerId, inputKeplerId);
os.targetIndices = targetIndices;

% display warning messages if selected targets are not present in TIP input
if all(~tf)
    % throw warning if all targets in the inputs parameter set are not in tipDataObject
    display('WARNING: No targets in the TIP input parameters set are found in the TIP inputsStruct.');
elseif any(~tf)
    % throw warning if any targets in the input parameters set are not in tipDataObject
    display('WARNING: Input parameters were generated for the following targets which are not in the TIP inputsStruct:');
    disp(os.keplerId(~tf));
    disp(' ');
end

% select only parameters for targets which exist in TIP inputs by truncating fields with arrays of parameters
% randomNumberSeed is a scalar field (applies to all targets) so it does not get truncated
osFields = fieldnames(os);
for iField = 1:length(osFields)
    tmp = os.(osFields{iField});
    os.(osFields{iField}) = tmp(tf);
end
    
% attach random number seed to output
os.randomNumberSeed = RandStream.getDefaultStream.Seed;

return;
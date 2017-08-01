function [outputsStruct] = Aprilensemble_matlab_controller(inputsStruct)
% [outputsStruct] = Aprilensemble_matlab_controller(inputsStruct)
%
% Removes common mode noise sources from the light curve of each target star.  
% All stars are included in each target star's ensemble, with the weight of the target star
% set to zero, and nearby stars (within a given pixel radius from the target star) weighted 
% heavily and decreasing with increasing distance.  The ensemble light curves for each target 
% star are computed simultaneously.
%
% INPUT
% convergenceParameter          parameter for convergence of weights
% inputsStruct.
%      .targetInputStruct []
%            .rowCentroid       mean X centroid for all stars (float [])
%            .colCentroid       mean Y centroid for all stars       "
%            .flux              raw flux time series  (float [])
%            .fluxUncert        raw flux uncertainties (float [])
%            .dataGap           boolean array (1=location of data gaps)
%            .starNumber        target star indices
%            .ensembleListInStruct []
%               .ensSetIn       indices of ensemble stars
%               .ensWeightsIn   weights of stars in ensSetIn
%      .targetID    list of targets to use (indices into targetInputStruct)
%
%      .gain                     gain (float, DMC)
%      .variableStarThresh       stellar variability threshold (float, PAR)
%      .updateEnsFlag            update ensemble flag (Boolean, PAR) if
%                                ensemble stars and weights are given as inputs
%      .nIterate                 number of iterations to establish convergence of
%                                weights (int, PAR)
%
% OUTPUT
% outputsStruct.
%       .targetOutputStruct []
%              .relFlux         relative flux time series (float [])
%              .relFluxUncert   uncertainties in relative flux (float [])
%              .diagnostic      diagnostic parameter which records weights at 
%                               each iteration (float [])
%        .ensembleListOutStruct []
%               .ensSetOut      indices of ensemble stars
%               .ensWeightsOut  weights of stars in ensSetOut
%         .elapsedTime          elapsed time between weights iterations (seconds)
%
% Written by N. Batalha Jul 2005
% 18 Nov 2005, modified by DAC to handle ETEM data w/ Kepler-like interface
% May 2007, updated by EVQ 
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

% radius in pixels from target star for which all stars within will fully contribute to 
% ensemble, while outside of this radius the contribution (weights) will decrease with distance
ensembleRadius = 350;

% parameter for convergence of weights
convergenceParameter = -6;

% determine nStars and nCadences
inputsStruct.nStars = length(inputsStruct.targetInputStruct);
inputsStruct.nCadences = length(inputsStruct.targetInputStruct(1).flux);

% pre-allocate vector which will record the elapsed time between weights iterations
elapsedTime = zeros(inputsStruct.nStars,1);

% set up target output structures
targetOutputStruct = struct('relFlux', zeros(inputsStruct.nCadences,inputsStruct.nStars), ...
    'relFluxUncert', zeros(inputsStruct.nCadences,inputsStruct.nStars), 'diagnostic',zeros(inputsStruct.nIterate-1,inputsStruct.nStars),'weightsTrue',zeros(inputsStruct.nStars,inputsStruct.nStars) );

ensembleListOutStruct = struct('ensSetOut', [], 'ensWeightsOut', []);

outputsStruct = struct('targetOutputStruct',targetOutputStruct,...
    'ensembleListOutStruct',ensembleListOutStruct,'elapsedTime',elapsedTime);

%%%%% temporary variable declared due to the resampling of target stars that was done in order
% to limit computation time for test runs
inputsStruct.nStars = 784;

% concatenate flux structures into array to perform calculations for all stars simultaneously
inputsStruct.flux = cat(2, inputsStruct.targetInputStruct.flux);

% convert flux from ADU to units of photoelectrons
inputsStruct.flux = inputsStruct.flux .* inputsStruct.gain;

%%%%% temporary declaration due to resampling of target stars 
inputsStruct.flux = inputsStruct.flux(1:4464, 1:784);

% concatenate flux uncertainties (given in units of photoelectrons) structures into array to perform calculations for all stars simultaneously
inputsStruct.uncertainties = cat(2, inputsStruct.targetInputStruct.uncertainties);

%%%%% temporary declaration due to resampling of target stars 
inputsStruct.uncertainties = inputsStruct.uncertainties(1:4464, 1:784);

% total variance (instrument noise) is equal to the flux uncertainty squared
% instrumental errors will be used as first guesses to compute normalized weights
instrumentWeights = inputsStruct.uncertainties(1,:) .^ 2;

% compute array of stellar distances to include in weights
[distanceWeights] = calculate_distance_weights(inputsStruct,ensembleRadius);

% define logical array that will be used to exclude variable stars from ensemble
weightsTrue = true(inputsStruct.nStars,inputsStruct.nStars);

% if ensemble weights are not given as input, generate ensemble set:
if inputsStruct.updateEnsFlag

    %iterate the weights, construct ensemble for star i, compute differential light curve and associated variance:
    [outputsStruct,varianceWeights] = iterate_weights(inputsStruct,convergenceParameter,instrumentWeights,distanceWeights,weightsTrue);

    %exclude variable stars from ensemble
    [weightsTrue] = variable_star_check(inputsStruct,instrumentWeights,varianceWeights,weightsTrue);

    %repeat get_weights using the updated set of nearstars which exclude
    %variable stars; iterate the weights, construct final ensemble,
    %compute differential light curves and associated variances
    [outputsStruct,varianceWeights,normalizedWeights,differentialLightCurveEns,diagnostic,ensemble,weightsTotal] = ...
        iterate_weights(inputsStruct,convergenceParameter,instrumentWeights,distanceWeights,weightsTrue);

    %compute the variances of differential light curves by propagating errors
    relFluxUncert = compute_variance(inputsStruct,ensemble,instrumentWeights,varianceWeights);

    %record final output
    %record final differential light curve
    outputsStruct.targetOutputStruct.relFlux = differentialLightCurveEns;

    %record uncertainties in relFlux
    outputsStruct.targetOutputStruct.relFluxUncert = relFluxUncert;

    % update ensemble weights
    outputsStruct.ensembleListOutStruct.ensWeightsOut = normalizedWeights;

    %outputsStruct.targetOutputStruct(i).diagnostic1 = diagnostic1;
    outputsStruct.targetOutputStruct.diagnostic = diagnostic;
    % update ensemble list, or copy over existing list
    %outputsStruct.ensembleListOutStruct(i).ensSetOut = nearstars;

    outputsStruct.targetOutputStruct.weightsTrue = weightsTrue;
    
    
    %if ensemble set/weights are given as input:
else

    targetOutputStruct.ensSetOut = inputsStruct.targetInputStruct(i).ensSetIn;
    targetOutputStruct.ensWeightsOut = inputsStruct.targetInputStruct(i).ensWeightsIn;

    %nearstars are given
    %nearstars = inputsStruct.targetInputStruct(i).ensSetIn;
    %nNearstars = length(nearstars);
    %[] = compute_light_curve();

    % get variance matrix for all stars
    varianceWeights = repmat(varDifferentialLightCurve,inputsStruct.nCadences,1);

    %use input weights
    %normalizedWeights = inputsStruct.targetInputStruct(i).ensWeightsIn;

    %duplicate weights, 1 set for each image
    %normalizedWeights = repmat(normalizedWeights, nImages, 1);
    [differentialLightCurveEns,varDifferentialLightCurveEns,normalizedWeights,ensemble] = ...
        construct_ensemble(inputsStruct,weightsInstrument,distanceWeights,weightsTrue);


    %record final differential light curve
    outputsStruct.targetOutputStruct.relFlux = differentialLightCurveEns;

    %no diagnostic when ensemble is pre-selected
    %outputsStruct.targetOutputStruct(i).diagnostic1 =[];
    outputsStruct.targetOutputStruct.diagnostic =[];
    relFluxUncert = compute_variance(inputsStruct,i,ensemble,varianceWeights);

    %record uncertainties in relFlux
    outputsStruct.targetOutputStruct.relFluxUncert = relFluxUncert;

end %if inputsStruct.updateEnsFlag

save ensemblerunvarthreshthousand.mat
return


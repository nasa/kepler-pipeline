function [outputsStruct,varianceWeights,normalizedWeights,differentialLightCurveEns,diagnostic,ensemble,weightsTotal] =...
    iterate_weights(inputsStruct,convergenceParameter,instrumentWeights,distanceWeights,weightsTrue)
%
% Function to calculate the weights for each star's ensemble through an
% iterative process.  Begins with instrumental noise as first guesses, and
% calculates the variance of differential light curves to use as new weights
%
% INPUT
% inputsStruct
% i (ith star)
%
% convergenceParameter
%
% OUTPUT
% ensemble
% differentialLightCurveEns
% diagnostic                    used to estimate the optimal number of iterations
% varianceWeights
% normalizedWeights
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

tstart = clock;
tnow = clock;

%pre-allocate diagnostic array
%diagnostic = zeros(inputsStruct.nIterate-1,1);
diagnostic = zeros(inputsStruct.nIterate-1,inputsStruct.nStars);

%pre-allocate array to collect weights upon each iteration,
%weightsKeep = zeros(inputsStruct.nIterate+1,inputsStruct.nStars);

%set first row equal to instrument noise
%weightsKeep(1,:) = instrumentWeights(1,:);

%pre-allocate array to record the differential light curve for star i upon each iteration
%diffLightCurveKeep = zeros(inputsStruct.nCadences, inputsStruct.nStars, inputsStruct.nIterate+1);
%differentialLightCurveArray = zeros(inputsStruct.nCadences, inputsStruct.nStars, 2);

 [differentialLightCurveEns,varDifferentialLightCurveEns,normalizedWeights] = ...
        construct_ensemble(inputsStruct,instrumentWeights,distanceWeights,weightsTrue);

h = cantwaitbar(0, tstart, 'Iteration j');
for j = 1:inputsStruct.nIterate+1

    
    oldEnsemble = differentialLightCurveEns;
    
    %construct an ensemble using all stars, and compute (1) differential light
    %curves using instrument errors as weights, and (2) variances of light curves
    [differentialLightCurveEns,varDifferentialLightCurveEns,normalizedWeights,ensemble,weightsTotal] = ...
        construct_ensemble(inputsStruct,instrumentWeights,distanceWeights,weightsTrue);

    %record variances of differential light curves
    %weightsKeep(j+1,:) = varDifferentialLightCurveEns;

    %record differential light curve of star i
    newEnsemble = differentialLightCurveEns;


    differentialLightCurveArray = cat(3,oldEnsemble,newEnsemble);
    

    %convergence test for ensemble star weights
    if (j > 1)

        %evaluate the change in the differential light curve per iteration
        %delta = log10(std(diff(diffLightCurveKeep(:,:,j-1:j),[],3))./mean(diffLightCurveKeep(:,:,j-1)));
        changeInLightCurve = log10(std(diff(differentialLightCurveArray, [], 3))./ mean(oldEnsemble));

        %changes in light curve become smaller as weights settle down,
        %number of iterations is sufficient when log(test3) < convergenceParameter (1e-6)
        convergedWeights = find(changeInLightCurve <= convergenceParameter);
        
        
        %break when all weights have converged
        if length(convergedWeights) == 784
            break
        end
        diagnostic(j-1,:) = changeInLightCurve;
    end

    %use the variances of the light curves as the new weights
    instrumentWeights = varDifferentialLightCurveEns;
    
    

    if etime(clock,tnow) > 1
        tnow = clock;
        cantwaitbar(j/(inputsStruct.nIterate+1), tstart, h, 'Calculating for iteration j');
    end

    outputsStruct.elapsedTime(j) = etime(tnow,tstart);

end

%save converged variance (of differential light curves) weights
varianceWeights = instrumentWeights;
differentialLightCurveEns = newEnsemble;

close(h)
return;
function [ensemble,differentialLightCurveEns,diagnostic,weightsNEW, ...
    normalizedWeights] = get_weights(Xin,i,nearstars,nNearstars,convergenceParameter)
% [ensemble,differentialLightCurveEns,diagnostic,weightsNEW, ...
%    normalizedWeights] = get_weights(Xin,i,nearstars,nNearstars,convergenceParameter)
%
% Function to calculate the weights for each star's ensemble through an
% iterative process.  Begins with instrumental noise as first guesses, and 
% calculates the variance of differential light curves to use as new weights
%
% INPUT
% Xin
% i (ith star)
% nearstars
% nNearstars
% convergenceParameter
%
% OUTPUT
% ensemble
% differentialLightCurveEns
% diagnostic
% weightsNEW
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

%compute normalized weights for ensemble stars using instrumental errors
%as first guesses
weights = Xin.varianceNoise(:,nearstars);

%tstartj = clock;
%tnowj = clock;
%hj = cantwaitbar(0, tstartj, 'j iterations');

%pre-allocate diagnostic array, which will be used to estimate the optimal
%number of iterations
%diagnostic1 = zeros(Xin.nIterate-1,Xin.nStars);
diagnostic = zeros(Xin.nIterate-1,1);

%pre-allocate array to collect weights upon each iteration,
%with first row equal to instrument noise
weightsKeep = zeros(Xin.nIterate+1,nNearstars);
weightsKeep(1,:) = weights(1,:);
    
%construct differential light curve

[ensemble,normalizedWeights,differentialLightCurveEns] = ...
    construct_ensemble(Xin,i,weights,nearstars,nNearstars);

diffLightCurveKeep = zeros(length(differentialLightCurveEns),Xin.nIterate+1);
diffLightCurveKeep(:,1) = differentialLightCurveEns;

%barj = waitbar(0,'get weights for star i'); %Waitbar to watch progress
for j = 1:Xin.nIterate

    %For each comparison star, construct an ensemble using the "other" stars,
    %and compute (1) differential light curve and (2) variance of light curve
    [varDifferentialLightCurve,normalizedWeights] = ...
        compute_light_curve(Xin,nNearstars,nearstars,weights);

    weightsKeep(j+1,:) = varDifferentialLightCurve;

    %use the variances of the light curves as the new normalized weights for all stars
    weightsNEW = repmat(varDifferentialLightCurve,Xin.nCadences,1);

    %construct ensemble for all stars
    [ensemble,normalizedWeights,differentialLightCurveEns] = ...
        construct_ensemble(Xin,i,weightsNEW,nearstars,nNearstars);

    diffLightCurveKeep(:,j+1) = differentialLightCurveEns;
    
    %test for convergence in ensemble star weights
    if (j > 1)

        %alternative test #1
        %test1 = sum(abs(weightsNEW(1,:) - weights(1,:)));
        %alternative test #2
        %test2 = 1 - sqrt(weightsNEW(1,:))./ sqrt(weights(1,:));
        %test2 = median(test2);
        %diagnostic1(j-1,i) = test1;
        
        %alternative test #3
        %plot((weightsKeep(2:end,:)))
        %semilogy(std(diff(diffLightCurveKeep,[],2))./mean(diffLightCurveKeep(:,1:end-1)))
        
        %evaluate the change in the differential light curve per iteration
        %test3 = std(diff(diffLightCurveKeep,[],2))./mean(diffLightCurveKeep(:,1:end-1));
        
        %test3 = log10(std(diff(diffLightCurveKeep,[],2))./mean(diffLightCurveKeep(:,1:end-1)));
        
        test3 = log10(std(diff(diffLightCurveKeep(:,j-1:j),[],2))./mean(diffLightCurveKeep(:,j-1)));
        
        %changes in light curve become smaller as weights settle down,
        %number of iterations is sufficient when log(test3) < 1e-6
        
        if (test3(end) <= convergenceParameter)
            break 
            
        end
        diagnostic(j-1,1) = test3;

    end
    weights = weightsNEW;

    %waitbar(j-1/Xin.nIterate,barj)
    %   if etime(clock,tnowj) > 1
    %       tnowj = clock;
    %       cantwaitbar(j/Xin.nIterate, tstartj, hj, 'Calculating for jth iteration');
    %   end
end
%close(hj)
%close(barj)

return;
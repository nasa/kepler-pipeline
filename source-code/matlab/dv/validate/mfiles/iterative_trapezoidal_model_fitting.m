function [trapezoidalModelFitData] = iterative_trapezoidal_model_fitting(trapezoidalModelFitData, nRuns)
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

iTarget = trapezoidalModelFitData.iTarget;
iPlanet = trapezoidalModelFitData.iPlanet;

residualFunction = @(pars)trapezoidal_model_function(pars, trapezoidalModelFitData);

chiSquares                      = zeros([1,                                                                              nRuns]);
fitParameters                   = zeros([length(trapezoidalModelFitData.modelFittingParameters.physicalVariableValues),  nRuns]);
fitParametersBoundedVariables   = zeros([length(trapezoidalModelFitData.modelFittingParameters.physicalVariableValues),  nRuns]);
validFitFlags                   = false(1, nRuns);

for i = 1 : nRuns
    
    physicalVariablesInitial    = trapezoidalModelFitData.modelFittingParameters.physicalVariableMins + rand(size(trapezoidalModelFitData.modelFittingParameters.physicalVariableMins)) .* ...
        ( trapezoidalModelFitData.modelFittingParameters.physicalVariableMaxs - trapezoidalModelFitData.modelFittingParameters.physicalVariableMins );
    
    physicalVariablesInitial(2) = max([ mean(trapezoidalModelFitData.quarters.minDepthPpm(trapezoidalModelFitData.quarters.transitsFlag))/1.0e6; physicalVariablesInitial(2) ] );
    
    
    boundedVariablesInitial     = boundedvals(physicalVariablesInitial, trapezoidalModelFitData.modelFittingParameters.physicalVariableMaxs, trapezoidalModelFitData.modelFittingParameters.physicalVariableMins);
    
    testResiduals               = feval(residualFunction, boundedVariablesInitial);
    
    if sum( isnan(testResiduals) | ~isfinite(testResiduals) ) > 0
        
        display(' ');
        display(['Try run #' num2str(i) ':  Warning: NaNs/Infinite numbers found in the residuals of flux values']);
        display(' ');
        
    else
        
        [Xf, Ssq, CNT, Res, XY]     = LMFnlsq(residualFunction, boundedVariablesInitial, 'Display', 0);
        
        boundedVariablesFinal       = Xf;
        physicalVariablesFinal      = unboundedvals(boundedVariablesFinal, trapezoidalModelFitData.modelFittingParameters.physicalVariableMaxs, trapezoidalModelFitData.modelFittingParameters.physicalVariableMins);
        
        
        display(' ');
        display(['Try run #' num2str(i) ':  chiSquare  ' num2str(Ssq) '    and  parameters ']);
        physicalVariablesFinal
        close all;
        
        chiSquares(1, i)                      = Ssq;
        fitParameters(:, i)                   = physicalVariablesFinal;
        fitParametersBoundedVariables(:, i)   = boundedVariablesFinal;
        
        if (       ~isnan(Ssq)                        &&      isfinite(Ssq)                        && ...
                sum(isnan(physicalVariablesFinal))==0 && sum(~isfinite(physicalVariablesFinal))==0 && ...
                sum(isnan(boundedVariablesFinal ))==0 && sum(~isfinite(boundedVariablesFinal ))==0 && ...
                physicalVariablesFinal(2) >  1.0e-6                                                && ...                   % depth > 1 ppm
                physicalVariablesFinal(3) >  0        && physicalVariablesFinal(4) > 0             && ...                   % bigTDays > 0, littleTDays > 0
                physicalVariablesFinal(3) >= physicalVariablesFinal(4)*physicalVariablesFinal(3)   && ...                   % bigTDays >= littleTDays
               (physicalVariablesFinal(3) +  physicalVariablesFinal(4)*physicalVariablesFinal(3)) >= 0.5/24 )               % durationDays = bigTDays + littleTDays >= 0.5/24 Days
            
            validFitFlags(i) = true;
            
        end
        
    end
    
end

nValidFits = sum(validFitFlags);
if nValidFits > 0
    
    chiSquares                          = chiSquares(1, validFitFlags);
    fitParameters                       = fitParameters(:, validFitFlags);
    fitParametersBoundedVariables      =  fitParametersBoundedVariables(:, validFitFlags);

    [minChiSquare, index]               = min(chiSquares);
    bestFitParameters                   = fitParameters(:, index);
    bestFitParametersBoundedVariables   = fitParametersBoundedVariables(:, index);

    nFitData                            = sum(trapezoidalModelFitData.modelFittingParameters.fitDataFlag);
    nBestFitParameters                  = length(bestFitParameters);
    
    trapezoidalModelFitData.trapezoidalFitOutputs.minChiSquare                       = minChiSquare;
    trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters                  = bestFitParameters;
    trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParametersBoundedVariables  = bestFitParametersBoundedVariables;
    trapezoidalModelFitData.trapezoidalFitOutputs.degreesOfFreedom                   = nFitData - nBestFitParameters;
    trapezoidalModelFitData.trapezoidalFitMinimized                                  = true;
    
    display(' ');
    display(['      ' num2str(nValidFits) ' valid trapezoidal fits are identified from the outputs of ' num2str(nRuns) ' try runs.']);
    display(['      The best trapezoidal fit of target ' num2str(iTarget) ' planet candidate ' num2str(iPlanet) ' is determined as the valid trapezoidal fit with the minimum chiSquare:']);
    display(['         chiSquare = ' num2str(trapezoidalModelFitData.trapezoidalFitOutputs.minChiSquare) ',      parameterValues:  ' ...
             trapezoidalModelFitData.modelFittingParameters.physicalVariableNames{1} ' = '  num2str(trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(1)) ',  ' ...
             trapezoidalModelFitData.modelFittingParameters.physicalVariableNames{2} ' = '  num2str(trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(2)) ',  ' ...
             trapezoidalModelFitData.modelFittingParameters.physicalVariableNames{3} ' = '  num2str(trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(3)) ',  ' ...
             trapezoidalModelFitData.modelFittingParameters.physicalVariableNames{4} ' = '  num2str(trapezoidalModelFitData.trapezoidalFitOutputs.bestFitParameters(4)) ]);
    display(' ');
    display(' ');
    
else
    
    error('dv:iterativeTrapezidalModelFitting:noValidTrapezoidalFits', 'no valid trapezoidal fits are available');
    
end

end


% create_tcat_inputs.m
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

% bartOutputModelStruct =
%
%                    T0: 35
%     modelCoefficients: [2x1070x1132 double]
%      covarianceMatrix: [3x1070x1132 double]
%                module: 2
%                output: 1 
%
% bartHistoryStruct =
%            module: 2
%            output: 1
%     fitsFileNames: {27x1 cell}
%       temperature: [1x27 double]
%
% bartDiagnosticsWeightStruct =
%     weightedRmsResiduals: [1070x1132 double]
%                weightSum: [1070x1132 double]
%                   module: 2
%                   output: 1





% table strings for name are:
% Y = random(name,A,B)
%
% 'beta' (Beta distribution)
% y = random('beta', 4, 4, m,n);
%
%
% 'chi2' (Chi-square distribution) non-central chi-square (Rice)
% distribution
% y = random('ncx2', 4, 1, m,n);
%
% 'exp' (Exponential distribution)
% y = random('exp', 4, m,n);
%
% 'ev' (Extreme value distribution)
% y = random('evp', 4, 0.01, m,n);
%
% 'f' (F distribution)
% y = random('f', 4, 2, m,n);
%
% 'gam' (Gamma distribution)
% y = random('gam', 4, 2, m,n);
%
%
% 'gp' (Generalized Pareto distribution)
% y = random('gp', 0, 1, 0.5, m,n);
%
%
% 'norm' (Normal distribution)
% y = random('normrnd', 0.01, , 0.1, m,n);
%
%
% 'rayl' (Rayleigh distribution)
% y = random('rayl', 0.5, m,n);
%
% 't' (t distribution)
% y = random('trnd',4, m,n);
%
% 'unif' (Uniform distribution)
% y = random('unif', 0.01, 0.09, m,n);
%
%
% 'wbl' (Weibull distribution
% y = random('wbl', 0.5, 0.5, m,n);

close all;
clc;

% choose different distributions for modouts

randomOrder = randperm(84);
randomOrder = randomOrder(:);

distributionsEvalString  = cell(84,1);
meanArray = linspace(0.01,0.15, 84);
stdArray = linspace(0.1, 0.9, 84);

for j = 1:84

    k = randomOrder(j);
    switch j
        case 1
            distributionsEvalString{k} = 'y = random(''beta'', 4, 4, 1070,1132);';
        case 2
            distributionsEvalString{k} = 'y = random(''ncx2'', 4, 1, 1070,1132);';
        case 3
            distributionsEvalString{k} = 'y = random(''exp'', 4,  1070,1132);';
        case 4
            distributionsEvalString{k} = 'y = random(''ev'', 4, .01, 1070,1132);';
        case 5
            distributionsEvalString{k} = 'y = random(''f'', 4, 2, 1070,1132);';
        case 6
            distributionsEvalString{k} = 'y = random(''gam'', 4, 2, 1070,1132);';
        case 7
            distributionsEvalString{k} = 'y = random(''gp'', 0, 1, 0.5, 1070,1132);';
        case 8
            distributionsEvalString{k} = 'y = random(''rayl'',  0.5, 1070,1132);';
        case 9
            distributionsEvalString{k} = 'y = random(''t'',  4, 1070,1132);';
        case 10
            distributionsEvalString{k} = 'y = random(''unif'',  0.1, 0.9, 1070,1132);';
        case 11
            distributionsEvalString{k} = 'y = random(''wbl'',  0.5, 0.5, 1070,1132);';
        otherwise
            randomIndex = unidrnd(84,1);
            distributionsEvalString{k} = ['y = random(''norm'',  ' num2str(meanArray(randomIndex)) ' , '  num2str(stdArray(randomIndex)) ',  1070,1132);'];
    end

end


% quickly try to evaluste the expressions


% for j = 1: 84
%
%     eval(distributionsEvalString{j});
%     imagesc(y);
%     pause
%
% end
%
%
%
%


dirNameStr = 'model';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end

dirNameStr = 'diagnostics';
if(~exist(dirNameStr, 'dir'))
    eval(['mkdir ' dirNameStr]);
end



for j = 1:84


    [module, output] = convert_to_module_output(j);

    bartOutputModelStruct.module = module;
    bartOutputModelStruct.output = output;

    bartHistoryStruct.module = module;
    bartHistoryStruct.output = output;

    bartDiagnosticsWeightStruct.module = module;
    bartDiagnosticsWeightStruct.output = output;


    diagnosticsMatFileName = ['bart_mod' num2str(module) '_out' num2str(output) '_' datestr(now,1) '_diagnostics.mat'];
    diagnosticsMatFileName = strrep(diagnosticsMatFileName, '-', '_');

    modelMatFileName = ['bart_mod' num2str(module) '_out' num2str(output) '_' datestr(now,1) '_model.mat'];
    modelMatFileName = strrep(modelMatFileName, '-', '_');


    % may need to load and change the values to generate distinct data
    % structures for each modout
    eval(['load diagnostics/' diagnosticsMatFileName ' bartDiagnosticsWeightStruct bartHistoryStruct;']);

    randomIndex = unidrnd(84,1);
    eval(distributionsEvalString{randomIndex});

    % introduce sprinkling of NaNs (10%)
    xrow = unidrnd(1070,100,1);
    ycol = unidrnd(1132,100,1);
    [X,Y] = meshgrid(xrow, ycol);
    invalidIndex = sub2ind([1070,1132], X(:), Y(:));    
    
    y(invalidIndex) = NaN;


    bartDiagnosticsWeightStruct. weightedRmsResiduals = y; % new distinct distributiond for each modout


    eval(['load model/' modelMatFileName ' bartOutputModelStruct bartHistoryStruct;']);

    randomIndex = unidrnd(84,1);

    eval(distributionsEvalString{randomIndex});
    % introduce sprinkling of NaNs (10%)
    xrow = unidrnd(1070,100,1);
    ycol = unidrnd(1132,100,1);
    [X,Y] = meshgrid(xrow, ycol);
    invalidIndex = sub2ind([1070,1132], X(:), Y(:));    

    y(invalidIndex) = NaN;

    bartOutputModelStruct.modelCoefficients(1,:,:) =  y;

    randomIndex = unidrnd(84,1);

    eval(distributionsEvalString{randomIndex});
    y(invalidIndex) = NaN; % same invalid index as for the const coefficients

    bartOutputModelStruct.modelCoefficients(2,:,:) =  719 + y;

    eval(['save  ' diagnosticsMatFileName ' bartDiagnosticsWeightStruct bartHistoryStruct;']);

    eval(['save  ' modelMatFileName ' bartOutputModelStruct bartHistoryStruct;']);

    movefile( diagnosticsMatFileName, 'diagnostics/', 'f');
    movefile( modelMatFileName, 'model/', 'f');


end
return;
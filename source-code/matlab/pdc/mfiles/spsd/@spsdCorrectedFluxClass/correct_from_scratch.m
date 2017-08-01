function correctionResultsStruct = correct_from_scratch( obj, iDedStruct )
%%  correct_from_scratch
% Removes SPSDs from time series.
% spsd = Sudden Pixel Sensitivity Dropouts
% 
%   Revision History:
%
%       Version 0 - 3/14/11       released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation.
%                                 Changed some variable names for
%                                 readablity.
%                                 Replaced some enumerated values with
%                                 variable names
%                                 Deleted unused development code.
%       Version 0.11 - 3/05/12    moved into correct_from_scratch
%                                 (otherwise unchanged)
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
% function correctionResultsStruct= correct(iDedStruct, timeseriesStruct);
%% 1.0 ARGUMENTS
% 
% Function returns: 
%
% * |correctionResultsStruct    	-| structure containing corrected timeseries information. 
% * |.correctedTimeSeries           -| timeseries with SPSDs removed 
% * |.PersistentStep                -| correction timeseries for persistent step 
% * |.RecoveryTerm                  -| correction timeseries for recovery 
%
% Function Arguments:
%
% * |iDedStruct   -| structure containing new spsd information to be appended. 
% * See | detect.m | for structure details
%
% * |timeseriesStruct   -| structure containing corrections associated with new SPSDs. 
% * See | Get_input_timeseries.m | for structure details
%
%% 2.0 CONSTANT PARAMETERS
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
polyWindowHalfWidth = obj.correctionParamsStruct.polyWindowHalfWidth;       % polynomial window half-width
recoveryWindowWidth = obj.correctionParamsStruct.recoveryWindowWidth;       % recovery window width
bigPicturePolyOrder = obj.correctionParamsStruct.bigPicturePolyOrder;       % polynomial order for big picture fit
logTimeConstantStartValue      = obj.correctionParamsStruct.logTimeConstantStartValue; % log_10 of time constant start range ( as fraction of recovery window width
logTimeConstantIncrement   = obj.correctionParamsStruct.logTimeConstantIncrement;  % log_10 of time constant increment
logTimeConstantMaxValue      = obj.correctionParamsStruct.logTimeConstantMaxValue;   % log_10 of time constant end range
timeConstant           = 10.^(logTimeConstantStartValue:logTimeConstantIncrement:logTimeConstantMaxValue); % range of time constants for exponential model terms
nTimeConstants        = length(timeConstant);             % number of exponential terms

%% 3.0 INITIALIZATION
%

% Get original flux time series with spsds SPSDs and gap locations
dirtyTimeSeries = obj.timeSeriesStruct.fluxResiduals( iDedStruct.index , : );
dirtyGaps       = obj.timeSeriesStruct.gaps( iDedStruct.index , : );

% Number of U_hat vectors from inputs
nMapBasisVectors     = size(obj.timeSeriesStruct.parameters.U_hat,1);

% Number of long cadences
nCadences=length(dirtyTimeSeries(1,:));

% initialization
newTimeSeries1=zeros(iDedStruct.count,nCadences);
correctionResultsStruct.correctedTimeSeries=zeros(iDedStruct.count,nCadences);
correctionResultsStruct.persistentStep=zeros(iDedStruct.count,nCadences);
correctionResultsStruct.recoveryTerm=zeros(iDedStruct.count,nCadences);

% number of components in big picture model
nBigPictureModelComponents=bigPicturePolyOrder+2+nMapBasisVectors;

% long and short term variability statistics 
% (sqrt(2)*mad(fit residuals)/mad(diff(fit residuals))
% from detect.m long term and short term fits
longTermVar=sqrt(2)*iDedStruct.longMADs(:,1)./iDedStruct.longMADs(:,2);
shortTermVar=sqrt(2)*iDedStruct.shortMADs(:,1)./iDedStruct.shortMADs(:,2);

% these aren't currently used
timeConstEst=-iDedStruct.longCoefs(:,9)./iDedStruct.longCoefs(:,10)/3;
timeConstEst2=-iDedStruct.shortCoefs(:,7)./iDedStruct.longCoefs(:,10)/3;

% these ordered indices are mainly for ploting and debugging 
[~,orderedByStepHeight]=sort(iDedStruct.longStepHeight(:),'ascend');
[~,orderedByLongTermVar]=sort(longTermVar,'descend');
[~,orderedByShortTermVar]=sort(shortTermVar,'descend');

%% 4.0 ESTIMATE PERSISTENT STEP HEIGHT FROM BIG PICTURE  
%

% initialization
steps = zeros(iDedStruct.count,nCadences);
coefs = zeros(nBigPictureModelComponents,iDedStruct.count);
xRange= cell(iDedStruct.count,1);
bigPictureModel=cell(iDedStruct.count,1);
    
% perform big picture analysis on each TS identified to have an spsd
for k1=1:iDedStruct.count    
    k=orderedByStepHeight(k1);
    
    % center of window
    center = iDedStruct.spsdCadence(k);

    % fit range excludes recover window, with constraints including the
    % ends
    cadenceRangeBigPicture = [1:center-2,min(nCadences-4,center+recoveryWindowWidth+1):nCadences];
    
    % polynomial range
    normalizedXRange = -1.0:2/(nCadences-1):1.0;
    PolyRangeBigPicture = normalizedXRange(cadenceRangeBigPicture);
    
    % number of data points
    nCadencesInBigPicture=length(cadenceRangeBigPicture);
    
    % step at spsd location over full time series
    unitStep=[zeros(1,center-1),0.5,ones(1,nCadences-center)];
    
    % initialize big picture design matrix
    designMatBigPicture = zeros(nBigPictureModelComponents,nCadencesInBigPicture);
    
    % design matrix component #1: constant
    designMatBigPicture(1,:) = ones(1,nCadencesInBigPicture);
    
    % design matrix components #2 to bigPicturePolyOrder+1: Legendre polynomials
    for k2 = 1:bigPicturePolyOrder
        legendreFunctions = legendre(k2,PolyRangeBigPicture);
        designMatBigPicture(k2+1,:) = legendreFunctions(1,:);
    end
    
    % design matrix components # bigPicturePolyOrder+2 to
    % bigPicturePolyOrder+2+nMapBasisVectors: Uhat components from input
    if ~isempty(obj.timeSeriesStruct.parameters.U_hat)
        designMatBigPicture(bigPicturePolyOrder+1+(1:nMapBasisVectors),:)=obj.timeSeriesStruct.parameters.U_hat(:,cadenceRangeBigPicture);
    end
    
    % last design matrix component: persistent step
    designMatBigPicture(end,:) = unitStep(1,cadenceRangeBigPicture);
    
    % index for excluding gaps
    nonGapIndices=dirtyGaps(k,cadenceRangeBigPicture)==0;

    % fit big picture
    fitBigPicture = regress( ...
        dirtyTimeSeries(k,cadenceRangeBigPicture(nonGapIndices))', ...
        designMatBigPicture(:,nonGapIndices)');
    coefs(:,k)=fitBigPicture;
    
    % constrain to actual step height to range between 0 and local short term step
    % height
    coefs(end,k)=min(0.0,max(fitBigPicture(end),iDedStruct.shortStepHeight(k)));
    
    % persistent step component
    steps(k,:)=coefs(end,k)*unitStep;
    
    % modeled range and modeled estimate--excluding step
    xRange{k}=cadenceRangeBigPicture;
    bigPictureModel{k}=fitBigPicture(1:end-1)'*designMatBigPicture(1:end-1,:)-mean(fitBigPicture(1:end-1)'*designMatBigPicture(1:end-1,:));
    
    % revised time series corrected for persistent step
    newTimeSeries1(k,:)=dirtyTimeSeries(k,:)-steps(k,:);
    
end

%% 5.0 DETERMINE OPTIMAL LOCAL POLYNOMIAL ORDER
% DELETED UNUSED DEVELOPMENT CODE


%% 6.0 DETERMINE CORRECTION FOR spsd RECOVERY
% Estimates an transient recovery during a 
% 'recoveryWindowWidth' long cadence window of time after the spsd event

% perform recovery analysis on each time series as revised in 4.0
for k1=1:iDedStruct.count   
        k=orderedByStepHeight(k1);
    
%% 6.1 DEFINE WINDOWS OF INTEREST
% Modeled window is 2*polyWindowHalfWidth+1 LC centered around spsd.
% recoveryTerm window is recoveryWindowWidth LC beginning at the spsd and
% extending afterword.

    % long cadence of spsd
    center = iDedStruct.spsdCadence(k);

    % modeled range 
    cadenceRangeRecovery = max(1,center-polyWindowHalfWidth):min(nCadences,center+polyWindowHalfWidth);
    
    % location of spsd within the modeled window
    windowCenter= center-cadenceRangeRecovery(1)+1;
    
    % polynomial range
    nCadencesInRecovery=length(cadenceRangeRecovery);
    PolyRangeRecovery = -1.0:2/(nCadencesInRecovery-1):1.0;
    
    % recovery window range within the modeled window
    rangeWindow = windowCenter-1:max(windowCenter+3,min(windowCenter+recoveryWindowWidth,nCadencesInRecovery-4));
    nCadencesInWindow=length(rangeWindow);


%% 6.2 ID AND REMOVE HARMONICS IN MODELED WINDOW
% Identify and remove any harmonics in the modeled window,
% which survive because the spsd is present 

    [newTimeSeries2,~,stepVector]=obj.remove_harmonics(newTimeSeries1(k,:),cadenceRangeRecovery,center);
    thisTimeSeries=newTimeSeries2(cadenceRangeRecovery(dirtyGaps(k,cadenceRangeRecovery)==0))';

%% 6.3 DETERMINE OPTIMAL POLYNOMIAL ORDER IN MODELED WINDOW MINUS RECOVERY RANGE
% Determine the optimal polynomial order needed to fit the modeled
% region excluding the recovery window range

    % modeled range of interest excluding the recovery window range and
    % gaps
    rangePolyModel=setdiff(1:length(PolyRangeRecovery),rangeWindow); % 
    rangeLCPolyModel0=cadenceRangeRecovery(rangePolyModel);
    rangeLCPolyModel=rangeLCPolyModel0(dirtyGaps(k,rangeLCPolyModel0)==0);
    
    % determine optimal polynomial degree
    y=newTimeSeries2(rangeLCPolyModel)';
    x=PolyRangeRecovery(rangeLCPolyModel-rangeLCPolyModel0(1)+1)';
    [optimalPolyDeg,~] = obj.polydeg(x,y-mean(y));
    
%% 6.4 DESIGN MATRIX FOR RECOVERY MODEL
% polynomials + cotrend(Uhat) terms + recovery terms + residual step

    % polynomial order (NOTE: polynomials are nuissance parameters
    polynomial = optimalPolyDeg;
    
    % offset to recovery terms
    offset = polynomial+5+nMapBasisVectors;
    
    % number of components in design matrix
    nRecoveryModelComponents = 5 +polynomial+nTimeConstants+nMapBasisVectors;

    % initalize recovery design matrix
    M = zeros(nRecoveryModelComponents,nCadencesInRecovery);
    
    % design matrix component #1: constant
    M(1,:) = ones(1,nCadencesInRecovery);

    % design matrix component #2 to 4: delta functions 
    % to effectively mask or decouple central 3 LC from recovery parameters
    M(2,windowCenter-1) = 1;
    M(3,windowCenter) = 1;
    M(4,windowCenter+1) = 1;
    
    % design matrix component #5 to polynomial+4: Legendre Polynomials terms 
    % (NOTE: polynomial coefficients are nuissance parameters in the model)
    for k2 = 1:polynomial
        legendreFunctions = legendre(k2,PolyRangeRecovery);
        M(k2+4,:) = legendreFunctions(1,:);
    end
    
    % design matrix component #polynomial+5 to polynomial+nMapBasisVectors+4: Cotrending terms
    if ~isempty(obj.timeSeriesStruct.parameters.U_hat)    
        M(polynomial+4+(1:nMapBasisVectors),:)=obj.timeSeriesStruct.parameters.U_hat(:,cadenceRangeRecovery);
    end
    
    % exponential function range (0-1)
    rangeExponentialFunction = zeros(1,nCadencesInWindow);
    rangeExponentialFunction(1,3:nCadencesInWindow) = 0:1/(nCadencesInWindow-3):1.0;

    % design matrix component #polynomial+nMapBasisVectors+5 to polynomial+nMapBasisVectors+nTimeConstants+4: recoveryTerm terms
    % recoveryTerm is modeled by a series of modified exponential functions
    % the function f(x) is an exponential decay with a series 
    % of distinct time constants + a linear ramp
    % under the constraints that f(0)=1,  f(1)=0, f'(1)=0.
    %
    % RLM -- We take nCadencesInWindow evenly spaced samples of f(x) along
    % the interval [0,1.0]. 
    for k2 = 1:nTimeConstants
        thisTimeConstant=timeConstant(k2);
        M(offset+k2-1,rangeWindow)=-((thisTimeConstant - exp((1 - rangeExponentialFunction)/thisTimeConstant)*thisTimeConstant + 1 - rangeExponentialFunction)./ ...
                                              (thisTimeConstant - exp(1/thisTimeConstant)*thisTimeConstant + 1));
    end
    
    % (last) design matrix component # polynomial+nMapBasisVectors+nTimeConstants+5: persistentStep Term
    M(end,windowCenter-1:end) = ones(1,nCadencesInRecovery-windowCenter+2);

    
%% 6.5 FIT FOR RECOVERY COEFFICIENTS
% fit with and without step term 

    warningState = warning('query', 'all'); warning off

    fit1 = regress(thisTimeSeries,M(:,dirtyGaps(k,cadenceRangeRecovery)==0)');
    fit2 = regress(thisTimeSeries,M(1:end-1,dirtyGaps(k,cadenceRangeRecovery)==0)');
    
    warning(warningState);

    % polynomial part of fit
    polyEstimate1=fit1(5:offset-nMapBasisVectors-1)'*M(5:offset-nMapBasisVectors-1,:); 
    polyEstimate2=fit2(5:offset-nMapBasisVectors-1)'*M(5:offset-nMapBasisVectors-1,:);
    
    % Variation in polynomial part of fit.
    % Correlations between polynomial and recovery terms can cause 
    % large (unnatural) polynomial variations in the recovery range.
    % These quantities are defined to discriminate which fit (w/ or w/o
    % step) gives smaller variation.
    varPoly1=std(detrend(polyEstimate1));
    varPoly2=std(detrend(polyEstimate2));
        
    
%% 6.6 BUILD OUTPUT STRUCTURE
% polynomials + cotrend(Uhat) terms + recovery terms 


    if varPoly1<varPoly2
        
        % FIT WITH STEP case
        
        % recovery includes delta functions and exponential functions
        recovery=fit1([2:4,offset:end-1])'*M([2:4,offset:end-1],:);
        
        % step included fit step from 6.5, fit step from harmonic removal from 6.2,
        % and sustained step from big picture analysis from 4.0
        newStep=zeros(1,nCadences);
        newStep(1,cadenceRangeRecovery)=fit1(end)*M(end,:); % in modeled window
        newStep(1,cadenceRangeRecovery(end)+1:nCadences)= ...
            fit1(end)*ones(1,length(cadenceRangeRecovery(end)+1:nCadences)); % after modeled window
        % combine various step components
        correctionResultsStruct.persistentStep(k,:)=steps(k,:)+newStep+stepVector';
        
    else
        
        % FIT WITHOUT STEP case
        
        % recovery again includes delta functions and exponential functions
        recovery=fit2([2:4,offset:end])'*M([2:4,offset:end-1],:);
        
        % step included only fit step from harmonic removal from 6.2,
        % and sustained step from big picture analysis from 4.0
        correctionResultsStruct.persistentStep(k,:)=steps(k,:)+stepVector';
        
    end

    % recovery again includes delta functions and exponential functions
    correctionResultsStruct.recoveryTerm(k,cadenceRangeRecovery)=recovery;

    % RLM -- Limit the correction to prevent corrected flux values from
    % dropping below input flux. Zero all correction components where the
    % combined correction would cause corrected flux to drop below input
    % flux.
    combinedCorrection = correctionResultsStruct.persistentStep(k,:) + correctionResultsStruct.recoveryTerm(k,:);
    badCorrectionFlags = combinedCorrection > 0;
    correctionResultsStruct.persistentStep( k, badCorrectionFlags ) = 0;
    correctionResultsStruct.recoveryTerm(   k, badCorrectionFlags ) = 0;

    % JCS: Check for poor corrections
    % If the std of the corrected flux is greater than the original flux (with tolerance factor) then the correction appears to poor and do not perform the
    % correction.
    correctionToleranceFactor=1.5; % adjustable > 1
    varOriginal=std(detrend(dirtyTimeSeries(k,cadenceRangeRecovery)));
    proposedCorrectedTimeSeries = dirtyTimeSeries(k,:) - combinedCorrection;
    varCorrected=std(detrend(proposedCorrectedTimeSeries(cadenceRangeRecovery)));
    if varCorrected > correctionToleranceFactor* varOriginal
        badCorrectionFlags = true(size(combinedCorrection));
        correctionResultsStruct.persistentStep(k, badCorrectionFlags) = 0;
        correctionResultsStruct.recoveryTerm(k, badCorrectionFlags) = 0;
    end


    % original time series with spsd corrections applied
    correctionResultsStruct.correctedTimeSeries(k,:)=dirtyTimeSeries(k,:)-...
                                                correctionResultsStruct.recoveryTerm(k,:)- ...
                                                correctionResultsStruct.persistentStep(k,:);
        
end
%% 7.0 RETURN
% 

   % RLM: Make sure value arrays are set to zero or -1 where gap indicators 
   % are set.

end


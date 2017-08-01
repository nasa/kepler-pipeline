function eeTempStruct = generate_eeTempStruct_from_paDataStruct(paDataStruct,paResultsStruct,varargin)
%%   function eeTempStruct = generate_eeTempStruct_from_paDataStruct(paDataStruct,paResultsStruct,varargin)
%
% This function packages data from a paDataStruct and a paResults struct
% into a temporary structure used by encircledEnergy.m (eeTempStruct).
% Default values for algorithm tuning parameters are set here if they are
% not provided through the encircledEnergyConfigurationStruct in the input.
%
% INPUT:
% paDataStruct.targetStarDataStruct: [1xnTargets struct]
%                            labels: cell array;string
%            fluxFractionInAperture: double
%                      expectedFlux: double (OPTIONAL)
%                   pixelDataStruct: [1xnPixels struct]
%                            values: nCadences x 1;double
%                     gapIndicators: nCadences x 1;logical
%                     uncertainties: nCadences x 1;double
%                            ccdRow: int
%                         ccdColumn: int
%
%  paDataStruct.encircledEnergyConfigurationStruct
%           fluxFraction: double
%              polyOrder: int
%            targetLabel: string
%             maxTargets: int
%              maxPixels: int
%             seedRadius: double
%           maxPolyOrder: int
%            aicFraction: double
%        targetPolyOrder: int
%              maxRadius: double
%           plotsEnabled: logical
%        robustThreshold: double
%     robustLimitEnabled: logical
%
%     paResultsStruct.targetStarResultsStruct: [1xnTargets struct]
%               prfCentroids: [struct]
%                   rowTimeSeries: [struct]
%                              values: [nCadencesx1];double
%                       uncertainties: [nCadencesx1];double
%                       gapIndicators: [nCadencesx1];logical
%                columnTimeSeries: [struct]
%                              values: [nCadencesx1];double
%                       uncertainties: [nCadencesx1];double
%                       gapIndicators: [nCadencesx1];logical
%      fluxWeightedCentroids: [struct]
%                   rowTimeSeries: [struct]
%                              values: [nCadencesx1];double
%                       uncertainties: [nCadencesx1];double
%                       gapIndicators: [nCadencesx1];logical
%                columnTimeSeries: [struct]
%                              values: [nCadencesx1];double
%                       uncertainties: [nCadencesx1];double
%                       gapIndicators: [nCadencesx1];logical
%
% VARIABLE INPUT ARGUMENTS
% varargin(1) = If available, polyOrder, order of polynomial used in eeRadius fit. 
%               If polyOrder = -1 --> invoke polynomial order selection is based on minimizing
%               the AIC metric for a randomly selected AIC_FRACTION of cadences, then apply that
%               polyOrder to all other cadences
% varargin(2) = If available, eeFraction == fraction of total encircled energy included within eeRadius
% varargin(3) = If available, plotOn --> boolean to turn on plots during processing; 1 == turn plots on
%
% OUTPUT:
%   eeTempStruct             = structure with the following fields
%       .targetStar()        = # of encircled energy targets x 1 array of structures with the following fields:
%           .gapList()       = # of gaps x 1 int containing the indices of cadence gaps at the target-level
%           .expectedFlux    = scalar expected flux for this target as calculated from the target magnitude; float
%           .cadence()       = # of cadences x 1 array of structures with the following fields:
%               .pixFlux     = # of pixels x 1 float 
% ***********************************************************************************************************************
%               .Cpixflux    = # of pixels x 1 float (OR cell array of # of pixels x # of pixels float)
% ************************* DOES NOT HANDLE COVARIANCE MATRICES IN Cpixflux YET *****************************************
%               .radius      = # of pixels x 1 float
%               .row         = # of pixels x 1 int
%               .col         = # of pixels x 1 int
%               .gapFlag     = # of pixels x 1 boolean indicating cadence gaps at the pixel-level, 1==gap, 0==no gap
%
%       .encircledEnergyStruct  = structure with the following fields
%            .polyOrder         = polynomial order of q(x) used in constrained fit; int [0,MAX_POLY_ORDER]
%            .eeFraction        = fraction of encircled energy included at eeRadius; float [0,1]
%            .EE_TARGET_LABEL   = label in tppInputStruct denoting target to be used for encircled enegry; string
%            .MAX_TARGETS       = maximum number of targets to process; int
%            .MAX_PIXELS        = maximum number of pixels per target; int
%            .SEED_RADIUS       = start fzero search at SEED_RADIUS; float [0,1]
%            .MIN_POLY_ORDER    = allowed maximum polynomial order is 0, polyOrder = -1 invokes automatic polynomial order
%                                 determination
%            .MAX_POLY_ORDER    = allowed maximum polynomial order - used in automatic polynomial order determination; int
%            .AIC_FRACTION      = fraction of cadecences used in automatic polynomial order determination; float  
%            .TARGET_P_ORDER    = polynomial order used to normalize pixel data on a per target basis; int
%            .MAX_RADIUS        = radius from target centroid (in pixels) used as normalization factor. Setting = 0 envokes
%                                 dynamic normalization
%            .PLOTS_ON          = enable diagnostic plots; boolean
%            .CONSTRAINED_COV_FACTOR 
%            .ADDITIVE_WHITE_NOISE_SIGMA
%            .ROBUST_LIMIT_FLAG
%            .ROBUST_FIT_WEIGHT_THRESHOLD
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

%disp(mfilename('fullpath'));


%% hard coded constants
degreesPerHour = (360/24);

%% Get number of target and cadences from the first pixel of the first target
numTargets = length(paDataStruct.targetStarDataStruct);
numCadences = length(paDataStruct.targetStarDataStruct(1).pixelDataStruct(1).values);

%% Encircled energy default parameters

MIN_POLY_ORDER              = -1;
MAX_POLY_ORDER              = 30;
DEFAULT_POLY_ORDER          = 7;
MIN_EE_FRACTION             = 0.40;
MAX_EE_FRACTION             = 0.98;
DEFAULT_EE_FRACTION         = 0.95;
MAX_TARGETS                 = 3000;
MAX_PIXELS                  = 200;
SEED_RADIUS                 = 0.6;
AIC_FRACTION                = 0.1;
EE_TARGET_LABEL             = 'PPA_STELLAR';
TARGET_P_ORDER              = 2;
MAX_RADIUS                  = 0;
PLOTS_ON                    = false;
CONSTRAINED_COV_FACTOR      = 0.001; 
ADDITIVE_WHITE_NOISE_SIGMA  = 1e-12;
ROBUST_THRESHOLD            = 0.05;
ROBUST_LIMIT_FLAG           = true;

%% build encircledEnergyStruct

% load defaults
encircledEnergyStruct = struct('polyOrder',DEFAULT_POLY_ORDER,...
                               'eeFraction',DEFAULT_EE_FRACTION,...
                               'EE_TARGET_LABEL',EE_TARGET_LABEL,...
                               'MAX_TARGETS',MAX_TARGETS,...
                               'MAX_PIXELS',MAX_PIXELS,...
                               'SEED_RADIUS',SEED_RADIUS,...
                               'MIN_POLY_ORDER',MIN_POLY_ORDER,...
                               'MAX_POLY_ORDER',MAX_POLY_ORDER,...
                               'AIC_FRACTION',AIC_FRACTION,...
                               'TARGET_P_ORDER',TARGET_P_ORDER,...
                               'MAX_RADIUS',MAX_RADIUS,...
                               'PLOTS_ON',PLOTS_ON,...
                               'CONSTRAINED_COV_FACTOR',CONSTRAINED_COV_FACTOR,...
                               'ADDITIVE_WHITE_NOISE_SIGMA',ADDITIVE_WHITE_NOISE_SIGMA,...
                               'ROBUST_FIT_WEIGHT_THRESHOLD',ROBUST_THRESHOLD,...
                               'ROBUST_LIMIT_FLAG',ROBUST_LIMIT_FLAG);


% update from paDataStruct.encircledEnergyConfigurationStruct if available
if(isfield(paDataStruct,'encircledEnergyConfigurationStruct') && isstruct(paDataStruct.encircledEnergyConfigurationStruct));
    S = paDataStruct.encircledEnergyConfigurationStruct;
    if(isfield(S,'polyOrder'));         encircledEnergyStruct.polyOrder                     = S.polyOrder;          end
    if(isfield(S,'fluxFraction'));      encircledEnergyStruct.eeFraction                    = S.fluxFraction;       end
    if(isfield(S,'targetLabel'));       encircledEnergyStruct.EE_TARGET_LABEL               = S.targetLabel;        end
    if(isfield(S,'maxTargets'));        encircledEnergyStruct.MAX_TARGETS                   = S.maxTargets;         end
    if(isfield(S,'maxPixels'));         encircledEnergyStruct.MAX_PIXELS                    = S.maxPixels;          end    
    if(isfield(S,'seedRadius'));        encircledEnergyStruct.SEED_RADIUS                   = S.seedRadius;         end
    if(isfield(S,'minPolyOrder'));      encircledEnergyStruct.MIN_POLY_ORDER                = S.minPolyOrder;       end    
    if(isfield(S,'maxPolyOrder'));      encircledEnergyStruct.MAX_POLY_ORDER                = S.maxPolyOrder;       end
    if(isfield(S,'aicFraction'));       encircledEnergyStruct.AIC_FRACTION                  = S.aicFraction;        end 
    if(isfield(S,'targetPolyOrder'));   encircledEnergyStruct.TARGET_P_ORDER                = S.targetPolyOrder;    end     
    if(isfield(S,'maxRadius'));         encircledEnergyStruct.MAX_RADIUS                    = S.maxRadius;          end  
    if(isfield(S,'plotsEnabled'));      encircledEnergyStruct.PLOTS_ON                      = S.plotsEnabled;       end   
    if(isfield(S,'covFactor'));         encircledEnergyStruct.CONSTRAINED_COV_FACTOR        = S.covFactor;          end   
    if(isfield(S,'whiteSigma'));        encircledEnergyStruct.ADDITIVE_WHITE_NOISE_SIGMA    = S.whiteSigma;         end  
    if(isfield(S,'robustThreshold'));   encircledEnergyStruct.ROBUST_FIT_WEIGHT_THRESHOLD   = S.robustThreshold;    end  
    if(isfield(S,'robustLimitEnabled'));encircledEnergyStruct.ROBUST_LIMIT_FLAG             = S.robustLimitEnabled; end  
    
    % update defaults
    EE_TARGET_LABEL             = encircledEnergyStruct.EE_TARGET_LABEL;                    %#ok<NASGU>
    MAX_TARGETS                 = encircledEnergyStruct.MAX_TARGETS;                        %#ok<NASGU>
    MAX_PIXELS                  = encircledEnergyStruct.MAX_PIXELS;                         %#ok<NASGU>
    SEED_RADIUS                 = encircledEnergyStruct.SEED_RADIUS;                        %#ok<NASGU>
    MIN_POLY_ORDER              = encircledEnergyStruct.MIN_POLY_ORDER; 
    MAX_POLY_ORDER              = encircledEnergyStruct.MAX_POLY_ORDER;
    AIC_FRACTION                = encircledEnergyStruct.AIC_FRACTION;                       %#ok<NASGU>
    TARGET_P_ORDER              = encircledEnergyStruct.TARGET_P_ORDER;                     %#ok<NASGU>
    MAX_RADIUS                  = encircledEnergyStruct.MAX_RADIUS;                         %#ok<NASGU>
    PLOTS_ON                    = encircledEnergyStruct.PLOTS_ON;                           %#ok<NASGU>
    CONSTRAINED_COV_FACTOR      = encircledEnergyStruct.CONSTRAINED_COV_FACTOR;             %#ok<NASGU>
    ADDITIVE_WHITE_NOISE_SIGMA  = encircledEnergyStruct.ADDITIVE_WHITE_NOISE_SIGMA;         %#ok<NASGU>
    ROBUST_FIT_WEIGHT_THRESHOLD = encircledEnergyStruct.ROBUST_FIT_WEIGHT_THRESHOLD;        %#ok<NASGU>
    ROBUST_LIMIT_FLAG           = encircledEnergyStruct.ROBUST_LIMIT_FLAG;                  %#ok<NASGU>
end




%% check for variable arguments - set defaults if unavailable              

% check variable arguments
arglist = cell2mat(varargin);

if(~isempty(arglist))                                               % at least one argument, first one is polyOrder
    encircledEnergyStruct.polyOrder = arglist(1);
    if(length(arglist) > 1)                                         % at least two arguments, second one is eeFraction
        encircledEnergyStruct.eeFraction = arglist(2);
        if(length(arglist) > 2)                                     % at least three arguments, third one is PLOTS_ON
            encircledEnergyStruct.PLOTS_ON = arglist(3);
        end
    end                                                             % arguments past the third are ignored
end

%% check variable input parameters - data type and in bounds

% polyOrder must be numeric and integer values
if(~isnumeric(encircledEnergyStruct.polyOrder))
    encircledEnergyStruct.polyOrder = DEFAULT_POLY_ORDER;
else
    encircledEnergyStruct.polyOrder = floor(encircledEnergyStruct.polyOrder);
    if(encircledEnergyStruct.polyOrder < MIN_POLY_ORDER)
        encircledEnergyStruct.polyOrder = MIN_POLY_ORDER;                       
    else if(encircledEnergyStruct.polyOrder > MAX_POLY_ORDER)
        encircledEnergyStruct.polyOrder = MAX_POLY_ORDER;
        end
    end
end

% eeFraction must be numeric
if(~isnumeric(encircledEnergyStruct.eeFraction))                    
    encircledEnergyStruct.eeFraction = DEFAULT_EE_FRACTION;
elseif(encircledEnergyStruct.eeFraction < MIN_EE_FRACTION)
    encircledEnergyStruct.eeFraction = MIN_EE_FRACTION;
elseif(encircledEnergyStruct.eeFraction > MAX_EE_FRACTION)
    encircledEnergyStruct.eeFraction = MAX_EE_FRACTION;
end

% PLOTS_ON must be logical
if(~islogical(encircledEnergyStruct.PLOTS_ON))
    if(isnumeric(encircledEnergyStruct.PLOTS_ON))
        encircledEnergyStruct.PLOTS_ON = logical(encircledEnergyStruct.PLOTS_ON);
    else
        encircledEnergyStruct.PLOTS_ON = PLOTS_ON;
    end
end

%% select encircled energy targets
% make list of encircled energy targets by filtering labels from paDataStruct.targetStarDataStruct
% if 'labels' field is not available, use all available targets to build list
eeTargets = zeros(MAX_TARGETS,1);
numeeTargets = 0;

if(isfield(paDataStruct.targetStarDataStruct,'labels'))
    for iTarget=1:numTargets
        if(ismember(EE_TARGET_LABEL,paDataStruct.targetStarDataStruct(iTarget).labels))
            numeeTargets=numeeTargets+1;
            eeTargets(numeeTargets)=iTarget;
        end
    end
    if(numeeTargets>0);
        eeTargets = eeTargets(1:numeeTargets);
    end
else
    eeTargets=1:numTargets;
    numeeTargets=length(eeTargets);
end               

%% create output structure

eeTempStruct=struct('targetStar',repmat(struct('gapList',[],...
                                               'expectedFlux',0,... 
                                               'cadence',repmat(struct('pixFlux',zeros(MAX_PIXELS,1),...
                                                                        'Cpixflux',zeros(MAX_PIXELS,1),...
                                                                        'radius',zeros(MAX_PIXELS,1),...
                                                                        'row',zeros(MAX_PIXELS,1),...
                                                                        'col',zeros(MAX_PIXELS,1),...
                                                                        'gapFlag',zeros(MAX_PIXELS,1)...
                                                                        ),numCadences,1)...
                                                ),numeeTargets,1),...
                    'encircledEnergyStruct',encircledEnergyStruct);
            
%% ADD 8/7/2009 - KSOC 356 
%% loop through cadences to get centroids from motion polynomials

% preallocate space for data and gap indicators
rowCentroid = zeros(numCadences,numeeTargets);
colCentroid = zeros(numCadences,numeeTargets);
rowCentroidGaps = false(numCadences,numeeTargets);
colCentroidGaps = false(numCadences,numeeTargets);

% unavoidable loop because motion polynomials must be evaluated one cadence at a time
for iCadence = 1:numCadences
    raDegrees = [paResultsStruct.targetStarResultsStruct.raHours].*degreesPerHour;
    decDegrees = [paResultsStruct.targetStarResultsStruct.decDegrees];
    
    if(~isempty(paDataStruct.motionPolyStruct) && paDataStruct.motionPolyStruct(iCadence).rowPolyStatus)
        rowCoord = weighted_polyval2d(raDegrees(:),decDegrees(:),paDataStruct.motionPolyStruct(iCadence).rowPoly);
        colCoord = weighted_polyval2d(raDegrees(:),decDegrees(:),paDataStruct.motionPolyStruct(iCadence).colPoly);
        rowCentroid(iCadence,:) = rowCoord(:)';
        colCentroid(iCadence,:) = colCoord(:)';
    else
        rowCentroidGaps(iCadence,:) = true(1,numeeTargets);
        colCentroidGaps(iCadence,:) = true(1,numeeTargets);
    end    
end     
     
%% loop through selected ee targets

for iTarget=1:numeeTargets
    
    % pass expectedFlux value from paResultsStruct.targetStarResultsStruct
    % if available otherwise set eeTempStruct.targetStar.expectedFlux = 0
    if(isfield(paDataStruct.targetStarDataStruct,'expectedFlux'))
        eeTempStruct.targetStar(iTarget).expectedFlux = paDataStruct.targetStarDataStruct(iTarget).expectedFlux;
    end

% Superceeded by KSOC-356    
    
% % ADD 4/29/09 - KSOC-175    
%     % read centroid for this target over all cadences  
%     % column vectors: row#==cadence  
%     % use the prf centroid if ppaTargetPrfCentroidingEnabled is true, otherwise use the flux-weighted centroid
%     if(paDataStruct.paConfigurationStruct.ppaTargetPrfCentroidingEnabled)
%         r0 = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.rowTimeSeries.values];
%         r0Gaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.rowTimeSeries.gapIndicators];
%         c0 = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.columnTimeSeries.values];
%         c0Gaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.columnTimeSeries.gapIndicators];        
%     else
%         r0 = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.rowTimeSeries.values];
%         r0Gaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.rowTimeSeries.gapIndicators];
%         c0 = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.columnTimeSeries.values];
%         c0Gaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.columnTimeSeries.gapIndicators];
%     end


% Added 8/7/09 - KSOC-356
    r0 = rowCentroid(:,iTarget);
    c0 = colCentroid(:,iTarget);
    r0Gaps = rowCentroidGaps(:,iTarget);
    c0Gaps = colCentroidGaps(:,iTarget);
% %%

    % make sure centroids and gapIndicators are column vectors (nCadences x 1)
    r0 = r0(:);
    c0 = c0(:);
    centroidGaps = r0Gaps | c0Gaps;
    centroidGaps = centroidGaps(:);      
    
    
% REMOVE 4/29/09 - KSOC-175    
%     % read centroid for this target over all cadences  
%     % column vectors: row#==cadence  
%     % use the prf centroid if it is available, otherwise use the flux-weighted centroid
%     r0fluxWeighted = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.rowTimeSeries.values];
%     r0fluxWeightedGaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.rowTimeSeries.gapIndicators];
%     r0prf = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.rowTimeSeries.values];
%     r0prfGaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.rowTimeSeries.gapIndicators];
% 
%     r0 = ~r0prfGaps .* r0prf + r0prfGaps .* r0fluxWeighted;    
%     r0 = r0(:);  
%   
%     c0fluxWeighted = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.columnTimeSeries.values];
%     c0fluxWeightedGaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).fluxWeightedCentroids.columnTimeSeries.gapIndicators];
%     c0prf = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.columnTimeSeries.values];
%     c0prfGaps = [paResultsStruct.targetStarResultsStruct(eeTargets(iTarget)).prfCentroids.columnTimeSeries.gapIndicators];
% 
%     c0 = ~c0prfGaps .* c0prf + c0prfGaps .* c0fluxWeighted;    
%     c0 = c0(:);
%     
%     % get centroid gap indicators ( nCadences x 1 )
%     % centroids should be gapped only if both flux-weighted and prf are gapped
%     rGaps = r0fluxWeightedGaps & r0prf;
%     cGaps = c0fluxWeightedGaps & c0prf; 
%     centroidGaps = rGaps | cGaps;
%     centroidGaps = centroidGaps(:);
   
    % build matrices out of squeezed data from pixelTimeSeriesStruct
    % list of fields
    S = fieldnames(paDataStruct.targetStarDataStruct(eeTargets(iTarget)).pixelDataStruct);
    % numFields x numPixels, cell
    Y = squeeze(struct2cell(paDataStruct.targetStarDataStruct(eeTargets(iTarget)).pixelDataStruct));   
    
    % find row index in Y for labels in pixelTimeSeriesStruct - column of Y corresponds to pixel number 
    iTimeseries     = find(strcmp(S,'values'));
    iUncertainties  = find(strcmp(S,'uncertainties'));
    iRow            = find(strcmp(S,'ccdRow'));
    iCol            = find(strcmp(S,'ccdColumn'));
    iGap            = find(strcmp(S,'gapIndicators'));    
    
    RR = cell2mat(Y(iRow,:));           %#ok<FNDSB> % row vector: col==pixel
    CC = cell2mat(Y(iCol,:));           %#ok<FNDSB> % row vector: col==pixel
   
    % note: length(r0) = length(c0) = number of cadences
    %       length(RR) = length(CC) = number of pixels    
    nCad = length(r0);
    nPix = length(RR);
    
    % col * row --> (cadences x pixels)
    % ROW and COL for each pixel at each cadence 
    ROW = ones(nCad,1) * RR;      
    COL = ones(nCad,1) * CC;
    % centroid (r0,c0) for each pixel at each cadence
    R0 = r0 * ones(1,nPix);
    C0 = c0 * ones(1,nPix);

    % calculate radius for each pixel at each cadence
    % this gives the matrix form of radial distance from centroid: row==cadence, col==pixel
    RP = sqrt((ROW - R0).^2 + (COL - C0).^2);   
    
    
    % construct matrix form of time series data for each pixel (row == cadence, column == pixel)
    PP = cell2mat(Y(iTimeseries,:));                %#ok<FNDSB>
    UU = cell2mat(Y(iUncertainties,:));             %#ok<FNDSB>
    GG = cell2mat(Y(iGap,:));                       %#ok<FNDSB>
    
    % apply cetroid gap timeseries to pixel gaps
    centroidGapArray = repmat(centroidGaps, 1, size(GG,2));
    GG = GG | centroidGapArray;
    
%     % construct gap indicator time series for each pixel (row == cadence, column == pixel)
%     % from cadence gapList provided in tppInputStruct.targetStarStruct.pixelTimeSeriesStruct.gapList()
%     GG = zeros(nCad,nPix);
%     for iTimeseries=1:nPix
%        GG(:,iTimeseries) = ismember(1:nCad,Y{iGap,iTimeseries});
%     end
    
    % concatenate matrices
    ZZ = [PP;UU;RP;ROW;COL;GG]; 
    
    % transpose and make into 1x6*numCadences cells of numPixelsx1 matrices
    [zzRows, zzCols] = size(ZZ);    
    ZZcell = mat2cell(ZZ',zzCols,ones(zzRows,1));   
    
    % make the 1xnumCadences cell array into numCadencesx6 where each
    % column now corresponds to an eeTempStruct output field
    ZZcell = reshape(ZZcell,nCad,6);         
                    
    % parse into appropriate fields along the column dimension and store
    eeTempStruct.targetStar(iTarget).cadence = ...
        cell2struct(ZZcell,{'pixFlux','Cpixflux','radius','row','col','gapFlag'},2);
    
%     % copy target level gap list from tppInputStruct  - make sure it is a column
%     eeTempStruct.targetStar(iTarget).gapList = tppInputStruct.targetStarStruct(eeTargets(iTarget)).gapList(:);

    % apparently there are no such thing as a gap at the target level in PA
    % set target level gap list to empty in eeTempStruct
     eeTempStruct.targetStar(iTarget).gapList = [];
    
end


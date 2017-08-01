function [eeTempStruct,inputError] = generate_eeTempStruct_from_tppInputStruct(tppInputStruct,varargin)

%%   function [eeTempStruct, inputError] = generate_eeTempStruct_from_tppInputStruct(tppInputStruct,varargin)
%
%   Generate a temporary structure eeTempStruct from tppInputStruct to be
%   used by encircledEnergy.m. Check for existance and range of required
%   fields, calculate distance from target centroid for each pixel on a
%   cadence by cadence basis.
%
%	INPUT:  Valid tppInputStruct with the following fields:
%           tppInputStruct
%                .encircledEnergyStruct
%                   .polyOrder           = order of polynomial fit; polyOrder = -1 invokes automatic polynomial order determination; int
%                   .eeFraction          = float
%                   -------------------- (optional) -----------------------
%                   .EE_TARGET_LABEL   = label in tppInputStruct denoting target to be used for encircled enegry; string
%                   .MAX_TARGETS       = maximum number of targets to process; int
%                   .MAX_PIXELS        = maximum number of pixels per target; int
%                   .SEED_RADIUS       = start fzero search at SEED_RADIUS; float [0,1]
%                   .MAX_POLY_ORDER    = allowed maximum polynomial order - used in automatic polynomial order determination; int
%                   .AIC_FRACTION      = fraction of cadecences used in automatic polynomial order determination; float  
%                   .TARGET_P_ORDER    = polynomial order used to normalize pixel data on a per target basis; int 
%                   .MAX_RADIUS        = radius from target centroid (in pixels) used as normalization factor. 
%                                        Setting = 0 envokes dynamic normalization; float
%                   .PLOTS_ON          = enable diagnostic plots; boolean
%                   .CONSTRAINED_COV_FACTOR 
%                   .ADDITIVE_WHITE_NOISE_SIGMA
%                   .ROBUST_FIT_WEIGHT_THRESHOLD
%                    -------------------- (optional) -----------------------
%                .targetStarStruct()
%                    .labels           = cell array of labels
%                    .expectedFlux     = expected flux from this target; float
%                    .rowCentroid      = computed centroid row
%                    .colCentroid      = computed centroid column
%                    .gapList          = # of gaps x 1 array containing the indices of cadence gaps at the target-level 
%                    .pixelTimeSeriesStruct() = structure for each pixel in target with the following fields
%                        .timeSeries     = # of cadences x 1 array containing pixel brightness time series in electrons
%                        .uncertainties  = # of cadences x 1 array containing pixel uncertainty time series
%                        .row            = row of this pixel
%                        .column         = column of this pixel
%                        .gapList        = # of gaps x 1 array containing the indices of cadence gaps at the pixel-level
%
%           VARIABLE INPUT ARGUMENTS
%           varargin(1) =   If available, polyOrder, order of polynomial used in eeRadius fit. 
%                           If polyOrder = -1 --> invoke polynomial order selection is based on minimizing
%                           the AIC metric for a randomly selected AIC_FRACTION of cadences, then apply that
%                           polyOrder to all other cadences
%           varargin(2) =   If available, eeFraction == fraction of total encircled energy included within eeRadius
%           varargin(3) =   If available, plotOn --> boolean to turn on plots during processing; 1 == turn plots on
%
%
%   OUTPUT:
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

%% Check tppInputStruct

inputError=0;

% is it an eeTempStruct already?
[itsAneeTempStruct, eeTempStruct] = iseeTempStruct(tppInputStruct);

if(~itsAneeTempStruct)
    % check field structure for tppInputStruct form
    % Minimum required fields in the top level tppInputStruct
    if(~isfield(tppInputStruct,'targetStarStruct') || ...
             ~isfield(tppInputStruct.targetStarStruct,'rowCentroid') || ...
             ~isfield(tppInputStruct.targetStarStruct,'colCentroid') || ...
             ~isfield(tppInputStruct.targetStarStruct,'gapList') || ...
             ~isfield(tppInputStruct.targetStarStruct,'pixelTimeSeriesStruct') ||...
       ~isfield(tppInputStruct,'encircledEnergyStruct') ||...
             ~isfield(tppInputStruct.encircledEnergyStruct,'polyOrder') ||...
             ~isfield(tppInputStruct.encircledEnergyStruct,'eeFraction'));

        inputError=1;                       % set error flag, warn and return empty structure
        eeTempStruct=struct('');

        msgString   = ['PA:',mfilename,':generate_eeTempStruct_from_tppInputStruct:tppInputStruct incomplete at "targetStarStruct" ', ...
                        'or "encircledEnergyStruct" level'];
        warnString  = 'Error in input data structure';
        warning( msgString, warnString );

        return;
    end

    % Must have at least one target
    numTargets  = length(tppInputStruct.targetStarStruct);
    if(numTargets==0)    
        inputError=1;               % set error flag and return empty structure
        eeTempStruct=struct('');
        return;
    end

    % targetStarStruct must have a field pixelTimeSeriesStruct which must have
    % these minimum sub-fields
    if(~isfield(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct,'timeSeries') || ...
             ~isfield(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct,'uncertainties') || ...
             ~isfield(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct,'row') || ...
             ~isfield(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct,'column') || ...
             ~isfield(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct,'gapList'))

        inputError=1;               % set error flag, warn and return empty structure
        eeTempStruct=struct('');

        msgString   = ['PA:',mfilename,':generate_eeTempStruct_from_tppInputStruct:tppInputStruct incomplete at "pixelTimeSeriesStruct" level'];
        warnString  = 'Error in input data structure';
        warning( msgString, warnString );

        return;
    end

    % Must have at least one cadence
    numCadences = length(tppInputStruct.targetStarStruct(1).pixelTimeSeriesStruct(1).timeSeries);    
    if(numCadences==0)    
        inputError=1;               % set error flag and return empty structure
        eeTempStruct=struct('');

        msgString   = ['PA:',mfilename,':generate_eeTempStruct_from_tppInputStruct:tppInputStruct contains zero cadences'];
        warnString  = 'Error in input data structure';
        warning( msgString, warnString );

        return;
    end
end

%% Use parameters from tppInputStruct.encircledEnergyStruct or load with defaults

% copy encircledEnergyStruct from tppInputStruct
encircledEnergyStruct = tppInputStruct.encircledEnergyStruct;

% if encircledEnergyStruct fields don't exist or are out of range, set defaults and/or create fields

if(isfield(encircledEnergyStruct,'MIN_POLY_ORDER'))
    MIN_POLY_ORDER = encircledEnergyStruct.MIN_POLY_ORDER;
else
    encircledEnergyStruct.MIN_POLY_ORDER = MIN_POLY_ORDER;
end

if(isfield(encircledEnergyStruct,'MAX_POLY_ORDER'))
    MAX_POLY_ORDER = encircledEnergyStruct.MAX_POLY_ORDER;
else
    encircledEnergyStruct.MAX_POLY_ORDER = MAX_POLY_ORDER;
end

if(isfield(encircledEnergyStruct,'MAX_TARGETS'))
     MAX_TARGETS = encircledEnergyStruct.MAX_TARGETS;
else     
     encircledEnergyStruct.MAX_TARGETS = MAX_TARGETS;
end

if(isfield(encircledEnergyStruct,'MAX_PIXELS'))
     MAX_PIXELS = encircledEnergyStruct.MAX_PIXELS;
else     
     encircledEnergyStruct.MAX_PIXELS = MAX_PIXELS;
end 

if(isfield(encircledEnergyStruct,'SEED_RADIUS'))
     SEED_RADIUS = encircledEnergyStruct.SEED_RADIUS; %#ok<NASGU>
else     
     encircledEnergyStruct.SEED_RADIUS = SEED_RADIUS;
end

if(isfield(encircledEnergyStruct,'AIC_FRACTION'))
    AIC_FRACTION = encircledEnergyStruct.AIC_FRACTION; %#ok<NASGU>
else
    encircledEnergyStruct.AIC_FRACTION = AIC_FRACTION;
end

if(isfield(encircledEnergyStruct,'EE_TARGET_LABEL'))
    EE_TARGET_LABEL = encircledEnergyStruct.EE_TARGET_LABEL;
else
    encircledEnergyStruct.EE_TARGET_LABEL = EE_TARGET_LABEL;
end

if(isfield(encircledEnergyStruct,'TARGET_P_ORDER'))
    TARGET_P_ORDER = encircledEnergyStruct.TARGET_P_ORDER; %#ok<NASGU>
else
    encircledEnergyStruct.TARGET_P_ORDER = TARGET_P_ORDER;
end

if(isfield(encircledEnergyStruct,'MAX_RADIUS'))
    MAX_RADIUS = encircledEnergyStruct.MAX_RADIUS; %#ok<NASGU>
else
    encircledEnergyStruct.MAX_RADIUS = MAX_RADIUS;
end

if(~isfield(encircledEnergyStruct,'PLOTS_ON'))
    encircledEnergyStruct.PLOTS_ON = PLOTS_ON;
end

if(~isfield(encircledEnergyStruct,'CONSTRAINED_COV_FACTOR'))
    encircledEnergyStruct.CONSTRAINED_COV_FACTOR = CONSTRAINED_COV_FACTOR;
end

if(~isfield(encircledEnergyStruct,'ADDITIVE_WHITE_NOISE_SIGMA'))
    encircledEnergyStruct.ADDITIVE_WHITE_NOISE_SIGMA = ADDITIVE_WHITE_NOISE_SIGMA;
end

if(~isfield(encircledEnergyStruct,'ROBUST_FIT_WEIGHT_THRESHOLD'))
    encircledEnergyStruct.ROBUST_FIT_WEIGHT_THRESHOLD = ROBUST_THRESHOLD;
end

if(~isfield(encircledEnergyStruct,'ROBUST_LIMIT_FLAG'))
    encircledEnergyStruct.ROBUST_LIMIT_FLAG = ROBUST_LIMIT_FLAG;
end


%% check for variable arguments - set defaults if unavailable              

% check variable arguments
arglist = cell2mat(varargin);

if(~isempty(arglist))                                                % empty list, use passed values
    encircledEnergyStruct.polyOrder = arglist(1);                       % at least one argument, first one is polyOrder
    if(~isnumeric(encircledEnergyStruct.polyOrder))                     % polyOrder must be numeric
        encircledEnergyStruct.polyOrder = DEFAULT_POLY_ORDER;
    else
        encircledEnergyStruct.polyOrder = floor(encircledEnergyStruct.polyOrder);	% and integer value
        if(encircledEnergyStruct.polyOrder < MIN_POLY_ORDER)
            encircledEnergyStruct.polyOrder = MIN_POLY_ORDER;       % if out of valid range, set to closest endpoint
        else if(encircledEnergyStruct.polyOrder > MAX_POLY_ORDER)
            encircledEnergyStruct.polyOrder = MAX_POLY_ORDER;
            end
        end
    end
    if(length(arglist) > 1)                                         % at least two arguments, second one is eeFraction
        encircledEnergyStruct.eeFraction = arglist(2);
        if(~isnumeric(encircledEnergyStruct.eeFraction))                  % eeFraction must be numeric
            encircledEnergyStruct.eeFraction = DEFAULT_EE_FRACTION;
        elseif(encircledEnergyStruct.eeFraction < MIN_EE_FRACTION)
            encircledEnergyStruct.eeFraction = MIN_EE_FRACTION;       % if out of valid range, set to closest endpoint
        elseif(encircledEnergyStruct.eeFraction > MAX_EE_FRACTION)
            encircledEnergyStruct.eeFraction = MAX_EE_FRACTION;
        end
    end
    if(length(arglist) > 2)                                         % at least three arguments, third one is PLOTS_ON
        encircledEnergyStruct.PLOTS_ON = arglist(3);
        if(~islogical(encircledEnergyStruct.PLOTS_ON))                  % convert to logical if not already
            if(isnumeric(encircledEnergyStruct.PLOTS_ON))
                encircledEnergyStruct.PLOTS_ON = logical(encircledEnergyStruct.PLOTS_ON);
            else
                encircledEnergyStruct.PLOTS_ON = DEFAULT_PLOTS_ON;
            end
        end
    end
end
% ignore any variable input arguments past the second one

% if the input is already an eeTempStruct, update the encircledEnergyStruct field and return
if(itsAneeTempStruct)
    eeTempStruct.encircledEnergyStruct = encircledEnergyStruct;
    return;
end

%% select encircled energy targets
% make list of encircled energy targets by filtering labels from tppInputStruct.targetStarStruct
% if 'labels' field is not available, use all available targets to build list
eeTargets = zeros(MAX_TARGETS,1);
numeeTargets = 0;
if(isfield(tppInputStruct.targetStarStruct,'labels'))
    for iTarget=1:numTargets
%        if(strcmp(tppInputStruct.targetStarStruct(iTarget).labels,EE_TARGET_LABEL)~=...
        if(ismember(EE_TARGET_LABEL,tppInputStruct.targetStarStruct(iTarget).labels))
            numeeTargets=numeeTargets+1;
            eeTargets(numeeTargets)=iTarget;
        end
    end
    % trim excess zeros
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
            

%% loop through selected ee targets
 

for iTarget=1:numeeTargets
    
    % pass expectedFlux value from targetStarStruct if available -
    % otherwise eeTemp.targetStar.expectedFlux = 0 from seed
    if(isfield(tppInputStruct.targetStarStruct,'expectedFlux'))
        eeTempStruct.targetStar(iTarget).expectedFlux = tppInputStruct.targetStarStruct(iTarget).expectedFlux;
    end
    
    % read centroid for this target over all cadences    
    r0 = tppInputStruct.targetStarStruct(eeTargets(iTarget)).rowCentroid;      % column vector: row#==cadence
    c0 = tppInputStruct.targetStarStruct(eeTargets(iTarget)).colCentroid;      % column vector: row#==cadence
    
    % if r0,c0 are not column vectors - make them columns 
    [dimRow, dimCol] = size(r0);if(dimRow < dimCol);r0=r0';end
    [dimRow, dimCol] = size(c0);if(dimRow < dimCol);c0=c0';end
    
    % build matrices out of squeezed data from pixelTimeSeriesStruct
    % list of fields
    S = fieldnames(tppInputStruct.targetStarStruct(eeTargets(iTarget)).pixelTimeSeriesStruct);
    % numFields x numPixels, cell
    Y = squeeze(struct2cell(tppInputStruct.targetStarStruct(eeTargets(iTarget)).pixelTimeSeriesStruct));   
    
    % find row index in Y for labels in pixelTimeSeriesStruct - column of Y
    % corresponds to pixel number 
    iTimeseries     = find(strcmp(S,'timeSeries'));
    iUncertainties  = find(strcmp(S,'uncertainties'));
    iRow            = find(strcmp(S,'row'));
    iCol            = find(strcmp(S,'column'));
    iGap            = find(strcmp(S,'gapList'));    
    
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
    
    % construct gap indicator time series for each pixel (row == cadence, column == pixel)
    % from cadence gapList provided in tppInputStruct.targetStarStruct.pixelTimeSeriesStruct.gapList()
    GG = zeros(nCad,nPix);
    for iTimeseries=1:nPix
       GG(:,iTimeseries) = ismember(1:nCad,Y{iGap,iTimeseries});
    end
    
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
    
    % copy target level gap list from tppInputStruct  - make sure it is a column
    eeTempStruct.targetStar(iTarget).gapList = tppInputStruct.targetStarStruct(eeTargets(iTarget)).gapList(:);
    
end


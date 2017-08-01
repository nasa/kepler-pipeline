function [Cv, gapIndicators, pouStruct] = retrieve_cal_pixel_covariance( row, col, cadenceList, pouConfigStruct, pouStruct )
%**************************************************************************
% function [Cv, gapIndicators, pouStruct] = ...
%     retrieve_cal_pixel_covariance( row, col, cadenceList, ...
%         pouConfigStruct, pouStruct )
%**************************************************************************
% This function returns the covariance matrix (Cv) for the requested pixels
% at the row-column pair for each cadence in cadenceList. The ordering
% along the row and column dimension of Cv matches the ordering of the
% input row and col. Ordering along the cadence dimension of Cv matches the
% ordering in the input cadenceList. The dimensions of Cv are (cadence,
% row-col pair, row-col pair). Gap indicators for Cv are also returned in a
% 2D matrix - column == row-col pair, row == cadence. Any  gapped row-col
% pairs are assigned values of zero across that index for the row-col
% dimensions of the covariance matrix.
% 
% INPUT:    row                     = [double];list of pixel row
%                                     indices;nPixels x 1 
%           col                     = [double];list of pixel column
%                                     indices;nPixels x 1 
%           cadenceList             = [double];list of absolute cadence
%                                     numbers;nCadences x 1 
%           pouConfigStruct         = structure containing the following
%                                     configuration parameters: 
%                 cadenceNumbers                [int];nCadences x 1
%                 inputUncertaintiesFileName    [char]
%                 calPouFileRoot                [char]
%                 pouInterpMethod               [char] (default 'linear')
%                 pouDecimationEnabled          [logical] (default true)
%                 pouPixelChunkSize             [int] (default 2500)
%                 pouEnabled                    [logical] 
%                 pouCompressionEnabled         [logical]
%                 pouCadenceChunkSize           [int]
%                 pouInterpDecimation           [int]
%                 debugLevel                    [int]
%                 gapWarningThrown              [logical]
%           pouStruct 
%                 calTransformStruct    = [struct or cell array of
%                                         structs]; Contains error
%                                         propagation structures from CAL.
%                                         These will typically be a series
%                                         of deciamted pou structures but
%                                         may be a single entry containg
%                                         the full pou structure. May be
%                                         empty. If pouStruct is empty the
%                                         necessary structure(s) will be
%                                         loaded from local files.
%                 gapWarningThrown      = [logical]; This flag is used
%                                         locally to control messaging. The
%                                         gap filled cadence warning needs
%                                         to be thrown only on the first
%                                         call of a newly initialized
%                                         pouStruct. All other calls
%                                         generate the same condition.
% OUTPUT:   Cv                      = [double];covariance matrix time
%                                     series;nCadences x nPixels x nPixels 
%           gapIndicators           = [logical];logical gap indicators.
%                                     true == row, column pair not found in
%                                     cal errorPropStruct;nCadences x nPixels 
%           pouStruct               = Cell array containing error
%                                     propagation structures from CAL. This
%                                     will either be the pouStruct passed
%                                     in throught the inputs or one
%                                     populated by loading local files if
%                                     the input pouStruct was empty.
%
%
% Due to memory limitations in PA, covariances are only retrieved on
% decimated cadences. This is done by decimating the incoming CAL
% uncertainties information contained in the  on the first call to PA in
% POU blob on the first call to PA and saving that decimated information in
% local files decimatedCalPou#.mat where # = the relative one based POU
% blob index. Each decimated blob file contains the following variables:
%
%               calTransformStruct      = decompressed, expanded and
%                                         decimated errorPropStruct array 
%               compressedData          = empty
%               absoluteFirstCadence    = starting absolute cadence number
%               absoluteLastCadence     = ending absolute cadence number
%               decimatedRelativeIndices= relative cadences represented in
%                                         calTransformStruct 
%
% This function also contains support for using the full CAL uncertainties
% blobs rather than the decimated version however the full version is never
% used in prcatice. The inputUncertaintiesFileName is local storage for the
% full CAL unceratinties blobs and contains the following variables:
%
%       calUncertaintiesStruct          nBlobs x 1
%               calTransformStruct      compressed and minimized
%                                       errorPropStruct array 
%               compressedData          = compressed data for calTransformStruct
%               absoluteFirstCadence    = starting absolute cadence number
%               absoluteLastCadence     = ending absolute cadence number
%       calUncertaintyGapIndicators = gap indicators corresponding to the
%                                     calUncertaintyIndices 
%       calUncertaintyIndices       = nCadences x 1 list of indices
%                                     referencing one of the uniqueBlobIndices 
%       uniqueBlobIndices           = n x 1 array of blobIndices - the
%                                     position in this array corresponds to  
%                                     the position of the related
%                                     calUncertaintiesStruct in the array 
%**************************************************************************
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


% set boolean
loadPouFile = isempty(pouStruct);

% extract calPou filename root
calPouFileRoot = pouConfigStruct.calPouFileRoot;

% check cadenceList input
if isempty(cadenceList)
    error(['PA:',mfilename,':invalidCadenceList'],'Input cadenceList cannot be empty.');
elseif any(cadenceList < pouConfigStruct.cadenceNumbers(1)) || any(cadenceList > pouConfigStruct.cadenceNumbers(end))
    error(['PA:',mfilename,':invalidCadenceList'],'Input cadenceList contains cadence numbers outside the current unit of work.');
else
    cadenceList = cadenceList(:);
    nCadences = length(cadenceList);
%     uniqueCadenceList = unique(cadenceList);
end

% check row/col input
if ~isvector(row) || ~isvector(col) || length(row) ~= length(col) || isempty(row)
    error(['PA:',mfilename,':invalidRowOrColList'],'Row and column input must be non-empty equal length vectors.');
else
    row = row(:);
    col = col(:);
    nPixels = length(row);
end

% a message!
if pouConfigStruct.debugLevel > 0
    display(['Retrieving covariance for ',num2str(length(row)),' pixels over ',num2str(length(cadenceList)),' cadences...']);
end

% allocate space for Cv and gapIndicators
if pouConfigStruct.pouDecimationEnabled
    Cv = zeros(nCadences+1,nPixels,nPixels);
    gapIndicators = zeros(nCadences+1,nPixels);
else
    Cv = zeros(nCadences,nPixels,nPixels);
    gapIndicators = zeros(nCadences,nPixels);
end


% initialize indices and counters and storage
iLoop = 0;
numGappedCadencesUsed = 0;
processedCadences = [];

% load unique pou indices
p = load(pouConfigStruct.inputUncertaintiesFileName,'uniqueBlobIndices');

% loop over uniqueBlobIndices to create the array of covariance matrices spanning cadenceList
for iBlob = p.uniqueBlobIndices(:)'
    
    if pouConfigStruct.pouDecimationEnabled
        % use deciamted pou struct       
        if loadPouFile
            % load the decimated file
            varFileName = [calPouFileRoot,num2str(iBlob),'.mat'];
            load(varFileName);
            % populate local pouStruct - one cell entry for each decimated blob
            pouStruct.calTransformStruct{iBlob} = decimatedCalPou;
            pouStruct.gapWarningThrown = false;
        else
            decimatedCalPou = pouStruct.calTransformStruct{iBlob};
        end

        % find the cadences covered by this blob and extract calTransofrmStruct
        firstPouCadence     = decimatedCalPou.absoluteFirstCadence;
        lastPouCadence      = decimatedCalPou.absoluteLastCadence;
        relativePouCadences = decimatedCalPou.decimatedRelativeIndices;
        if any(cadenceList >= firstPouCadence & cadenceList <= lastPouCadence)            
            relativeCadenceList = cadenceList(cadenceList >= firstPouCadence & cadenceList <= lastPouCadence) - firstPouCadence + 1;            
            startIndex = max([1, find(relativePouCadences > min(relativeCadenceList), 1) - 1]);
            stopIndex  = min([length(relativePouCadences), find(relativePouCadences > max(relativeCadenceList), 1) - 1]);
            cadencesToProcess = relativePouCadences(startIndex:stopIndex) + firstPouCadence - 1;
            processedCadences = [processedCadences;cadencesToProcess];                                              %#ok<AGROW>
            S = decimatedCalPou.calTransformStruct(:,startIndex:stopIndex);
            clear decimatedCalPou;
        else
            S = [];
        end
        
    else
        % use full pou struct
        if loadPouFile
            % load full pou from file
            s = load(pouConfigStruct.inputUncertaintiesFileName,'calUncertaintiesStruct');
            % populate local pouStruct
            pouStruct.calTransformStruct = s;
            pouStruct.gapWarningThrown = false;
            % reset load flag since this file contains all the blob information
            loadPouFile = false;
        else
            s = pouStruct.calTransformStruct;
        end

        % find the cadences covered by this blob and extract calTransofrmStruct
        firstPouCadence = s.calUncertaintiesStruct(iBlob).absoluteFirstCadence;
        lastPouCadence  = s.calUncertaintiesStruct(iBlob).absoluteLastCadence;
        if any(cadenceList >= firstPouCadence & cadenceList <= lastPouCadence)            
            relativeCadenceList = cadenceList(cadenceList >= firstPouCadence & cadenceList <= lastPouCadence) - firstPouCadence + 1;            
            cadencesToProcess = relativeCadenceList + firstPouCadence - 1;
            processedCadences = [processedCadences;cadencesToProcess];                                              %#ok<AGROW>
            S = s.calUncertaintiesStruct(iBlob).calTransformStruct;
            C = s.calUncertaintiesStruct(iBlob).compressedData;
            clear calUncertaintiesStruct;
            S = expand_errorPropStruct(S, C, relativeCadenceList);
        else
            S = [];
        end
    end
    
    % update covariance matrix
    for iCadence = 1:size(S,2)        
        iLoop = iLoop + 1;
        % get Cv for current uniqueCadence
        [Cv(iLoop,:,:), gapIndicators(iLoop,:), gapFilledUsed] = ...
            get_pixel_covariance_matrix( S(:,iCadence), row, col, pouConfigStruct.pouPixelChunkSize );        
        % count gap filled cadences used
        if gapFilledUsed
            numGappedCadencesUsed = numGappedCadencesUsed + 1;
        end
    end    
    % release memory
    clear S C;
end

% trim arrays
Cv = Cv(1:iLoop,:,:);
gapIndicators = gapIndicators(1:iLoop,:);

% throw warning if any gap filled primitives were used
if numGappedCadencesUsed > 0 && ~pouStruct.gapWarningThrown
    disp(['PA:',mfilename,': ',num2str(numGappedCadencesUsed),...
        ' gap filled cadences used in interpolation of covariance over ',...
        num2str(nCadences),' cadences.']);
    pouStruct.gapWarningThrown = true;
end

% set the output arrays - if only one unique cadence was retrieved, copy result over nCadences else interpolate over cadences 
if iLoop == 1
    Cv = repmat(Cv(1,:,:), [nCadences, 1, 1]);
    gapIndicators = repmat(gapIndicators(1,:), [nCadences, 1 ]);
else
    Cv = interp1(processedCadences, Cv, cadenceList, pouConfigStruct.pouInterpMethod, 'extrap');                                                                        
    if any(any(gapIndicators))
        gapIndicators = logical(interp1(processedCadences, gapIndicators, cadenceList, 'nearest', 'extrap'));
    else
        gapIndicators = false( nCadences, nPixels );
    end
end

return
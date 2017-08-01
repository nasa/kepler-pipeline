function initialize(obj, inputStruct)
%**************************************************************************
% initialize(obj, inputStruct)
%**************************************************************************
% Initialize an apertureModelClass object.
%
% INPUTS
%     inputStruct : An apertureModelClass input structure.
%
% OUTPUTS
%     (none)
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
            
    obj.initialize_debug_struct( inputStruct.debugLevel ); 
    
    obj.configStruct  = inputStruct.configStruct;    
    obj.midTimestamps = inputStruct.midTimestamps;
    
    if ~isfield(inputStruct,'keplerIds')
        inputStruct.keplerIds = [];
    end
    
    % Check for Optimization Toolbox if the 'lsqnonneg' fitting method was
    % specified.
    if strcmp(obj.configStruct.amplitudeFitMethod, 'lsqnonneg') ...
        && ~license('test', 'Optimization_toolbox')
    
        warning(['Matlab Optimization Toolbox license is unavailable.', ...
            ' Using ''bbnnls'' method in place of ''lsqnonneg''.']);
        obj.configStruct.amplitudeFitMethod = 'bbnnls';
    end
    
    %----------------------------------------------------------------------
    % Set handles to the PRF and motion models.
    %----------------------------------------------------------------------
    obj.prfModelHandle    = inputStruct.prfModelObject;
    obj.motionModelHandle = inputStruct.motionModelObject;
    
    %----------------------------------------------------------------------
    % Determine the set of unique pixels comprising this group of target
    % masks. Set the pixelRows pixelColumns and observedPixels properties.
    %----------------------------------------------------------------------
    allPixels = [inputStruct.targetArray.pixelDataStruct]; 
    allPixelRowCol = ...
        [ colvec([allPixels.ccdRow]), colvec([allPixels.ccdColumn]) ];
    [~, uniquePixelInd] = unique(allPixelRowCol, 'rows');
    
    obj.observedPixels = allPixels(uniquePixelInd);
    obj.pixelRows      = allPixelRowCol(uniquePixelInd,1);
    obj.pixelColumns   = allPixelRowCol(uniquePixelInd,2);    
    
    nPixels = length(obj.pixelRows);

    %----------------------------------------------------------------------
    % Determine the contributing stars.
    %
    % If a list of kepler IDs was provided then construct a model using
    % only those stars, provided there are corresponding entries for them
    % in either the catalog or the target array. 
    %----------------------------------------------------------------------
    if ~isempty(inputStruct.keplerIds)
        obj.initialize_contributing_stars_from_list( inputStruct.targetArray, ...
            inputStruct.catalog, inputStruct.keplerIds);
    else
        obj.initialize_contributing_stars(inputStruct.targetArray, ...
                                          inputStruct.catalog);
    end
    
    %----------------------------------------------------------------------
    % Initialize the model components.
    %----------------------------------------------------------------------
    nStars = numel(obj.contributingStars);
    nCadences = obj.get_num_cadences();
    
    obj.coefficients = zeros(nCadences, nStars + 1);
    obj.basisVectors = zeros(nPixels, nStars + 1, nCadences);  
    
    % The last basis vector is filled with a constant.
    obj.basisVectors(:,end,:) = 1.0 / nPixels;
end

%********************************** EOF ***********************************


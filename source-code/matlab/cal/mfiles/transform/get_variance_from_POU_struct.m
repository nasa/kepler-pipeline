function outputStruct = get_variance_from_POU_struct(pouStructArray, variableNames, pouParameterStruct)
%
% function outputStruct = get_variance_from_POU_struct(pouStructArray, variableNames, pouParameterStruct)
%
% This function returns the values and their variances for the data listed in variableNames by propagating primitive data throught the
% transformations saved in the pouStructArray. The output is nCadence x nPixel arrays in the fields of outputStruct. The variance is taken
% from the diagonal of the propagated covariance matrix. 
%
% INPUT:    pouStructArray      =   full errorPropStructArray containting
%                                   maximized and uncompressed data - 2D array,
%                                   nVariables x nCadences
%           variableNames       =   cell array containing names of
%                                   errorPropStruct variables
%           pouParameterStruct  =   structure containing parameters used in
%                                   propagation of uncertainties, namely:
%                                       pouEnabled
%                                       compressFlag
%                                       maxSvdOrder
%                                       pixelChunkSize
%                                       interpDecimation
%                                       interpMethod
% OUTPUT:   outputStruct    =     structure with one field for each of the names in variableNames. The field names
%                                   match the variable names. Output is the 'varaince' and the decimated relative cadence
%                                   indices where the variance in calculated. The full covariance matrix is not returned 
%                                   but this function could be easily modified to return full covariance matrices
%                                   since they are returned cadence by cadence in the call to cascade_transformations.
%                               e.g.
%                                   outputStruct.(variableName).variance = variance; nCadences x nPixels; double
%                                   outputStruct.(variableName).usedCadences = usedCadences; nDecimatedCadences x 1; double
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

if any(size(pouStructArray) == 0)
    error(['CAL:',mfilename,':POU struct array must have at least one row and one column '...
        '(at least one variable name and one cadence)']);
end

% get pou parameters
decimationFactor = pouParameterStruct.interpDecimation;
% interpMethod = pouParameterStruct.interpMethod;

% number of cadences avaliable determined by the pouStructArray dimension
numCadence = size(pouStructArray,2);
if decimationFactor >= numCadence
    decimationFactor = 1;
end
usedCadences = unique([1:decimationFactor:numCadence, numCadence]);
numUsedCadences = length(usedCadences);

for i = 1:length(variableNames)

    varIndex = iserrorPropStructVariable(pouStructArray(:,1), variableNames{i});
    if varIndex
        display(['CAL:get_variance_from_POU_struct: Processing ',variableNames{i},' ...']);

        % throw warning if gap filled cadences are used for interpolation
        numGappedCadencesUsed = length(intersect(usedCadences,find([pouStructArray(varIndex,:).cadenceGapFilled])));
        if numGappedCadencesUsed > 0
            disp(['CAL:',mfilename,': ',num2str(numGappedCadencesUsed),...
                ' Gap filled cadences used in interpolation of variance over ',num2str(numCadence),' cadences.']);
        end

        % intitalize empty arrays
        variance = [];
        cadence = [];

        for j = 1:numUsedCadences
            [x, Cx] = cascade_transformations(pouStructArray(:,usedCadences(j)), variableNames{i} );                %#ok<ASGLU>
            v = diag(Cx);
            v = v(:)';

            % preallocate space
            if isempty(variance) && isempty(cadence)
                variance = zeros(numUsedCadences,length(v));
                cadence = zeros(numUsedCadences,1);
            end

            variance(j,:) = v;                                                                                      %#ok<*AGROW>
            cadence(j) = usedCadences(j);
        end
        
        % save cadence indices where the propagated variance was extracted
        outputStruct.(variableNames{i}).usedCadenceIndex = usedCadences;

        % save variance only on used cadence indices
        outputStruct.(variableNames{i}).variance = variance;
        
        
        % no more extrapolation - it is not needed due to KSOC-2554
        
%         % set output struct - extrapolate decimated variance over all cadences
%         if decimationFactor ~= 1 && numCadence > 2
%             outputStruct.(variableNames{i}).variance = ...
%                 interp1(cadence,variance,(1:numCadence)',interpMethod,'extrap');
%         else
%             outputStruct.(variableNames{i}).variance = variance;
%         end
       
        
    end
end

% if no output structure was generated set to empty and throw warning
if ~exist('outputStruct','var')
    outputStruct = struct([]);
    warning(['CAL:',mfilename,'No variable names found. Returning empty output struct']);               %#ok<WNTAG>
end

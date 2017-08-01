function [uniqueApertureList apertureMap] = find_unique_apertures(apertureStructs, ...
    amaConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [uniqueApertureList apertureMap] = find_unique_apertures(apertureStructs, ...
%     amaConfigurationStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% return list of unique apertures given a list of apertures with possibly
% identical entries
%
% inputs:
%   apertureDefinitionList array of aperture structures containing the fields 
%       .offsets array of structures containing the fields
%       .row, column row, column offsets of each offsets entry
%
% outputs:
%   uniqueApertureList array of aperture structures containing the fields 
%       .offsets array of structures containing the fields
%       .row, column row, column offsets of each offsets entry
%   apertureMap array of indices with the same length as input
%       apertureDefinitionList giving which entry in uniqueApertureList
%       corresponds to each entry in apertureDefinitionList
%
% 
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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

if nargin < 2
    defaultNumHalos = 0;
    defaultUndershootColumn = 0;
    amaConfigurationStruct.defaultStellarLabels = [];
else
    defaultNumHalos = 1;
    defaultUndershootColumn = 1;
end

numAperturesInList = length(apertureStructs); % # of input apertures
apertureMap = zeros(numAperturesInList, 1); % initialize output

% we'll build up the output unique aperture list by adding input apertures
% if they are not already in the list
uniqueApertureList = []; % initialize the unique aperture list
uniqueApertureNum = 1; % index of current unique aperture
% for each aperture in the input list
for a = 1:numAperturesInList
	if isempty(apertureStructs(a).offsets)
		continue;
    end

    aperture = apertureStructs(a); % pull the target ap data of interest
    if ~isfield(aperture, 'labels')
        aperture.labels = [];
    end
    if ~isfield(aperture, 'custom')
        aperture.custom = 0;
    end
    if isempty(aperture.labels)
        % assign default lables appropriate to this target
        if aperture.custom
        	aperture.labels = amaConfigurationStruct.defaultCustomLabels;
        else
        	aperture.labels = amaConfigurationStruct.defaultStellarLabels;
        end
    end
    
    % parse the lables
    wantsDedicatedMask = 0;    
    numHalos = defaultNumHalos;
    undershootColumn = defaultUndershootColumn;
    for label = 1:length(aperture.labels)
        switch aperture.labels{label}
            case {'TAD_NO_HALO'}
                numHalos = 0;
            case {'TAD_ONE_HALO'}
                numHalos = 1;
            case {'TAD_TWO_HALO', 'TAD_TWO_HALOS'}
                numHalos = 2;
            case {'TAD_THREE_HALO', 'TAD_THREE_HALOS'}
                numHalos = 3;
            case {'TAD_FOUR_HALO', 'TAD_FOUR_HALOS'}
                numHalos = 4;
            case {'TAD_ADD_UNDERSHOOT_COLUMN'}
                undershootColumn = 1;
            case {'TAD_NO_UNDERSHOOT_COLUMN'}
                undershootColumn = 0;
            case {'TAD_DEDICATED_MASK'}
                wantsDedicatedMask = 1;
            otherwise % assume a generic stellar target
                wantsDedicatedMask = 0;
                numHalos = defaultNumHalos;
                undershootColumn = defaultUndershootColumn;
        end
    end

    % dedicated mask targets are not subject to the unique list
    if ~wantsDedicatedMask
        % see if current aperture is in unique list
        if numHalos || undershootColumn
            [apImage apertureCenter] = target_definition_to_image( aperture );
            [apImage, apertureCenter] = apply_halo(apImage, apertureCenter, ...
                numHalos, undershootColumn);
            aperture = image_to_target_definition(apImage, apertureCenter);
        end
        uniqueAperture = find_equal_aperture_definitions( ...
            aperture, uniqueApertureList);
        if uniqueAperture == -1
            % it's not so add the aperture
            uniqueApertureList(uniqueApertureNum).offsets = aperture.offsets;
            % set the aperture map entry to the index of the newly added unique
            % entry
            apertureMap(a) = uniqueApertureNum;
            uniqueApertureNum = uniqueApertureNum + 1;
        else
            % set aperture map entry to the found unique entry
            apertureMap(a) = uniqueAperture;        
        end
    end
end
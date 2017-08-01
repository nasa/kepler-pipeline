function tf = is_valid_id( id, typeStr )
%**************************************************************************
% tf = is_valid_id( id, typeStr )
%**************************************************************************
% Test whether target ID numbers are consistent with a specified target
% type. Target types are categorized as shown in the diagram below:
%
%             catalog   custom
%             ----------------
%     kepler | KIC    |       |
%            | UKIRT  |       |
%            |----------------
%         k2 | EPIC   |       |
%            | test   |       |
%             ----------------
%
% INPUTS
%
%     id      : A numeric array of any dimensions.
%
%     typeStr : An optional string specifying the type of test to apply
%               (default='any'). Valid types are: 
%
%               'any'     : Are these valid IDs of any kind?
%               'kepler'  : Test whether elements of the id array are in
%                           any range of IDs reserved for the Kepler
%                           primary mission. 
%               'k2'      : Test whether elements of the id array are in
%                           any range of IDs reserved for the K2 mission. 
%               'catalog' : Test whether elements of the id array are in
%                           any range of IDs reserved for catalog objects
%                           from either mission. 
%               'custom'  : Test whether elements of the id array are in
%                           any range of IDs reserved for custom targets.  
%               'kic'     : Test whether elements of the id array are
%                           within the range reserved for KIC targets in
%                           the Kepler primary mission.
%               'ukirt'   : Test whether elements of the id array are
%                           within the range reserved for UKIRT targets in
%                           the Kepler primary mission. 
%               'epic'    : Test whether elements of the id array are
%                           within the range reserved for EPIC targets in
%                           the K2 mission.  
%               'test'    : Test whether elements of the id array are
%                           within the range reserved for K2 engineering
%                           tests prior to campaign 0.
%
% OUTPUTS
%
%     tf      : A logical array having the same dimensions as 'id'.
%
% NOTES
%     Per KSOC-3819, we have the following ID ranges defined:
%
%     Kepler ID ranges: 
%     ----------------
%     0 <= kepid < 100M 
%         * Kepler catalog targets (the KIC) 
%         * 15M <= kepid < 25M 
%             * UKIRT KIC extension targets in the kepler FOV 
%         * 60M <= kepid < 100M 
%             * K2 testing targets (Sept, 2013 through Feb, 2014 data sets) 
% 
%     100M <= kepid < 200M 
%         * Kepler Custom targets 
% 
%     200M <= kepid < 201M 
%         * K2 Custom targets 
% 
%     kepid <= 201M 
%         * K2 catalog target 
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

    if ~exist('typeStr', 'var')
        typeStr = 'any';
    end

    switch lower(typeStr)
        case 'any' 
            tf = is_kepler_id(id) | is_k2_id(id);
        case 'kepler'
            tf = is_kepler_id(id);
        case 'k2'
            tf = is_k2_id(id);
        case 'catalog'
            tf = is_catalog_id(id);
        case 'custom'
            tf = is_custom_id(id);
        case 'kic'  
            tf = is_kepler_kic_id(id);
        case 'ukirt'
            tf = is_kepler_ukirt_id(id);
        case 'epic'
            tf = is_k2_epic_id(id);
        case 'test'
            tf = is_k2_test_id(id);
        otherwise
            error('Invalid type string.');
    end

end
    
%% Compound Tests

%**************************************************************************
% Test whether elements of the id array are in any range of IDs reserved 
% for the Kepler primary mission.
function tf = is_kepler_id(id)
    tf = is_kepler_kic_id(id)    | ...
         is_kepler_ukirt_id(id)  | ...
         is_kepler_custom_id(id);        
end

%**************************************************************************
% Test whether elements of the id array are in any range of IDs reserved 
% for the K2 mission.
function tf = is_k2_id(id)
    tf = is_k2_epic_id(id)    | ...
         is_k2_custom_id(id)  | ...
         is_k2_test_id(id);        
end

%**************************************************************************
% Test whether elements of the id array are in any range of IDs reserved 
% for catalog objects.
function tf = is_catalog_id(id)
    tf = is_kepler_kic_id(id)    | ...
         is_kepler_ukirt_id(id)  | ...
         is_k2_epic_id(id)       | ...
         is_k2_test_id(id);        
end

%**************************************************************************
% Test whether elements of the id array are in any range of IDs reserved 
% for custom targets.
function tf = is_custom_id(id)
    tf = is_kepler_custom_id(id) | ...
         is_k2_custom_id(id);        
end

%% Primitive Tests

%**************************************************************************
% Test whether elements of the id array are within the range reserved for
% KIC targets in the Kepler primary mission.
function tf = is_kepler_kic_id(id)
    tf = (id == fix(id)) & id >= 0 & id < 15e6;        
end

%**************************************************************************
% Test whether elements of the id array are within the range reserved for
% UKIRT targets in the Kepler primary mission.
function tf = is_kepler_ukirt_id(id)
    tf = (id == fix(id)) & id >= 15e6 & id < 25e6;    
end

%**************************************************************************
% Test whether elements of the id array are within the range reserved for
% custom targets in the Kepler primary mission.
function tf = is_kepler_custom_id(id)
    tf = (id == fix(id)) & id >= 100e6 & id < 200e6;    
end

%**************************************************************************
% Test whether elements of the id array are within the range reserved for
% EPIC targets in the K2 mission.
function tf = is_k2_epic_id(id)
    tf = (id == fix(id)) & id >= 201e6;
end

%**************************************************************************
% Test whether elements of the id array are within the range reserved for
% K2 engineering tests prior to campaign 0. 
function tf = is_k2_test_id(id)
    tf = (id == fix(id)) & id >= 60e6 & id < 100e6;
end

%**************************************************************************
% Test whether elements of the id array are within the range reserved for
% custom targets in the K2 mission.
function tf = is_k2_custom_id(id)
    tf = (id == fix(id)) & id >= 200e6 & id < 201e6;
end

%********************************** EOF ***********************************


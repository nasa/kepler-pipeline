function configMapTable = dg_retrieve_config_map_by_id(id)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function dgConfigMapTable = dg_retrieve_config_map_by_id(id)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% dg_retrieve_config_map_by_id uses the configMap retriever API to obtain 
% the confiMap of a specified configMapId # and displays it in a cell with
% 3 columns.  First column is the mnemonic, second column is the
% value, and third column is the description, if available.
%
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT:  
%           id: [int] the spacecraft configuration id number
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUT:
%
%       dgConfigMapTable:  [cell] configMap in table format
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


% call the retriever and place data in  configMapStruct
% this is a multi-level struct that needs to be manipulated for viewing
configMapStruct = retrieve_config_map_by_id(id);

% get the number of entries, or mnemonics on the map
numEntries =  length(configMapStruct.entries);

% initialize cell to put in all data
numRows = numEntries;
configMapCell = cell(numRows,3);

% allocate retrieved data into the cell
for n =1:numEntries
    configMapCell{n,1} = configMapStruct.entries(n).mnemonic;
    configMapCell{n,2} = configMapStruct.entries(n).value;
end



% create new configMapDescripStruct with description per Mike's spreadsheet
configMapDescripStruct = struct('TCSCCFGID', 'commanded SC configuration ID', ...
    'timestamp', 'Time when SC configuration ID is commanded', ...
    'GSFSWBLD', 'FSW version number, build', ...
    'GSFSWREL', 'FSW version number, release', ...
    'GSFSWUPDATE','FSW version number, update', ...
    'FDMINTPER','commanded integration period', ...
    'GSprm_FGSPER', 'FGS frame period', ...
    'GSprm_ROPER', 'Readout period',...
    'FDMSCPER', 'commanded short cadence period', ...
    'FDMLCPER', 'commanded long cadence period', ...
    'FDMNUMLCPERBL', 'num of LC periods between baselines', ...
    'FDMLDEFFINUM', 'num of integrations in a science FFI', ...
    'FDMLDEMD', 'Reverse-clocking', ...
    'FDMSMRROWSTART', 'The science collateral smear region start row',...
    'FDMSMRROWEND', 'The science collateral smear region end row', ...
    'FDMSMRCOLSTART', 'The science collateral smear region start col', ...
    'FDMSMRCOLEND', 'The science collateral smear region end col', ...
    'FDMMSKROWSTART', 'The science collateral masked region start row', ...
    'FDMMSKROWEND', 'The science collateral masked region end row', ...
    'FDMMSKCOLSTART', 'The science collateral masked region start col', ...
    'FDMMSKCOLEND', 'The science collateral masked region end col', ...
    'FDMDRKROWSTART', 'The science collateral dark region start row', ...
    'FDMDRKROWEND', 'The science collateral dark region end row', ...
    'FDMDRKCOLSTART', 'The science collateral dark region start col', ...
    'FDMDRKCOLEND', 'The science collateral dark region end col', ...
    'PEDFOC1POS', 'Current position of focus mechanism 1', ...
    'PEDFOC2POS', 'Current position of focus mechanism 2', ...
    'PEDFOC3POS', 'Current position of focus mechanism 3', ...
    'PEDFPAHCSETPT', 'Commanded set point to control FPA temperature');

fields = fieldnames(configMapDescripStruct);
nFields = length(fields);

for n = 1:nFields
    indx = strmatch(fields{n}, configMapCell(:,1), 'exact');
    descrip = configMapDescripStruct.(fields{n});
    if ~isempty(indx)
        configMapCell{indx, 3} = descrip;
    end
end


configMapTable = [{'Mnemonic'}, {'Value'}, {'Description'}; configMapCell];

    
return
% now configMapTable has a column header and description column
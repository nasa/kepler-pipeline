function validate_configmaps_input_structure(configMaps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function validate_configmaps_input_structure(configMaps)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% configMaps
%     TIME_ENTRY_NAME: 'Timestamp'
%       ID_ENTRY_NAME: 'TCSCCFGID'
%                  id: 1
%                time: 5.5296e+004
%             entries: [1x28 struct]
% configMaps.entries
% 1x28 struct array with fields:
%     mnemonic
%     value
% mnemonics ={
%     'TCSCCFGID'
%     'timestamp'
%     'GSFSWBLD'
%     'GSFSWREL'
%     'GSFSWUPDATE'
%     'FDMINTPER'
%     'GSprm_FGSPER'
%     'GSprm_ROPER'
%     'FDMSCPER'
%     'FDMLCPER'
%     'FDMNUMLCPERBL'
%     'FDMLDEFFINUM'
%     'FDMSMRROWSTART'
%     'FDMSMRROWEND'
%     'FDMSMRCOLSTART'
%     'FDMSMRCOLEND'
%     'FDMMSKROWSTART'
%     'FDMMSKROWEND'
%     'FDMMSKCOLSTART'
%     'FDMMSKCOLEND'
%     'FDMDRKROWSTART'
%     'FDMDRKROWEND'
%     'FDMDRKCOLSTART'
%     'FDMDRKCOLEND'
%     'PEDFOC1POS'
%     'PEDFOC2POS'
%     'PEDFOC3POS'
%     'PEDFPAHCSETPT'
%     };
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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


nConfigMaps = length(configMaps);



%------------------------------------------------------------
fieldsAndBounds = cell(3,4);
fieldsAndBounds(1,:)  = { 'id'; '>= 0'; '<=1e4'; []};
fieldsAndBounds(2,:)  = { 'time'; '> 54000'; '< 64000'; []};% use mjd
fieldsAndBounds(3,:)  = { 'entries'; []; []; []};

for jMap = 1:nConfigMaps

    validate_structure(configMaps(jMap), fieldsAndBounds,'configMaps');
end

clear fieldsAndBounds;
%------------------------------------------------------------




fieldsAndBounds = cell(2,4);
fieldsAndBounds(1,:)  = { 'mnemonic'; []; []; []};
fieldsAndBounds(2,:)  = { 'value'; []; []; []};


for jMap = 1:nConfigMaps
    
    nStructures = length(configMaps(jMap).entries);
    for j = 1:nStructures
        validate_structure(configMaps(jMap).entries(j), fieldsAndBounds,'configMaps.entries');
    end
end
clear fieldsAndBounds;
%------------------------------------------------------------

return

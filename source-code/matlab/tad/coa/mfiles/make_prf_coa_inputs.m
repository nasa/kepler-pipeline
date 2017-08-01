% make prf inputs for TAD, module 14 output 1, 1 March 2009
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

% get the target list
load ../../../../../../so/Develop/PRF/PRF_characterization/prfTargetLists
% get an example input
% load ../../coa/mfiles/coaInputStruct_6_16_08.mat

module = 14;
output = 1;
dateStr = '1 March 2009';
duration = 5; % days
startMjd = datestr2mjd(dateStr);
endMjd = startMjd + duration;
% set the main defaults
coaInputStruct = coaIs;
coaInputStruct.kicEntryDataStruct = [];

% set the catalog
kics = retrieve_kics(module, output, startMjd);
goodEntryCount = 1;
for i=1:length(kics)
    if ~isempty(kics(i).getKeplerId()) && ~isempty(kics(i).getKeplerMag())
        coaInputStruct.kicEntryDataStruct(goodEntryCount).KICID = double(kics(i).getKeplerId());
        coaInputStruct.kicEntryDataStruct(goodEntryCount).RA = double(kics(i).getRa());
        coaInputStruct.kicEntryDataStruct(goodEntryCount).dec = double(kics(i).getDec());
        coaInputStruct.kicEntryDataStruct(goodEntryCount).magnitude = double(kics(i).getKeplerMag());
        coaInputStruct.kicEntryDataStruct(goodEntryCount).effectiveTemp = double(kics(i).getEffectiveTemp());
        goodEntryCount = goodEntryCount + 1;
    end
end

% set the target list
coaInputStruct.targetKeplerIDList = prfKid12_15;

% get the appropriate PRF blob
filename = sprintf('/path/to/ETEM_PSFs/all_blobs/prf%02d%d-2008032321.dat', module, output);
disp(filename);

bfid = fopen(filename, 'r');
coaInputStruct.prfBlob = fread(bfid, inf, 'uint8');
fclose(bfid);

coaInputStruct.startTime = dateStr;
coaInputStruct.duration = duration; 
coaInputStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model(); 
coaInputStruct.readNoiseModel = retrieve_read_noise_model(startMjd, endMjd); 
coaInputStruct.gainModel = retrieve_gain_model(startMjd, endMjd); 
coaInputStruct.twoDBlackModel = retrieve_two_d_black_model(module, output); 
coaInputStruct.linearityModel = retrieve_linearity_model(startMjd, endMjd, module, output); 
coaInputStruct.undershootModel = retrieve_undershoot_model(); 
coaInputStruct.flatFieldModel = retrieve_flat_field_model(module, output); 
coaInputStruct.fcConstants = convert_fc_constants_java_2_struct(); 
coaInputStruct.module = module; 
coaInputStruct.output = output; 

coaInputStruct.debugFlag = 1; 

coaInputStruct = fix_coa_inputs(coaInputStruct);



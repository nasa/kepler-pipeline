function header = read_vcdu_header(vcduFileName)
% header = read_vcdu_header(vcduFileName)
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

%%
numHeaderBytes = 1115-1107;

if isstr(vcduFileName)
    fid = fopen(vcduFileName,'r','ieee-be');
    header.bytes= fread(fid,[1,numHeaderBytes],'uint8=>uint8');

    fclose(fid);
else
    header.bytes = vcduFileName;
end
%%

header.String = colvec(display_bits(GF256(header.bytes))')';
%%
header.items = {'versionNumber', '01';
                'SCID', 227;
                'virtualChannelID', 14;
                'VCDUcounter',NaN;
                'replayFlag',1;
                'spare', repmat('0',1,7);
                'MPDUspare',repmat('0',1,5);
                'firstHeaderPointer',NaN};
            
header.bitLengths = [2,8,6,24,1,7,5,11];    
                
header.bitStarts = cumsum([1,header.bitLengths]);

%%
for i = 1:length(header.items)
    ii = header.bitStarts(i):header.bitStarts(i+1)-1;
    header.itemValues(i) = bin2dec(header.String(ii));
    header.itemBits{i} = header.String(ii);
end
%%
disp(' ')
disp(['VCDU Header Reader: reading ',vcduFileName])
for i=1:length(header.items)
    if ~isstr(header.items{i,2})
        disp([header.items{i,1},' = ',int2str(header.itemValues(i)), ' should be ',...
        int2str(header.items{i,2})]);
        eval(['header.',header.items{i,1},'=int2str(header.itemValues(i));'])
    else
        disp([header.items{i,1},' = ',header.itemBits{i}, ' should be ',...
        header.items{i,2}]);
        eval(['header.',header.items{i,1},'=header.itemBits{i};']);    
    end
end

disp(' ')
%%
return

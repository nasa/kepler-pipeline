function parse_ccsds(ccsdsFileName)
% parse_ccsds(ccsdsFileName)
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

ccsdsPacketLength = 16380;
primaryHeaderLength = 7;
legalApIds = [40 41];

fid = fopen(ccsdsFileName,'r','ieee-be');

disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
disp('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');
for count = 1:10000
    header = parse_ccsds_header(fid);
    if isempty(header)
        break;
    end
    packetLength = header.itemValues(7) + primaryHeaderLength;
    packetSequenceCount = header.itemValues(6);
    apId = header.itemValues(4);
    
    if packetSequenceCount == 0 || packetLength ~= ccsdsPacketLength
        disp(['>>>>>>> count = ' num2str(count)]);
        display_ccsds_header(header);
    end
    if packetLength ~= ccsdsPacketLength
        disp('====');
    end
    if ~ismember(apId, legalApIds)
        disp('something is wrong, bailing out');
        break
    end
    status = fseek(fid, packetLength, 'cof');
    if status == -1
	break;
    end
end


fclose(fid);
disp('-----------------------------------------------------------');
disp('-----------------------------------------------------------');
disp('-----------------------------------------------------------');
disp(' ');
disp(' ');
disp(' ');


function header = parse_ccsds_header(fid)
% the file pointer for fid will always point at the start of the ccsds packet

ccsdsHeaderLength = 14;

header.bits = fread(fid,[1,ccsdsHeaderLength],'uint8=>uint8');
if length(header.bits) < ccsdsHeaderLength
   header = [];
   return;
end

% seek back to the beginning of the packet
fseek(fid, -ccsdsHeaderLength, 'cof');

header.String = colvec(display_bits(GF256(header.bits))')';
header.items = {'versionNumber';
                'type';
                'secondaryHeaderFlag';
                'apID';
                'sequenceFlags';
                'packetSequenceCount';
                'packetLength';
                'timeStamp';
                'packetID';
                'PacketDesinationID'};
            
header.bitLengths = [3,1,1,11,2,14,16,40,8,8,8];    
                
header.bitStarts = cumsum([1,header.bitLengths]);

for i = 1:length(header.items)
    ii = header.bitStarts(i):header.bitStarts(i+1)-1;
    header.itemValues(i) = bin2dec(header.String(ii));
end

function display_ccsds_header(header)

%for i=1:length(header.items)
typestring = ['apID = ' num2str(header.itemValues(4))];
switch header.itemValues(4) % apid
    case 40 
        typestring = [typestring ' long cadence '];
    case 41 
        typestring = [typestring ' short cadence '];
    otherwise
        typestring = [typestring ' unknown '];
end
typestring = [typestring ' packetID = ' num2str(header.itemValues(9))];
switch header.itemValues(9) % apid
    case 100 
        typestring = [typestring ' baseline '];
    case 101 
        typestring = [typestring ' residual baseline '];
    case 102 
        typestring = [typestring ' residual encoded '];
    case 103 
        typestring = [typestring ' raw '];
    otherwise
        typestring = [typestring ' unknown '];
end
disp(typestring);
for i=[6 7 8]
    disp([header.items{i},' = ',int2str(header.itemValues(i))]);
end

        

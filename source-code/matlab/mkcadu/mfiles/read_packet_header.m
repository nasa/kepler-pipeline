function header = read_packet_header(packetFileName)
% header = read_packet_header(packetFileName)
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
header.items = {'versionNumber'; % 3 bits
                'type'; % 1 bit
                'secondaryHeaderFlag'; % 1 bit
                'apID'; % 11 bits
                'sequenceFlags'; % 2 bits
                'packetSequenceCount'; % 14 bits
                'packetLength'; % 16 bits
                'timeStamp'; % 40 bits
                'packetID'; % 8 bits
                'DestinationAppID'; % 8 bits
		'PacketDesinationID'; % 8 bits
		'PhotoIDunused'; % 1 bit
		'PhotIDsefiAccum'; % 1 bit
		'PhotIDseficadence'; % 1 bit
		'PhotoIDideOutOfSync'; % 1 bit
		'PhotoIDfinePoint'; % 1 bit
		'PhotoIDmomentumDump'; % 1 bit
		'PhotoIDpixelError'; % 2 bit
		'PhotoIDlcTargetTableID'; % 8 bits
		'PhotoIDscTargetTableID'; % 8 bits
		'PhotoIDbgTargetTableID'; % 8 bits
		'PhotoIDapBackgroundTableID'; % 8 bits
		'PhotoIDabScienceTableID'; % 8 bits
		'PhotoIDrefPixelTableID'; % 8 bits
		'PhotoIDcompressionTableID'; % 8 bits
		'firstPixelID'; % 4*8 bits
		'numPixels'}; % 4*8 bits
            
header.bitLengths = [3,1,1,11,2,14,16,40,8,8,8,...
	             1,1,1,1,1,1,2,8,8,8,8,8,8,8,...
		     4*8,4*8];    
                
header.bitStarts = cumsum([1,header.bitLengths]);
header.numBytes = sum(header.bitLengths)/8;

%%
if isstr(packetFileName)
    fid = fopen(packetFileName,'r','ieee-be');

    header.bytes = fread(fid,[1,header.numBytes],'uint8=>uint8');

    fclose(fid);
else
    header.bytes = packetFileName;
end

header.String = colvec(display_bits(GF256(header.bytes))')';
%%
%%
for i = 1:length(header.items)
    ii = header.bitStarts(i):header.bitStarts(i+1)-1;
    header.itemValues(i) = bin2dec(header.String(ii));
    eval(['header.',header.items{i,1},'=int2str(header.itemValues(i));'])
end
%%
return
%%
for i=1:length(header.items)
    disp([header.items{i},' = ',int2str(header.itemValues(i))]);

end

%%
return
%%

headerString = display_bits(GF256(header));

headerString = colvec(headerString')';

%%

versionNumber = bin2dec(headerString(1:3));

disp(['version number = ',int2str(versionNumber)])

type = bin2dec(headerString(4))

disp(['type = ',int2str(type)])

secondaryHeaderFlag = bin2dec(headerString(5))
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

apID = bin2dec(headerString(5+(1:11)))
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

sequenceFlags = headerString(17:18);
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

packetSequenceCount = bin2dec(headerString(18+(1:14)))
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

packetLength = bin2dec(headerString(18+14+(1:16)))
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

timeStamp = bin2dec(headerString(6*8+(1:40)))
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

packetID = bin2dec(headerString(6*8+40+(1:8)))
disp(['secondary header flag = ',int2str(secondaryHeaderFlag)])

destApID = bin2dec(headerString(48+48+(1:8)))

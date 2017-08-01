function generate_tlnm_xml(tlTxtFileNames, tlnmXmlFileName)
% function generate_tlnm_xml(tlTxtFileNames, tlnmXmlFileName)
%
% tlTxtFileNames is an array of strings (these are the names of the target list txt files).
% tlnmXmlFileName is the output file name of the tlnm.xml file that will be generated (this file name must end with the string '_tlnm.xml').
%
% Example: 
% >> generate_tlnm_xml({'tad2-trimmed_planetary.txt', 'tad2-kplr2008113011_dedicated_arps.txt', 'tad2-exclusion.txt'}, 'kplr2008309100622_tlnm.xml')
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

fid = fopen(tlnmXmlFileName, 'w');
fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid, '<nm:data_product_message xmlns:nm="http://kepler.nasa.gov/nm">\n');
fprintf(fid, '  <message_type>TLNM</message_type>\n');
fprintf(fid, '  <identifier>%s</identifier>\n', tlnmXmlFileName);
fprintf(fid, '  <file_list>\n');

for i=1:length(tlTxtFileNames)
    tlTxtFileName = tlTxtFileNames{i};

    fprintf(fid, '    <file>\n');
    fprintf(fid, '      <filename>%s</filename>\n', tlTxtFileName);
    fprintf(fid, '      <size>0</size>\n');
    fprintf(fid, '      <checksum>skipped</checksum>\n');
    fprintf(fid, '    </file>\n');
end

fprintf(fid, '  </file_list>\n');
fprintf(fid, '</nm:data_product_message>\n');

fclose(fid);


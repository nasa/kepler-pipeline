function generate_tls_xml(name, type, startDate, endDate, includedTargetListNames, excludedTargetListNames, tlsXmlFileName)
% function generate_tls_xml(name, type, startDate, endDate, includedTargetListNames, excludedTargetListNames, tlsXmlFileName)
%
% name is the name of the target list set (any name is allowed that has not been previously imported into the database).
% type is the type of the target list set (only long-cadence, short-cadence, or reference-pixel are allowed).
% startDate is the start date of the tad run (e.g. 18-Mar-2009 12:00:00.000).
% endDate is the end date of the tad run (e.g. 17-Jun-2009 12:00:00.000).
% includedTargetListNames is an array of target list names to include in this target list set (these names must be names of target lists that exist in the database).
% excludedTargetListNames is an array of target list names to exclude from this target list set (these names must be names of target lists that exist in the database).
% tlsXmlFileName is the name of the output tls.xml file that is written (this file name must end with the string '_target-list-set.xml').
%
% Example: 
% >> generate_tls_xml('q1-lc', 'long-cadence', '18-Mar-2009 12:00:00.000', '17-Jun-2009 12:00:00.000', {'tad2-trimmed_planetary.txt', 'tad2-kplr2008113011_dedicated_arps.txt'}, {'tad2-exclusion.txt'}, 'kplr2008310114020--q1-lc_target-list-set.xml')
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

fid = fopen(tlsXmlFileName, 'w');
fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid, '<tar:target-list-set name="%s" type="%s" start="%s" end="%s" xmlns:tar="http://kepler.nasa.gov/dr/targetlistset">\n', name, type, startDate, endDate);

for i=1:length(includedTargetListNames)
    includedTargetListName = includedTargetListNames{i};

    fprintf(fid, '  <targetList name="%s"/>\n', includedTargetListName);
end

for j=1:length(excludedTargetListNames)
    excludedTargetListName = excludedTargetListNames{j};

    fprintf(fid, '  <excludedTargetList name="%s"/>\n', excludedTargetListName);
end

fprintf(fid, '</tar:target-list-set>\n');

fclose(fid);


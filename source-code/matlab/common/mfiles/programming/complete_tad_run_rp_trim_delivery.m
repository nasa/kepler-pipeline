function complete_tad_run_rp_trim_delivery(filenameSpec)
% function complete_tad_run_rp_trim_delivery(filenameSpec)
%
% input filenameSpec: a string pointing to a filename specification as
% described below
%
% This routine helps prepare a TAD run delivery directory, generating the
% xml files and notification messages based on the fields in this source code.
% This routine also fills in the appropriate fields in the params files.
%
% This routine should be run in the desired delivery directory after the
% target list text files have been copied there.  
% 
% >> complete_tad_run_rp_trim_delivery('filename_spec')
%
% 
% Edit the source file and fill in your target lists in the top section.  
% New files must exist in the local directory.  Duplicates in the 
% urser-specified lists are OK because this function removes duplicates 
% before generating the final files.
%
% the input filenameSpec should contain the command that invokes a matlab 
% script that sets the the following variables
%
% %
% % Configuration file for Quarter X ...
% %
% 
% startDate = '18-Mar-2009 12:00:00.000';
% endDate = '17-Jun-2009 12:00:00.000';
% 
% % for the TAD parameter file: associatedLcTargetListSetName= 
% lcRunName = 'quarter13_spring2012_untrimmed_lc';
% 
% % the TLS name, and filename string for the kplr*_target_list_set_tls.xml file
% rpRunName = 'quarter13_spring2012_untrimmed_rp_v1';
% 
% % reference pixel target lists that are also on the LC target list
% % this file will be in the kplr*_target_list_set_tls.xml and TLNM files
% rpTargetListOnLc = {'pdq_stellar_quarter13_spring2012_v1_untrimmed.txt'};
% 
% % reference pixel target lists that are not on the LC target list
% % this file will be in the kplr*_target_list_set_tls.xml file only
% rpTargetListNotOnLc = {'pdq_dynamic_quarter13_spring2012_untrimmed.txt'};
% 
% % for a function, unused
% rpExclusionList = [];
% 
% 
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

eval([filenameSpec ';']);

% collect the appropriate lists
targetLists = unique([lcTargetList, rpTargetListOnLc]);
rpTargetList = unique([rpTargetListOnLc, rpTargetListNotOnLc]);
exclusionLists = unique([lcExclusionList, rpExclusionList]);
allLists = unique([targetLists, exclusionLists, rpTargetList]);

%%%% make xml files and notification messages

% make the target list notification message
generate_tlnm_xml(allLists, generate_delivery_filename('_tlnm.xml'));

% make the target list set xml file
lcTlsXmlName = generate_delivery_filename(['_' lcRunName '_tls.xml']);
generate_tls_xml(lcRunName, 'long-cadence', startDate, endDate, ...
    targetLists, exclusionLists, lcTlsXmlName);

rpTlsXmlName = generate_delivery_filename(['_' rpRunName '_tls.xml']);
%tlsXmlNames = [tlsXmlNames {rpTlsXmlName}];
tlsXmlNames = [{rpTlsXmlName}];
generate_tls_xml(rpRunName, 'reference-pixel', startDate, endDate, ...
    	rpTargetList, rpExclusionList, rpTlsXmlName);

% make the target list set notification message
generate_tlsnm_xml(tlsXmlNames, generate_delivery_filename('_tlsnm.xml'));


%%%% modify required param files
% this script only takes care of the tad.param and amt.param files

% get a list of the files in this directory
filenames = dir('.');

% set the targetListSetName field in the tad.params_lc file
for i=1:length(filenames)
    if ~isempty(strfind(filenames(i).name, 'tad.params_lc'))
        replace_string_in_file(filenames(i).name, {'targetListSetName'}, ...
            {['targetListSetName=' lcRunName]});
        break;
    end
end

% set the targetListSetName and associatedLcTargetListSetName fields in 
% the tad.params_rp file
% this is an "optional" step and will only run if an existing parameter
% file is present in the directory
for i=1:length(filenames)
    if ~isempty(strfind(filenames(i).name, 'tad.params_rp'))
        replace_string_in_file(filenames(i).name, ...
            {'targetListSetName', 'associatedLcTargetListSetName'}, ...
            {['targetListSetName=' rpRunName], ...
            ['associatedLcTargetListSetName=' lcRunName]});
        break;
    end
end


%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%
% function replace_string_in_file(filename, triggerStringList, replaceStringList)
% 
% read a file a line at a time, and if the line starts with a string in the
% triggerStringList then replace that line with the corresponding entry in
% the replaceStringList
%
function replace_string_in_file(filename, triggerStringList, replaceStringList)
fid = fopen(filename, 'r');
if fid == -1
    error('file not found');
end
readString = 0;
lineNumber = 0;
while readString ~= -1
    readString = fgets(fid);
    if readString ~= -1
        lineNumber = lineNumber + 1;
        foundTriggerString = false;
        for c = 1:length(triggerStringList)
            if ~isempty(strfind(readString, triggerStringList{c}))
                outputText{lineNumber} = replaceStringList{c};
                newText(lineNumber) = true;
                foundTriggerString = true;
                break;
            end
        end
        if ~foundTriggerString
            outputText{lineNumber} = readString;
            newText(lineNumber) = false;
        end
    end
end
fclose(fid);

% now write out the new string with the new text
fid = fopen(filename, 'w');
fprintf(fid, '#modified by complete_tad_delivery on %s\n', datestr(now, 0));
for i=1:length(outputText)
    % gotta do this if statment because MATLAB is a little stupid w.r.t. unix
    % control characters like newline (\n)
    if newText(i)
        fprintf(fid, '%s\n', outputText{i});
    else
        fprintf(fid, '%s', outputText{i});
    end
end
fclose(fid);





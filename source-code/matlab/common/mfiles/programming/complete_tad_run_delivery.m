function complete_tad_run_delivery(filenameSpec)
% function complete_tad_run_delivery(filenameSpec)
%
% input filenameSpec: a string pointing to a filename specification as
% described below
%
% This routine helps prepare a TAD run delivery directory, generating the
% xml files and notification messages based on the fields in this source code.
% This routine also fills in the appropriate fields in the params files.
%
% This routine should be run in the desired delivery directory after the
% param files, target list text files, and mask table xml file have been copied
% there.  
%
% Edit this source file and fill in your target lists in the top section.  
% New files files must exist in the local
% directory.  LC, SC and RP target lists will be merged and duplicate
% entries removed, so there is no need to include SC and RP target lists
% in the lcTargetList.  Alternatively, duplicates in the user-specified
% lists are OK because this function removes duplicates before generating
% the final files.
%
% this routine requires that the param file names start with the string:
%   amt.params
%   tad.params_lc
%   tad.params_rp
%   tad.params_sc1
%   tad.params_sc2 (presence of this file is optional)
%   tad.params_sc3 (presence of this file is optional)
% 
% the input filenameSpec should contain the command that invokes  a matlab 
% script that sets the the following variables
%
% %
% % Configuration file for prelimQuarter1Trimmed
% %
% 
% startDate = '18-Mar-2009 12:00:00.000';
% endDate = '17-Jun-2009 12:00:00.000';
% 
% % set up long cadence lists
% lcRunName = 'prelimQuarter1Trimmed_lc';
% 
% lcTargetList = { ...
%     'arp_prelimQuarter1Trimmed.txt', ...
%     'astero_lc_prelimQuarter1Trimmed.txt', ...
%     'astrometry_prelimQuarter1Trimmed.txt', ...
%     'cluster_ngc6791_prelimQuarter1Trimmed.txt', ...
%     'cluster_ngc6819_prelimQuarter1Trimmed.txt', ...
%     'eb_prelimQuarter1Trimmed.txt', ...
%     'lepine_prelimQuarter1Trimmed.txt', ...
%     'planetary_prelimQuarter1Trimmed.txt', ...
%     'ppa_lde_prelimQuarter1Trimmed.txt', ...
%     'ppa_stellar_prelimQuarter1Trimmed.txt', ...
%     'unclassified_prelimQuarter1Trimmed.txt'};
% 
% lcExclusionList = [];
% 
% % set up short cadence lists for all three months (this is untested for 3 sc runs!)
% scRunName{1} = 'prelimQuarter1Trimmed_sc1';
% scRunName{2} = 'prelimQuarter1Trimmed_sc2';
% scRunName{3} = 'prelimQuarter1Trimmed_sc3';
% 
% scTargetList{1} = {'astero_sc1_prelimQuarter1Trimmed.txt', ...
%     'st_sc1_prelimQuarter1Trimmed.txt'};
% scTargetList{2} = {'astero_sc2_prelimQuarter1Trimmed.txt', ...
%     'st_sc2_prelimQuarter1Trimmed.txt'};
% scTargetList{3} = {'astero_sc3_prelimQuarter1Trimmed.txt', ...
%     'st_sc3_prelimQuarter1Trimmed.txt'};
% 
% scExclusionList{1} = [];
% scExclusionList{2} = [];
% scExclusionList{3} = [];
% 
% % set up reference pixel lists
% rpRunName = 'prelimQuarter1Trimmed_rp';
% % reference pixel target lists that are also on the LC target list
% rpTargetListOnLc = {'pdq_stellar_prelimQuarter1Trimmed.txt'};
% % reference pixel target lists that are nota on the LC target list
% rpTargetListNotOnLc = {'pdq_dynamic_prelimQuarter1Trimmed.txt'};
% 
% rpExclusionList = [];
% 
% maskTableXmlFilename = {'maskDefinitions_prelimQuarter1_v2.xml'};
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
for i=1:3
    targetLists = unique([targetLists scTargetList{i}]);
    exclusionLists = unique([exclusionLists scExclusionList{i}]);
end
allLists = unique([targetLists, exclusionLists, rpTargetList]);

%%%% make xml files and notification messages

% make the target list notification message
generate_tlnm_xml(allLists, generate_delivery_filename('_tlnm.xml'));

% make the target list set xml files for each list type
% long cadence
lcTlsXmlName = generate_delivery_filename(['_' lcRunName '_target_list_set_tls.xml']);
generate_tls_xml(lcRunName, 'long-cadence', startDate, endDate, ...
    targetLists, exclusionLists, lcTlsXmlName);
tlsXmlNames = {lcTlsXmlName};
% short cadence for each quarter
for i=1:3
    if ~isempty(scRunName{i})
        scTlsXmlName{i} ...
            = generate_delivery_filename(['_' scRunName{i} '_target_list_set_tls.xml']);
        tlsXmlNames = [tlsXmlNames {scTlsXmlName{i}}];
        generate_tls_xml(scRunName{i}, 'short-cadence', scStartDate{i}, scEndDate{i}, ...
            scTargetList{i}, scExclusionList{i}, scTlsXmlName{i});
    end
end
% reference pixels
if ~isempty(rpRunName)
	rpTlsXmlName = generate_delivery_filename(['_' rpRunName '_target_list_set_tls.xml']);
	tlsXmlNames = [tlsXmlNames {rpTlsXmlName}];
	generate_tls_xml(rpRunName, 'reference-pixel', startDate, endDate, ...
    	rpTargetList, rpExclusionList, rpTlsXmlName);
end

% make the target list set notification message
generate_tlsnm_xml(tlsXmlNames, generate_delivery_filename('_tlsnm.xml'));

if ~isempty(maskTableXmlFilename)
	% make the mask table notification message
	generate_mtnm_xml(maskTableXmlFilename, generate_delivery_filename('_mtnm.xml'));
end

%%%% modify required param files
% this script only takes care of the tad.param and amt.param files

% get a list of the files in this directory
filenames = dir('.');

if ~isempty(maskTableXmlFilename)
	% set the maskTableImportSourceFileName field in the amt.params file
	for i=1:length(filenames)
    	if ~isempty(strfind(filenames(i).name, 'amt.params'))
        	replace_string_in_file(filenames(i).name, {'maskTableImportSourceFileName'}, ...
            	{['maskTableImportSourceFileName=' maskTableXmlFilename{1}]});
        	break;
    	end
	end
end

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
for i=1:length(filenames)
    if ~isempty(strfind(filenames(i).name, 'tad.params_rp'))
        replace_string_in_file(filenames(i).name, ...
            {'targetListSetName', 'associatedLcTargetListSetName'}, ...
            {['targetListSetName=' rpRunName], ...
            ['associatedLcTargetListSetName=' lcRunName]});
        break;
    end
end

% set the targetListSetName and associatedLcTargetListSetName fields in 
% the tad.params_sc* file
for q=1:3
    for i=1:length(filenames)
        if ~isempty(strfind(filenames(i).name, ['tad.params_sc' num2str(q)]))
            replace_string_in_file(filenames(i).name, ...
                {'targetListSetName', 'associatedLcTargetListSetName'}, ...
                {['targetListSetName=' scRunName{q}], ...
                ['associatedLcTargetListSetName=' lcRunName]});
            break;
        end
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





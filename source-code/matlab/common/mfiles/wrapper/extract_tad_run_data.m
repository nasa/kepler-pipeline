function extract_tad_run_data(lcTargetListSetName, sc1TargetListSetName, ...
    sc2TargetListSetName, sc3TargetListSetName, rpTargetListSetName, ...
    mjd, includeRejected)
% function extract_tad_run_data(lcTargetListSetName, sc1TargetListSetName, ...
%     sc2TargetListSetName, sc3TargetListSetName, rpTargetListSetName, ...
%     mjd, includeRejected)
%
% WARNING: this function writes ~3.4 GB of data to local disk
%
% function that creates all the tad .mat files required to analyze a TAD
% run.  
% - lcTargetListSetName etc. contains the target list set names for the
%   run to be analyzed.  Any of these fields may be empty
% - mjd is any mjd date within the run
% - includeRejected = 1 for untrimmed TAD runs, = 0 for trimmed TAD runs
%
% Creates the following files for each of the target list set names:
%   - 1 file for each of 84 channels with the filename format 
%       'tadStruct_<targetListSetName>_m<module number>_o<output number>.mat'
%   - 1 file containing summary data for this run in a file with filename
%   format
%       '<targetListSetName>.mat'
%
% Also creates the following report files referring to long cadence only:
%   - targetReport.mat
%   - targetReportTable.dat
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

if ~isempty(lcTargetListSetName)
    retrieveTad(lcTargetListSetName,mjd,includeRejected);
end
if ~isempty(sc1TargetListSetName)
    retrieveTad(sc1TargetListSetName,mjd,includeRejected);
end
if ~isempty(sc2TargetListSetName)
    retrieveTad(sc2TargetListSetName,mjd,includeRejected);
end
if ~isempty(sc3TargetListSetName)
    retrieveTad(sc3TargetListSetName,mjd,includeRejected);
end
if ~isempty(rpTargetListSetName)
    retrieveTad(rpTargetListSetName,mjd,includeRejected);
end

if ~isempty(lcTargetListSetName)
    makeReport(lcTargetListSetName);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function []=retrieveTad(targetListSetName,mjd,includeRejected)
% function []=retrieveTad(targetListSetName,mjd,includeRejected)

%includeRejected=1; Must be one for Untrimmed TAD 

module=[2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,22,23,24];
output=[1,2,3,4];
tic;
tad=repmat(struct('kepid',[],'crowding',[],'snr',[],'npixInOptAp',[], ...
    'distFromEdge',[],'npixInMask',[],'skygroup',[],'rejected',[], ...
    'nTargetDefinitions',[],'labels',{}),1,84);


for i=1:length(module)
    for j=1:length(output)
        import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
        dbInstance = DatabaseServiceFactory.getInstance();
        dbInstance.clear();
        fprintf(1,'Module: %d and Output: %d\n',module(i),output(j));
        % Don't require a supplemental when extracting tad data, since this
        % is only used for flight ops.
        requireSupplemental = false;
        tadStruct=retrieve_tad(module(i),output(j),targetListSetName,includeRejected,requireSupplemental);
        if (size(tadStruct) == 0)
            continue; 
        end
                      if isempty(tadStruct.targets)
                                  continue;
                      end
        save(['tadStruct_' targetListSetName '_m' num2str(module(i)) 'o' num2str(output(j))], 'tadStruct');
%         ss=find([tadStruct.targets.keplerId] < 100000000);
%         if isempty(ss)
%             continue;
%         end
%         skygroup=retrieve_sky_group(tadStruct.targets(ss(1)).keplerId,mjd);
% 		  nsg=skygroup.skyGroupId;
% 		modKicInfo = retrieve_comprehensive_kic_info(module(i), output(j), mjd);        
% 		nsg=modKicInfo.skyGroup;
		skyGroupInfo = retrieve_sky_group(module(i), output(j), mjd);        
		nsg=skyGroupInfo.skyGroupId;
        tad(nsg).kepid=[tadStruct.targets.keplerId];
        tad(nsg).crowding=[tadStruct.targets.crowdingMetric];
                      if isfield(tadStruct, 'SNR')
          tad(nsg).snr=[tadStruct.targets.SNR];
                      elseif isfield(tadStruct, 'signalToNoiseRatio')
                          tad(nsg).snr=[tadStruct.targets.signalToNoiseRatio];
                      end
        tad(nsg).distFromEdge=[tadStruct.targets.distanceFromEdge];
        tad(nsg).skygroup=zeros(1,length([tadStruct.targets.keplerId]))+nsg;
        %tad(nsg).userDefined=[tadStruct.targets.isUserDefined];
                      if isfield(tadStruct, 'rejected')
          tad(nsg).snr=[tadStruct.targets.rejected];
                      elseif isfield(tadStruct, 'isRejected')
                          tad(nsg).snr=[tadStruct.targets.isRejected];
                      end
        tad(nsg).labels={tadStruct.targets.labels};
        tdtId=[tadStruct.targetDefinitions.keplerId];
        maskIndex=[tadStruct.targetDefinitions.maskIndex];
        for k=1:length([tadStruct.targets.keplerId])
            tad(nsg).npixInOptAp(k)=length(tadStruct.targets(k).offsets);
            ii=find(tdtId==tadStruct.targets(k).keplerId);
            if length(ii) > 0
                masks=maskIndex(ii);
                npix_tmp=0;
                for l=1:length(masks)
                    npix_tmp=npix_tmp+length(tadStruct.maskDefinitions(masks(l)+1).offsets);
                end
                tad(nsg).nTargetDefinitions(k)=length(masks);
                tad(nsg).npixInMask(k)=npix_tmp;
            else
                tad(nsg).nTargetDefinitions(k)=0;
                tad(nsg).npixInMask(k)=0;
            end
            jj=strmatch('TAD',tad(nsg).labels{k});
            tad(nsg).labels{k}(jj)=[];
            clear('masks','ii','jj')
        end
    clear('tdtId','maskIndex','tadStruct','skygroup','nsg');
    end
end
save([targetListSetName,'.mat'],'tad');
toc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function makeReport(lcName)

load([lcName,'.mat']); lc=tad;

lckepid=cat(2,lc.kepid); lcntdt=cat(2,lc.nTargetDefinitions); lcnpix=cat(2,lc.npixInMask); 
lcrejected=cat(2,lc.rejected);
ii=find(lcrejected==1);
lckepidOrig=lckepid;
lckepid(ii)=[]; lcntdt(ii)=[]; lcnpix(ii)=[]; lcrejected(ii)=[];
clear('ii');

categories = sort(retrieve_categories(lcName));
% categories={ ...
% 'ARP'; ...
% 'ASTERO_LC'; ...
% 'ASTERO_SC1'; ...
% 'ASTERO_SC2'; ...
% 'ASTERO_SC3'; ...
% 'ASTROMETRY'; ...
% 'CLUSTER'; ...
% 'EB'; ...
% 'GO_LC'; ...
% 'GO_SC1'; ...
% 'GO_SC2'; ...
% 'GO_SC3'; ...
% 'INCLUDE'; ...
% 'LEPINE'; ...
% 'PDQ_STELLAR'; ...
% 'PLANETARY'; ...
% 'PPA_LDE'; ...
% 'PPA_STELLAR'; ...
% 'ST_SC1'; ...
% 'ST_SC2'; ...
% 'ST_SC3'; ...
% 'UNCLASSIFIED' ...
% };

%identify targets with a particular category and grab relevant information from TAD struct
targets=repmat(struct('kepid',[],'nTDT',[],'npix',[],'category',{}),1,length(categories));
for i=1:length(categories)
	disp(categories{i});
	lStruct=retrieve_kepler_ids_by_label(lcName,'categories',{categories{i}});
	%targets(i).kepid=cat(1,lStruct.keplerId);
	nOrig(i)=length(intersect(lckepidOrig,[lStruct.keplerId]));
	[c,ia,ib]=intersect(lckepid,[lStruct.keplerId]);
	targets(i).kepid=lckepid(ia);
	targets(i).nTDT=lcntdt(ia);
	targets(i).npix=lcnpix(ia);
	targets(i).category=repmat(categories{i},length(ia),1);
end
clear('c','ia','ib');

save(['targetReport_' lcName '.mat'],'targets');

fid=fopen(['targetReportTable_' lcName 'dat'],'w');

fprintf(fid,'CATEGORY,NTARGET_ORIG,NTARGET,NTDT,NPIX\n');
for i=1:length(categories)
        fprintf(fid,'%s,%d, %d,%d,%d \n',categories{i},nOrig(i),length(targets(i).kepid),sum(targets(i).nTDT),sum(targets(i).npix));
end

for i=1:length(targets)
        fprintf(fid,'%s,',categories{i});
        for j=1:length(targets)
                [c,ia,ib]=intersect(targets(i).kepid,targets(j).kepid);
                if j == length(targets)
                        fprintf(fid,'%d\n',length(ia));
                else
                        fprintf(fid,'%d,',length(ia));
                end
                clear('ia');
        end
end

fclose(fid);





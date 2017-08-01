% script to run q0-q17 DAWG scripts
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
addpath /path/to/matlab/pa/test;

dawgDir = '/path/to/pa/q0-q17-r9.2-dawg/';
% paDir = '/path/to/lc/pa2/';
paDir = '/path/to/sc/pa/';
	
startingDir = pwd;

%for quarter = 0:17
for quarter = 17
    disp(['***************************** quarter ' num2str(quarter) ' ***********************************']);
	outputDir = [dawgDir 'q' num2str(quarter) '/'];
	if ~exist(outputDir, 'dir')
		mkdir(outputDir);
	end
	cd(outputDir);

if 0 % LC directory structure
    if quarter <= 13
		qString = 'q0-q13/';
	else
		qString = 'q14-q17/';
	end
	paTaskFileLocation = [paDir qString];
end
	paTaskFileLocation = [paDir 'q' num2str(quarter) '/'];

    configStruct.plotCentroids = false;
	if quarter <= 4
		configStruct.channels = 1:84;
	else
		configStruct.channels = [1:4,9:84];
	end
	
		
    if quarter == 0 || quarter == 1
        configStruct.dataType = {'sc_m1'};
        configStruct.pathName = {paTaskFileLocation};
    elseif quarter == 17
        configStruct.dataType = {'sc_m1','sc_m2'};
        configStruct.pathName = {paTaskFileLocation, paTaskFileLocation};
    else
        configStruct.dataType = {'sc_m1','sc_m2','sc_m3'};
        configStruct.pathName = {paTaskFileLocation, paTaskFileLocation, paTaskFileLocation};
    end
	
	configStruct.spiceFileDirectory = '/path/to/cache/spice/';
	
	configStruct.quarter = quarter;
	
	pa_dawg_metrics_script(configStruct);

end

cd(startingDir);

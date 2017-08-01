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
% long_target_fits_file = '/path/to/dr/incoming/kplr2010169033207_lcs-targ.fits';
fitsBaseHead = '/path/to/dr/incoming/kplr2010167034418'; % first cadence
% fitsHead = '/path/to/dr/incoming/kplr2010169033207'; % cadence 97 (counting from 1)
fitsHead = '/path/to/dr/incoming/kplr2010167041410'; % second cadence
longBaseTargetFitsFile = [fitsBaseHead '_lcs-targ.fits'];
longBaseBackFitsFile = [fitsBaseHead '_lcs-bkg.fits'];
longBaseColFitsFile = [fitsBaseHead '_lcs-col.fits'];
longTargetFitsFile = [fitsHead '_lcs-targ.fits'];
longBackFitsFile = [fitsHead '_lcs-bkg.fits'];
longColFitsFile = [fitsHead '_lcs-col.fits'];

etemFileHead = '/path/to/etem2/auto/7.5d/long/merged/mergedCadenceData-';

load configuration_files/requantizationTable.mat

% find the cadence number
info = fitsinfo(longTargetFitsFile);
for i=1:size(info.PrimaryData.Keywords)
	if strcmp(info.PrimaryData.Keywords{i,1}, 'LC_INTER')
		cadence = info.PrimaryData.Keywords{i,2};
	end	
end	
display(['cadence ' num2str(cadence)]);

etemFile = [etemFileHead num2str(cadence - 1) '.dat'];
etemFile

modules = [2:4 6:20 22:24];
nModules = 4*length(modules);

% read the etem data
fid = fopen(etemFile, 'r', 'ieee-be');
etemData = requantizationTable(fread(fid, inf, 'uint16')+1);

% build array of fits data
fitsData = [];
for i=1:nModules
	tf = fitsread(longTargetFitsFile, 'BinTable', i);
	bf = fitsread(longBaseTargetFitsFile, 'BinTable', i);
	diff = bf{1}' - tf{1}';
	fitsData = [fitsData bf{1}' + diff ];
end
for i=1:nModules
	tf = fitsread(longBackFitsFile, 'BinTable', i);
	bf = fitsread(longBaseBackFitsFile, 'BinTable', i);
	diff = bf{1}' - tf{1}';
	fitsData = [fitsData bf{1}' + diff ];
end
for i=1:nModules
	tf = fitsread(longColFitsFile, 'BinTable', i);
	bf = fitsread(longBaseColFitsFile, 'BinTable', i);
	diff = bf{1}' - tf{1}';
	fitsData = [fitsData bf{1}' + diff ];
end


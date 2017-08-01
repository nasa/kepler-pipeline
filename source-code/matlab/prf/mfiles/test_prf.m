% script to test the prf pipeline MATLAB code
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
clear;
caseStr = '_rb_xt_fast';
% if ~exist('prfInputStruct', 'var')
%     load prfInputStruct_240_m20o4_z5f5F1.mat
%     load prfInputStruct_240_m6o4_z1f1F4.mat
%     load prfInputStruct_240_m14o4_rb_xt.mat
%     load prfInputStruct_240_m14o4_source.mat
%     load prfInputStruct_240_m14o4_rb_xt_fast.mat
% end
% prfInputStruct.raDec2PixModel = retrieve_ra_dec_2_pix_model();

load(['prfInputStruct_240_m14o4' caseStr '.mat']);

prfInputStruct.prfConfigurationStruct.magnitudeRange = [12 13.5];
% prfInputStruct.prfConfigurationStruct.maximumPolyOrder = 8;
% prfInputStruct.prfConfigurationStruct.crowdingThreshold = 0.5;
% prfInputStruct.prfConfigurationStruct.prfOverlap = 0.1;
% prfInputStruct.prfConfigurationStruct.contourCutoff = 1e-3;
prfInputStruct.prfConfigurationStruct.numPrfsPerChannel = 5;

% convert input ra from degrees to hours
for t=1:length(prfInputStruct.targetStarsStruct)
    prfInputStruct.targetStarsStruct(t).ra ...
        = (24/360)*prfInputStruct.targetStarsStruct(t).ra;
end
prfResultStruct = prf_matlab_controller(prfInputStruct);
resultName = ['prfResultStruct_240_m14o4' caseStr '_'...
	num2str(prfInputStruct.prfConfigurationStruct.numPrfsPerChannel)];
eval([resultName ' = prfResultStruct']);
save(['prfResultStruct_240_m14o4' caseStr '_' ...
	num2str(prfInputStruct.prfConfigurationStruct.numPrfsPerChannel) '.mat'], resultName);

% fid = fopen(prfResultStruct.prfCollectionBlob, 'r');
% blob = fread(fid, 'uint8');
% fclose(fid);
% 
% prfObject = prfCollectionClass(blob_to_struct(blob), ...
%     prfInputStruct.fcConstants);
% draw(prfObject, [], []);
% draw(prfObject, [], [], 'contour');
% display_quality(prfObject, [], []);


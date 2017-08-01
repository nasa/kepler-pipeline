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
allLabels = { 'PDQ_STELLAR',
              'PDQ_BACKGROUND',
              'PDQ_BLACK_COLLATERAL',
              'PDQ_SMEAR_COLLATERAL',
              'PDQ_GUIDE_STAR',
              'PDQ_DYNAMIC_RANGE',
              'PPA_STELLAR',
              'PPA_2DBLACK',
              'PPA_LDE_UNDERSHOOT',
              'PLANETARY',
              'TAD_NO_HALO',
              'TAD_ONE_HALO',
              'TAD_TWO_HALOS',
              'TAD_THREE_HALOS',
              'TAD_FOUR_HALOS',
              'TAD_ADD_UNDERSHOOT_COLUMN',
              'TAD_NO_UNDERSHOOT_COLUMN',
              'TAD_DEDICATED_MASK'};
twoLabels = {'TAD_ONE_HALO', 'ASTERO_LC'};
fourLabels = {'TAD_ONE_HALO', 'ASTERO_LC', 'PLANETARY', 'PPA_STELLAR'};
categories = {'PLANETARY'};

targetListSetNames = {'quarter1_spring2009_lc',
                      'quarter1_spring2009_lc_v2'};

keplerIds = {};
for it = 1:length(targetListSetNames)
    tlsName =  targetListSetNames{it};
    for jj = 0:1
        % [it jj]
        tic, keplerIds{end+1} = retrieve_kepler_ids_by_label(tlsName,  'labels', twoLabels, jj); toc
        tic, keplerIds{end+1} = retrieve_kepler_ids_by_label(tlsName,  'labels', twoLabels, 'categories', categories, jj); toc
        tic, keplerIds{end+1} = retrieve_kepler_ids_by_label(tlsName,  'labels', fourLabels, jj); toc
        tic, keplerIds{end+1} = retrieve_kepler_ids_by_label(tlsName,  'categories', categories, jj); toc
    end
end
keplerIds{end+1} = retrieve_kepler_ids_by_label(targetListSetNames{1});
keplerIds{end+1} = retrieve_kepler_ids_by_label(targetListSetNames{1},  'labels', {'TAD'}, 1);

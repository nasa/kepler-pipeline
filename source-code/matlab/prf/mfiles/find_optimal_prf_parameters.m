function find_optimal_prf_parameters()
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

% make_data('m14o1_z1f2F4');
make_data('m20o4_z5f5F1');
make_data('m20o4_z1f1F4');
make_data('m6o4_z1f1F4');
make_data('m6o4_z5f5F1');

function make_data(prfIdString)

load(['prfInputStruct_' prfIdString '.mat']);

prfInputStruct.prfConfigurationStruct.magnitudeRange = [12 14];
prfInputStruct.prfConfigurationStruct.maximumPolyOrder = 5;
prfInputStruct.prfConfigurationStruct.crowdingThreshold = 0.5;
prfInputStruct.prfConfigurationStruct.prfOverlap = 0.1;
prfInputStruct.prfConfigurationStruct.contourCutoff = 1e-3;

magLimits = 12.5:0.5:15;
crowdingLimits = 0.3:0.1:0.7;
save analysisParameters.mat magLimits crowdingLimits;
% compare with the result for the range of parameters
for maxM = 1:length(magLimits)
    for crowding = 1:length(crowdingLimits)
        prfInputStruct.prfConfigurationStruct.magnitudeRange = [12 magLimits(maxM)];
        prfInputStruct.prfConfigurationStruct.crowdingThreshold = crowdingLimits(crowding);

        prfResultStruct = prf_matlab_controller(prfInputStruct);
        numStars(maxM, crowding) = sum([prfResultStruct.targetStarsStruct.selectedTarget]);

        filename = ['prfAnalysisData_' prfIdString '_m_' ...
            num2str(prfInputStruct.prfConfigurationStruct.magnitudeRange(1)) ...
            '-' num2str(prfInputStruct.prfConfigurationStruct.magnitudeRange(2)) ...
            '_c_' ...
            num2str(prfInputStruct.prfConfigurationStruct.crowdingThreshold) ...
            '.mat'];

        pixelPolyStruct = prfResultStruct.prfStructure.pixelPolyStruct;
        save(filename, 'pixelPolyStruct', 'numStars');
        clear prfResultStruct;
    end
end


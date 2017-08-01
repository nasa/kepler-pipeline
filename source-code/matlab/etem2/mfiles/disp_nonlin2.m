%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% NASA acknowledges the SETI Institute's primary role in authoring and
% producing the Kepler Data Processing Pipeline under Cooperative
% Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
% NNX11AI14A, NNX13AD01A & NNX13AD16A.
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
linElisaLocation = '/path/to/matlab/cal/ForBruce/calETEM_2D_ST_SM_DC_nl_lu_ff_rn_qn_sn_dir/run_long_m7o3s1/ssrOutput/';
nlinElisaLocation = '/path/to/matlab/cal/ForBruce/calETEM_2D_ST_SM_DC_NL_lu_ff_rn_qn_sn_dir/run_long_m7o3s1/ssrOutput/';

fid = fopen([linElisaLocation 'scienceCadenceData.dat'], 'r', 'ieee-be');
linElisaData = fread(fid, 'float32');
fclose(fid);

fid = fopen([nlinElisaLocation 'scienceCadenceData.dat'], 'r', 'ieee-be');
nlinElisaData = fread(fid, 'float32');
fclose(fid);

linElisaData = linElisaData - 419405;
nlinElisaData = nlinElisaData - 419405;
	
figure(10);
plot(linElisaData, linElisaData./nlinElisaData, '+');
title('elisa run mod 7 out 3');
% axis([0 3.5e6 0 1.4]);
ylabel('linear / nonlinear pixel values');
xlabel('linear pixel values (ADU)');

% linSteveLocation = 'output/nonlinearstudy/linear/run_long_m7o3s1/ssrOutput/';
% nlinSteveLocation = 'output/nonlinearstudy/nonlinear/run_long_m7o3s1/ssrOutput/';
% 
% fid = fopen([linSteveLocation 'scienceCadenceData.dat'], 'r', 'ieee-be')
% linSteveData = fread(fid, 'float32');
% fclose(fid);
% 
% fid = fopen([nlinSteveLocation 'scienceCadenceData.dat'], 'r', 'ieee-be')
% nlinSteveData = fread(fid, 'float32');
% fclose(fid);
% 
% linSteveData = linSteveData - 419405;
% nlinSteveData = nlinSteveData - 419405;
% 	
% figure(11);
% plot(linSteveData, linSteveData./nlinSteveData, '+');
% title('steve run mod 7 out 3');
% axis([0 3.5e6 0 1.4]);
% ylabel('linear / nonlinear pixel values');
% xlabel('linear pixel values (ADU)');
% 
% linSteveLocation = 'output/nonlinearstudy/linear/run_long_m12o1s1/ssrOutput/';
% nlinSteveLocation = 'output/nonlinearstudy/nonlinear/run_long_m12o1s1/ssrOutput/';
% 
% fid = fopen([linSteveLocation 'scienceCadenceData.dat'], 'r', 'ieee-be')
% linSteveData = fread(fid, 'float32');
% fclose(fid);
% 
% fid = fopen([nlinSteveLocation 'scienceCadenceData.dat'], 'r', 'ieee-be')
% nlinSteveData = fread(fid, 'float32');
% fclose(fid);
% 
% linSteveData = linSteveData - 419405;
% nlinSteveData = nlinSteveData - 419405;
% 	
% figure(12);
% plot(linSteveData, linSteveData./nlinSteveData, '+');
% title('steve run mod 12 out 1');
% axis([0 3.5e6 0 1.4]);
% ylabel('linear / nonlinear pixel values');
% xlabel('linear pixel values (ADU)');

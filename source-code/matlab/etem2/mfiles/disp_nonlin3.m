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
location = 'output/nonlinearstudy_smear_nofix/';

fid = fopen([location 'nonlinear/run_long_m7o3s1/ccdPixelPoly1.dat'], 'r', 'ieee-be');
nlp_pixPoly = fread(fid, 'float32');
fclose(fid);

fid = fopen([location 'linear/run_long_m7o3s1/ccdPixelPoly1.dat'], 'r', 'ieee-be');   
lp_pixPoly = fread(fid, 'float32');                                             
fclose(fid);

if all(nlp_pixPoly==lp_pixPoly)
	disp('ccdPixelPoly1 same');
else
	disp('ccdPixelPoly1 different !!!!!!!!!!');
end

fid = fopen([location 'nonlinear/run_long_m7o3s1/visiblePixelPoly1.dat'], 'r', 'ieee-be');
nlp_visPoly = fread(fid, 'float32');
fclose(fid);

fid = fopen([location 'linear/run_long_m7o3s1/visiblePixelPoly1.dat'], 'r', 'ieee-be');   
lp_visPoly = fread(fid, 'float32');                                             
fclose(fid);

if all(nlp_visPoly==lp_visPoly)
	disp('visiblePixelPoly1 same');
else
	disp('visiblePixelPoly1 different !!!!!!!!!!');
end


fid = fopen([location 'nonlinear/run_long_m7o3s1/ccdPixelEffectPoly1.dat'], 'r', 'ieee-be');
nlp_pixEffPoly = fread(fid, 'float32');
fclose(fid);

fid = fopen([location 'linear/run_long_m7o3s1/ccdPixelEffectPoly1.dat'], 'r', 'ieee-be');   
lp_pixEffPoly = fread(fid, 'float32');                                             
fclose(fid);

if all(nlp_pixEffPoly==lp_pixEffPoly)
	disp('ccdPixelEffectPoly1 same');
else
	disp('ccdPixelEffectPoly1 different !!!!!!!!!!');
end


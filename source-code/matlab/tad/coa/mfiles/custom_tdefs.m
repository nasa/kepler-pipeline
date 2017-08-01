%% create custom targets
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
arpImage = zeros(1070, 1132);
% put pattern in blacks
for group = 1:5
	for i=1:12
		arpImage(10 + group*160 + i*4, 1:i) = 1;
	end
	for i=0:20
		arpImage(10 + group*160 + i*4, 1132 - 20:1132 - 20 + i) = 1;
	end
end
% put pattern in smear
for group = 1:5
	for i=1:20
		arpImage(2 + group*2, 20 + group*150 + (1:i)) = 1;
		arpImage(3 + group*2, 20 + group*150 + (1:i)) = 1;
	end
	for i=0:20
		arpImage(1070 - 18 + group*2, 20 + group*150 + (1:i)) = 1;
		arpImage(1070 - 17 + group*2, 20 + group*150 + (1:i)) = 1;
	end
end
% put some strips on the visible pixels
arpImage(300, 400 + (1:20)) = 1;
arpImage(700, 200 + (1:20)) = 1;
arpImage(700, 800 + (1:20)) = 1;
arpImage(200, 900 + (1:20)) = 1;

arpTargetDefinition = image_to_target_definition(arpImage, [535, 566]);

customImage1 = rand(20, 40);
customImage1 = customImage1 > 0.5;
customTargetDefinition1 = image_to_target_definition(customImage1, [10, 20]);
customImage2 = ones(4, 200);
customTargetDefinition2 = image_to_target_definition(customImage2, [2, 100]);


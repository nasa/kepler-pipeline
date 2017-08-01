function analysisStruct = display_parameter_study()
% script to display parameter study
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

analysisStruct(1) = display_study('m20o4_z5f5F1');
analysisStruct(2) = display_study('m20o4_z1f1F4');
analysisStruct(3) = display_study('m14o1_z1f2F4');
analysisStruct(4) = display_study('m6o4_z1f1F4');
analysisStruct(5) = display_study('m6o4_z5f5F1');

draw_analysis_struct(analysisStruct);

function prfAnalysisStruct = display_study(prfIdString)
load(['prfAnalysisStruct_' prfIdString]);
prfAnalysisStruct.idString = prfIdString;
prfAnalysisStruct.norm2Error(prfAnalysisStruct.norm2Error(:) == -1) ...
	= mean(prfAnalysisStruct.norm2Error(prfAnalysisStruct.norm2Error(:) > 0));
figure;
mesh(prfAnalysisStruct.crowdingLimits, prfAnalysisStruct.magLimits, prfAnalysisStruct.norm2Error);
xlabel('crowding cutoff');
ylabel('magnitude cutoff');
title([prfIdString ' RSS error']);
for c=1:length(prfAnalysisStruct.crowdingLimits)
    for m=1:length(prfAnalysisStruct.magLimits)
        text(prfAnalysisStruct.crowdingLimits(c), prfAnalysisStruct.magLimits(m), ...
            prfAnalysisStruct.norm2Error(m,c), num2str(prfAnalysisStruct.numStars(m,c)));
    end
end

function draw_analysis_struct(analysisStruct)
%%
meanError = zeros(size(analysisStruct(1).norm2Error));
for i=1:length(analysisStruct)
    meanError = meanError + analysisStruct(i).norm2Error;
    
end
figure;
mesh(analysisStruct(1).crowdingLimits, analysisStruct(1).magLimits, meanError/length(analysisStruct));
xlabel('crowding cutoff');
ylabel('magnitude cutoff');
zlabel('mean RSS error');
title('mean RSS error');


figure
subplot(2,1,1);
m=3;
plot(analysisStruct(1).crowdingLimits, analysisStruct(1).norm2Error(m,:), 'd-', ...
    analysisStruct(2).crowdingLimits, analysisStruct(2).norm2Error(m,:), '+-', ...
    analysisStruct(3).crowdingLimits, analysisStruct(3).norm2Error(m,:), 'x-', ...
    analysisStruct(4).crowdingLimits, analysisStruct(4).norm2Error(m,:), 's-', ...
    analysisStruct(5).crowdingLimits, analysisStruct(5).norm2Error(m,:), 'o-');
title('prf RSS error vs. crowding, magnitude limit = 13.5');
xlabel('crowding cutoff');
ylabel('mean RSS error');
legend('crowded, broad', 'crowded, sharp', 'typical', 'sparse, sharp', 'sparse, broad');
subplot(2,1,2);
m=4;
plot(analysisStruct(1).crowdingLimits, analysisStruct(1).norm2Error(m,:), 'd-', ...
    analysisStruct(2).crowdingLimits, analysisStruct(2).norm2Error(m,:), '+-', ...
    analysisStruct(3).crowdingLimits, analysisStruct(3).norm2Error(m,:), 'x-', ...
    analysisStruct(4).crowdingLimits, analysisStruct(4).norm2Error(m,:), 's-', ...
    analysisStruct(5).crowdingLimits, analysisStruct(5).norm2Error(m,:), 'o-');
title('prf RSS error vs. crowding, magnitude limit = 14');
xlabel('crowding cutoff');
ylabel('mean RSS error');


figure
subplot(2,1,1);
c = 2;
plot(analysisStruct(1).magLimits, analysisStruct(1).norm2Error(:,c), 'd-', ...
    analysisStruct(2).magLimits, analysisStruct(2).norm2Error(:,c), '+-', ...
    analysisStruct(3).magLimits, analysisStruct(3).norm2Error(:,c), 'x-', ...
    analysisStruct(4).magLimits, analysisStruct(4).norm2Error(:,c), 's-', ...
    analysisStruct(5).magLimits, analysisStruct(5).norm2Error(:,c), 'o-');
title('prf RSS error vs. magnitude limit, crowding = 0.4');
xlabel('magnitude limit');
ylabel('mean RSS error');
legend('crowded, broad', 'crowded, sharp', 'typical', 'sparse, sharp', 'sparse, broad');
subplot(2,1,2);
c=3;
plot(analysisStruct(1).magLimits, analysisStruct(1).norm2Error(:,c), 'd-', ...
    analysisStruct(2).magLimits, analysisStruct(2).norm2Error(:,c), '+-', ...
    analysisStruct(3).magLimits, analysisStruct(3).norm2Error(:,c), 'x-', ...
    analysisStruct(4).magLimits, analysisStruct(4).norm2Error(:,c), 's-', ...
    analysisStruct(5).magLimits, analysisStruct(5).norm2Error(:,c), 'o-');
title('prf RSS error vs. magnitude limit, crowding = 0.5');
xlabel('magnitude limit');
ylabel('mean RSS error');


figure
subplot(2,1,1);
m=3;
for i=1:length(analysisStruct)
    a(i).val = analysisStruct(i).norm2Error(m,:) - mean(analysisStruct(i).norm2Error(m,:));
end
plot(analysisStruct(1).crowdingLimits, a(1).val, 'd-', ...
    analysisStruct(2).crowdingLimits, a(2).val, '+-', ...
    analysisStruct(3).crowdingLimits, a(3).val, 'x-', ...
    analysisStruct(4).crowdingLimits, a(4).val, 's-', ...
    analysisStruct(5).crowdingLimits, a(5).val, 'o-');
title('mean-subtracted prf RSS error vs. crowding, magnitude limit = 13.5');
xlabel('crowding cutoff');
ylabel('mean RSS error');
legend('crowded, broad', 'crowded, sharp', 'typical', 'sparse, sharp', 'sparse, broad');
subplot(2,1,2);
m=4;
for i=1:length(analysisStruct)
    a(i).val = analysisStruct(i).norm2Error(m,:) - mean(analysisStruct(i).norm2Error(m,:));
end
plot(analysisStruct(1).crowdingLimits, a(1).val, 'd-', ...
    analysisStruct(2).crowdingLimits, a(2).val, '+-', ...
    analysisStruct(3).crowdingLimits, a(3).val, 'x-', ...
    analysisStruct(4).crowdingLimits, a(4).val, 's-', ...
    analysisStruct(5).crowdingLimits, a(5).val, 'o-');
title('mean-subtracted prf RSS error vs. crowding, magnitude limit = 14');
xlabel('crowding cutoff');
ylabel('mean RSS error');


figure
subplot(2,1,1);
c = 2;
for i=1:length(analysisStruct)
    a(i).val = analysisStruct(i).norm2Error(:,c) - mean(analysisStruct(i).norm2Error(:,c));
end
plot(analysisStruct(1).magLimits, a(1).val, 'd-', ...
    analysisStruct(2).magLimits, a(2).val, '+-', ...
    analysisStruct(3).magLimits, a(3).val, 'x-', ...
    analysisStruct(4).magLimits, a(4).val, 's-', ...
    analysisStruct(5).magLimits, a(5).val, 'o-');
title('mean-subtracted prf RSS error vs. magnitude limit, crowding = 0.4');
xlabel('magnitude limit');
ylabel('mean RSS error');
legend('crowded, broad', 'crowded, sharp', 'typical', 'sparse, sharp', 'sparse, broad');
subplot(2,1,2);
c=3;
for i=1:length(analysisStruct)
    a(i).val = analysisStruct(i).norm2Error(:,c) - mean(analysisStruct(i).norm2Error(:,c));
end
plot(analysisStruct(1).magLimits, a(1).val, 'd-', ...
    analysisStruct(2).magLimits, a(2).val, '+-', ...
    analysisStruct(3).magLimits, a(3).val, 'x-', ...
    analysisStruct(4).magLimits, a(4).val, 's-', ...
    analysisStruct(5).magLimits, a(5).val, 'o-');
title('mean-subtracted prf RSS error vs. magnitude limit, crowding = 0.5');
xlabel('magnitude limit');
ylabel('mean RSS error');





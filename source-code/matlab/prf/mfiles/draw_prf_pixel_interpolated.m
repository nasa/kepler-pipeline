function centroidData = draw_prf_pixel_interpolated(prfModel, pixNum, quarter)
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

if nargin < 3
    quarter = 13;
end

dataLocation = ['/path/to/chatterMetrics/q' num2str(quarter) '/'];

chatterThreshold = 6;

if quarter >= 13
    filename = [dataLocation 'centroidData_q' num2str(quarter) ...
        '_m' num2str(prfModel.ccdModule) 'o' num2str(prfModel.ccdOutput) '.mat'];
else
    filename = [dataLocation 'centroidData_m' num2str(prfModel.ccdModule) ...
        'o' num2str(prfModel.ccdOutput) '.mat'];
end

disp(['loading ' filename]);
load(filename);

cd = [centroidData.prfCentroids];
cm = [cd.chatterMetric];
cm = cm - median(cm);
highIndex = find(cm > chatterThreshold);
lowIndex = find(cm <= chatterThreshold);

prfObject = prfCollectionClass(prfModel.blob, convert_fc_constants_java_2_struct);
[prfArray prfRow prfColumn] = draw_pixel(prfObject, pixNum, 500, 500);
prfRowCenter = mean(prfRow(:));
prfColCenter = mean(prfColumn(:));

title(['Interpolated PRF m' num2str(prfModel.ccdModule) 'o' ...
    num2str(prfModel.ccdOutput) ' pixel ' num2str(pixNum) ...
    ' quarter ' num2str(quarter)]);

hold on;

colors = {'r.' 'g.' 'y.' 'c.' 'm.' 'b.'};
for i=1:length(highIndex)
    sr = cd(highIndex(i)).row;
    sr(sr==0) = nan;
    sc = cd(highIndex(i)).col;
    sc(sc==0) = nan;
    r = nanmedian(sr);
    c = nanmedian(sc);
    dr = sr - nanmedfilt1(sr, 48);
    dc = sc - nanmedfilt1(sc, 48);
    
    subr = r - fix(r) - 0.5; % sub-row coords so 0 is in center of pixel
    subc = c - fix(c) - 0.5; % sub-row coords so 0 is in center of pixel
    
    prfR = prfRowCenter + subr + dr;
    prfC = prfColCenter + subc + dc;
    
    goodC = ~isnan(prfR);
    prfV = zeros(size(prfR));
    prfV(goodC) = interp2(prfRow', prfColumn', prfArray', prfR(goodC), prfC(goodC));
    prfV(prfV == 0) = nan;
    
    plot3(prfR, prfC, prfV, colors{mod(i, length(colors))+1});
end

for i=1:length(lowIndex)
    sr = cd(lowIndex(i)).row;
    sr(sr==0) = nan;
    sc = cd(lowIndex(i)).col;
    sc(sc==0) = nan;
    r = nanmedian(sr);
    c = nanmedian(sc);
    dr = sr - nanmedfilt1(sr, 48);
    dc = sc - nanmedfilt1(sc, 48);
    
    subr = r - fix(r) - 0.5; % sub-row coords so 0 is in center of pixel
    subc = c - fix(c) - 0.5; % sub-row coords so 0 is in center of pixel
    
    prfR = prfRowCenter + subr + dr;
    prfC = prfColCenter + subc + dc;
    
    goodC = ~isnan(prfR);
    prfV = zeros(size(prfR));
    prfV(goodC) = interp2(prfRow', prfColumn', prfArray', prfR(goodC), prfC(goodC));
    prfV(prfV == 0) = nan;
    
    plot3(prfR, prfC, prfV, 'k.');
end
hold off;

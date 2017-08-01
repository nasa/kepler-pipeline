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
nIter = 9;
%%
for i=1:nIter
    load(['firstIterationTest3/prfIteration_i' num2str(i) '.mat']);

    for m=1:4
        prfData(i,m).centroids = prfResultStruct(m).centroids;
        load(['firstIterationTest3/' prfInputStruct(m).fpgGeometryBlobsStruct.blobFilenames{1}]);
        prfData(i,m).geometryBlob = inputStruct;
        load(['firstIterationTest3/' prfResultStruct(m).prfCollectionBlobFileName]);
        prfData(i,m).prfData = inputStruct.polyStruct;
        prfData(i,m).residualMean = inputStruct.residualMean;
        prfData(i,m).residualStandardDeviation = inputStruct.residualStandardDeviation;
        
        prfObject = prfClass(inputStruct.polyStruct);
        prfArray = make_array(prfObject);
        [prfData(i,m).prfCentroid(1) prfData(i,m).prfCentroid(2)] = quick_centroid(prfArray);
    end
    clear prfResultStruct prfInputStruct fpgInputStruct fpgOutputStruct
end
%%
figure
channel = 1;
text([prfData(1,channel).centroids.rows], [prfData(1,channel).centroids.columns], '+', ...
    [prfData(2,channel).centroids.rows], [prfData(2,channel).centroids.columns], 'o', ...
    [prfData(3,channel).centroids.rows], [prfData(3,channel).centroids.columns], 'd', ...
    [prfData(4,channel).centroids.rows], [prfData(4,channel).centroids.columns], 'x', ...
    [prfData(5,channel).centroids.rows], [prfData(5,channel).centroids.columns], '*', ...
    [prfData(6,channel).centroids.rows], [prfData(6,channel).centroids.columns], 's', ...
    [prfData(7,channel).centroids.rows], [prfData(7,channel).centroids.columns], '^', ...
    [prfData(8,channel).centroids.rows], [prfData(8,channel).centroids.columns], 'v', ...
    [prfData(9,channel).centroids.rows], [prfData(9,channel).centroids.columns], '>');


%%
module = [7 9 17 19];
for i=1:nIter
    for m=1:length(module)
        load(['firstIterationTest3/centroidChangeData_m' num2str(module(m)) 'o4i' num2str(i) '.mat']);
        nStars = length(centroidChangeData.deltaCentroids);
        deltaCentroid(i,m).totalNorm = centroidChangeData.totalNorm/(nStars*121);
        deltaCentroid(i,m).averageNorm = centroidChangeData.averageNorm/121;
        deltaCentroid(i,m).maxNorm = max([centroidChangeData.deltaCentroids.norm]);
		rows = vertcat(centroidChangeData.deltaCentroids.row);
		cols = vertcat(centroidChangeData.deltaCentroids.column);
        deltaCentroid(i,m).maxDelta = max([rows(:); cols(:)]);
        deltaCentroid(i,m).data = centroidChangeData.deltaCentroids;
        deltaCentroid(i,m).rows = rows(:);
        deltaCentroid(i,m).cols = cols(:);
        deltaCentroid(i,m).rowMean = mean(rows(:));
        deltaCentroid(i,m).colMean = mean(cols(:));
        deltaCentroid(i,m).rowStd = std(rows(:));
        deltaCentroid(i,m).colStd = std(cols(:));
    end
end

%%
figure
semilogy(1:nIter, [deltaCentroid(:,1).totalNorm], '+', 1:nIter, [deltaCentroid(:,2).totalNorm], 'o', ...
	1:nIter, [deltaCentroid(:,3).totalNorm], 'd', 1:nIter, [deltaCentroid(:,4).totalNorm], 's');
xlabel('iteration');
ylabel('normalized total norm');
legend('m7o4', 'm9o4', 'm17o4', 'm19o4', 'Location', 'NorthWest');

figure
semilogy(1:nIter, [deltaCentroid(:,1).maxNorm], '+', 1:nIter, [deltaCentroid(:,2).maxNorm], 'o', ...
	1:nIter, [deltaCentroid(:,3).maxNorm], 'd', 1:nIter, [deltaCentroid(:,4).maxNorm], 's');
xlabel('iteration');
ylabel('normalized max norm');
legend('m7o4', 'm9o4', 'm17o4', 'm19o4', 'Location', 'NorthWest');

figure
semilogy(1:nIter, [deltaCentroid(:,1).averageNorm], '+', 1:nIter, [deltaCentroid(:,2).averageNorm], 'o', ...
	1:nIter, [deltaCentroid(:,3).averageNorm], 'd', 1:nIter, [deltaCentroid(:,4).averageNorm], 's');
xlabel('iteration');
ylabel('normalized average norm');
legend('m7o4', 'm9o4', 'm17o4', 'm19o4', 'Location', 'NorthWest');

figure
semilogy(1:nIter, [deltaCentroid(:,1).maxDelta], '+', 1:nIter, [deltaCentroid(:,2).maxDelta], 'o', ...
	1:nIter, [deltaCentroid(:,3).maxDelta], 'd', 1:nIter, [deltaCentroid(:,4).maxDelta], 's');
xlabel('iteration');
ylabel('maximum Delta Component');
legend('m7o4', 'm9o4', 'm17o4', 'm19o4', 'Location', 'NorthWest');

%%
for i=1:nIter
    for m=1:4
        r = prfData(i,m).residualMean;
        meanResidualMean(i,m) = mean(r(:));
        r = prfData(i,m).residualStandardDeviation;
        meanResidualStd(i,m) = mean(r(:));
    end
end


%%
figure
plot(1:nIter, [deltaCentroid(:,1).rowMean], '+', 1:nIter, [deltaCentroid(:,2).rowMean], 'o', ...
    1:nIter, [deltaCentroid(:,3).rowMean], 'd', 1:nIter, [deltaCentroid(:,4).rowMean], 's', ...
    1:nIter, [deltaCentroid(:,1).colMean], '^', 1:nIter, [deltaCentroid(:,2).colMean], '>', ...
    1:nIter, [deltaCentroid(:,3).colMean], 'v', 1:nIter, [deltaCentroid(:,4).colMean], '<');
xlabel('iteration');
ylabel('average row and column Component');
legend('m7o4 row', 'm9o4 row', 'm17o4 row', 'm19o4 row', 'm7o4 column', 'm9o4 column', 'm17o4 column', 'm19o4 column');

figure
plot(1:nIter, [deltaCentroid(:,1).rowStd], '+', 1:nIter, [deltaCentroid(:,2).rowStd], 'o', ...
    1:nIter, [deltaCentroid(:,3).rowStd], 'd', 1:nIter, [deltaCentroid(:,4).rowStd], 's', ...
    1:nIter, [deltaCentroid(:,1).colStd], '^', 1:nIter, [deltaCentroid(:,2).colStd], '>', ...
    1:nIter, [deltaCentroid(:,2).colStd], 'v', 1:nIter, [deltaCentroid(:,2).colStd], '<');
xlabel('iteration');
ylabel('standard deviation row and column Component');
legend('m7o4 row', 'm9o4 row', 'm17o4 row', 'm19o4 row', 'm7o4 column', 'm9o4 column', 'm17o4 column', 'm19o4 column');

%%
scaleFactor = 11/100;
for i=1:4
    cp = [prfData(:,i).prfCentroid];
    path(i).column = cp(1:2:end)*scaleFactor;
    path(i).row = cp(2:2:end)*scaleFactor;
end
figure
plot(path(1).row, path(1).column, '+', path(2).row, path(2).column, 'o', ...
    path(3).row, path(3).column, 'd', path(4).row, path(4).column, 's');
for i=1:4
    text(path(i).row, path(i).column, {'1', '2', '3', '4', '5', '6', '7', '8', '9'});
end
legend('m7o4', 'm9o4', 'm17o4', 'm19o4', 'Location', 'NorthWest');
xlabel('row pixels');
ylabel('column pixels');
title('PRF centroid history over iterations');
axis equal

%%
figure
channel = 4;
for i=1:9 
    subplot(2,1,1);
    d = vertcat(deltaCentroid(i,channel).data.row);
    plot(d,'+'); 
    axis([0 8000 -.6 .6]); 
    title(['iteration ' num2str(i) ' mean = ' num2str(mean(d)) ', standard deviation = ' num2str(std(d))]);

    subplot(2,1,2);
    d = vertcat(deltaCentroid(i,channel).data.column);
    plot(d,'+'); 
    axis([0 8000 -.6 .6]); 
    title(['iteration ' num2str(i) ' mean = ' num2str(mean(d)) ', standard deviation = ' num2str(std(d))]);

    pause; 
end

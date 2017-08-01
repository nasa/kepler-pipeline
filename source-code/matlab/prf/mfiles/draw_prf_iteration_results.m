function draw_prf_iteration_results(location, saveLocation, taskMapFile, asBuiltLocation)
% function draw_prf_iteration_results(dataLocation, saveLocation, taskMapFile)
% script to analyze pipeline PRF/FPG iteration results
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

dataLocation = [location '/prf-matlab-'];
taskMapArray = read_task_map(taskMapFile);

nIterations = size(taskMapArray, 1);

nChannels = size(taskMapArray, 2);

for c=1:nChannels
    for i=1:nIterations
        directoryName = [dataLocation num2str(taskMapArray(i,c).instanceId) ...
            '-' num2str(taskMapArray(i,c).taskId)];
        load([directoryName '/centroidChangeData_m' num2str(taskMapArray(i,c).module) ...
	    'o' num2str(taskMapArray(i,c).output) '.mat']);
        nStars = length(centroidChangeData.deltaCentroids);
        deltaCentroid(i,c).totalNorm = centroidChangeData.totalNorm/(nStars*121);
        deltaCentroid(i,c).averageNorm = centroidChangeData.averageNorm/121;
        deltaCentroid(i,c).maxNorm = max([centroidChangeData.deltaCentroids.norm]);
		rows = vertcat(centroidChangeData.deltaCentroids.row);
		cols = vertcat(centroidChangeData.deltaCentroids.column);
        deltaCentroid(i,c).maxDelta = max([rows(:); cols(:)]);
        deltaCentroid(i,c).data = centroidChangeData.deltaCentroids;
        deltaCentroid(i,c).rows = rows(:);
        deltaCentroid(i,c).cols = cols(:);
        deltaCentroid(i,c).rowMean = mean(rows(:));
        deltaCentroid(i,c).colMean = mean(cols(:));
        deltaCentroid(i,c).rowStd = std(rows(:));
        deltaCentroid(i,c).colStd = std(cols(:));
    
    end
    [module, output] = convert_to_module_output(c);
        
    figure(1);
    subplot(3,2,1);
    semilogy(1:nIterations, [deltaCentroid(:,c).totalNorm], '+-');
    xlabel('iteration');
    ylabel('normalized total norm');
    title(['channel ' num2str(c)]);

    subplot(3,2,2);
    semilogy(1:nIterations, [deltaCentroid(:,c).maxNorm], '+-');
    xlabel('iteration');
    ylabel('normalized max norm');
    title(['channel ' num2str(c)]);

    subplot(3,2,3);
    semilogy(1:nIterations, [deltaCentroid(:,c).averageNorm], '+-');
    xlabel('iteration');
    ylabel('normalized average norm');
    title(['channel ' num2str(c)]);

    subplot(3,2,4);
    semilogy(1:nIterations, [deltaCentroid(:,c).maxDelta], '+-');
    xlabel('iteration');
    ylabel('maximum Delta Component');
    title(['channel ' num2str(c)]);

    subplot(3,2,5);
    semilogy(1:nIterations, abs([deltaCentroid(:,c).rowMean]), '+-', ...
        1:nIterations, abs([deltaCentroid(:,c).colMean]), 'o-');
    xlabel('iteration');
    ylabel('mean centroid error');
    title(['channel ' num2str(c)]);

    subplot(3,2,6);
    semilogy(1:nIterations, [deltaCentroid(:,c).rowStd], '+-', ...
        1:nIterations, [deltaCentroid(:,c).colStd], 'o-');
    xlabel('iteration');
    ylabel('centroid error standard deviation');
    title(['channel ' num2str(c)]);
    
    saveas(gcf, [saveLocation '/centroid_convergence_channel_' num2str(c) '.fig']);
    
	
    load([directoryName '/prf-outputs-0.mat']);
    load([directoryName '/' outputsStruct.prfCollectionBlobFileName]);
    figure(2);
    subPlotIndex = [1 3 7 9 5];
    for i=1:5
        prfObject(i) = prfClass(inputStruct(i).polyStruct);
        ax(i) = subplot(3,3,subPlotIndex(i));
    	[prf(i).array, prf(i).row, prf(i).column] = make_array(prfObject(i), 100, 1);
        h = mesh(prf(i).row, prf(i).column, prf(i).array);
        set(h, 'Parent', ax(i));
        title(['channel ' num2str(c) ' m ' num2str(module) ...
            ' o ' num2str(output) ' prf ' num2str(i)]);
        xlabel('row pixel');
        ylabel('column pixel');
        axis tight;
    end
    saveas(gcf, [saveLocation '/prfs_channel_' num2str(c) '.fig']);
    
    figure(4);
    subPlotIndex = [1 3 7 9 5];
    subPlotSize = 0.3;
    subPlotPositionLeft = [0.05 0.7 0.05 0.7 0.35];
    subPlotPositionBottom = [0.6 0.6 0.05 0.05 0.35];
    for i=1:5
        subplot('Position', [subPlotPositionLeft(i), subPlotPositionBottom(i), subPlotSize, subPlotSize]);
        contour(prf(i).row, prf(i).column, prf(i).array, linspace(1e-4,max(max(prf(i).array)), 50));
        eval(['cutoffValue = inputStruct(i).prfConfigurationStruct.contourCutoffPrf' ...
            num2str(i) '(' num2str(c) ');']);
        hold on;
        contour(prf(i).row, prf(i).column, prf(i).array, [cutoffValue cutoffValue], 'Color', 'Red');
        title(['channel ' num2str(c) ' m ' num2str(module) ...
            ' o ' num2str(output) ' prf ' num2str(i)]);
        hold off;
        
        xlabel('row pixel');
        ylabel('column pixel');
        axis equal;
    end
    saveas(gcf, [saveLocation '/prfs_contour_channel_' num2str(c) '.fig']);

	figure(3);
	for i=1:nIterations 
    	subplot(nIterations,2,2*i-1);
    	d = vertcat(deltaCentroid(i,c).data.row);
    	plot(d,'+'); 
    	axis([0 length(d) -.6 .6]); 
    	title(['channel ' num2str(c)  ' m ' num2str(module) ...
            ' o ' num2str(output) ' iteration ' num2str(i) ' mean = ' ...
            num2str(mean(d)) ', standard deviation = ' num2str(std(d))]);

    	subplot(nIterations,2,2*i);
    	d = vertcat(deltaCentroid(i,c).data.column);
    	plot(d,'+'); 
    	axis([0 length(d) -.6 .6]); 
    	title(['channel ' num2str(c) ' m ' num2str(module) ...
            ' o ' num2str(output) ' iteration ' num2str(i) ...
            ' mean = ' num2str(mean(d)) ', standard deviation = ' num2str(std(d))]);
	end
    saveas(gcf, [saveLocation '/delta_centroid_component_channel_' num2str(c) '.fig']);
    
	% now draw the as-built for comparison
	filename = sprintf([asBuiltLocation '%02d%d_prf.bin'], ...
    	module, output);
	fid = fopen(filename, 'r');
	sourcePrfObject = prfClass(blob_to_struct(fread(fid, 'uint8')));
	fclose(fid);
	
	[prfArray, prfRow, prfColumn] = make_array(sourcePrfObject, 100, 1);
	amplitude = sum(sum(prf(5).array.*prfArray))/sum(sum(prfArray.^2));
	prfArray = amplitude*prfArray;
	
	figure(6);
    contour(prfRow, prfColumn, prfArray, linspace(1e-4,max(max(prfArray)), 50));
    hold on;
    contour(prfRow, prfColumn, prfArray, [cutoffValue cutoffValue], 'Color', 'Red');
    title(['channel ' num2str(c) ' m ' num2str(module) ...
        ' o ' num2str(output) ' as built prf']);
	hold off;
    xlabel('row pixel');
    ylabel('column pixel');
    axis equal;
	
    saveas(gcf, [saveLocation '/source_prf_contour_channel_' num2str(c) '.fig']);
	close all;
end

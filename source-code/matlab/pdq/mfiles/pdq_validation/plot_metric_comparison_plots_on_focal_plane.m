function plot_metric_comparison_plots_on_focal_plane(commonStruct, metricStruct)
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

printJpgFlag = true;
ccdModuleTilesInFocalPlane = commonStruct.ccdModuleTilesInFocalPlane;
modOutTilesInFocalPlane = commonStruct.modOutTilesInFocalPlane;
pdqModuleOutputTsData = commonStruct.pdqModuleOutputTsData;
nModOuts = commonStruct.nModOuts;
cadenceTimeStamps = commonStruct.cadenceTimeStamps;
version1Str = commonStruct.version1Str;
version2Str = commonStruct.version2Str;


metricValues1 = metricStruct.metricValues1;
metricValues2 = metricStruct.metricValues2;
metricUncertainties = metricStruct.metricUncertainties;
metricNameString = metricStruct.metricNameString;
annotateString1 = metricStruct.annotateString1;
annotateString2 = metricStruct.annotateString2;
figureFileName1 = metricStruct.figureFileName1;
figureFileName2 = metricStruct.figureFileName2;


fh1 = figure(1);
fh2 = figure(2);

printHeader = true;

fileNameString = [metricNameString ' Anomaly Report.txt'];
fileNameString = strrep(fileNameString, ' ', '_');
fid = -1;

for j = 1:nModOuts
    
    ccdModule = pdqModuleOutputTsData(j).ccdModule;
    ccdOutput = pdqModuleOutputTsData(j).ccdOutput;
    
    indexOfCcdModuleInMatrix = find(ccdModuleTilesInFocalPlane == ccdModule);
    indexOfModOut = find(modOutTilesInFocalPlane(indexOfCcdModuleInMatrix) == ccdOutput);
    
    modOut = convert_from_module_output(ccdModule,ccdOutput);
    
    set(0,'CurrentFigure',fh1);
    subplot(10,10, indexOfCcdModuleInMatrix(indexOfModOut));
    
    
    validCadences1 = find(metricValues1(j,:) ~= -1);
    validCadences2 = find(metricValues2(j,:) ~= -1);
    
    
    if(isempty(validCadences1) && isempty(validCadences2))
        continue;
    end
    
    changeInMetricValues = metricValues2(j,:) - metricValues1(j,:);
    
    validUncertaintiesIndex = find( (metricUncertainties(j,:) ~= -1) & (metricUncertainties(j,:) ~= 0));
    if(any(abs(changeInMetricValues(validUncertaintiesIndex)) > metricUncertainties(j,validUncertaintiesIndex)))
        
        if(printHeader)
            fid = fopen(fileNameString, 'wt');
            if(fid == -1)
                error('PDQValidation:plot_focal_plane_metric_comparison_plots:unableToOpenTextFileForWriting',...
                    'PDQValidation:plot_focal_plane_metric_comparison_plots: unable to open a text file for recording results; can''t proceed, so quitting PDQ Validation  ');
            end
        end
        print_report_changes_to_metric(metricValues2(j,:), metricValues1(j,:), metricUncertainties, metricNameString, ...
            cadenceTimeStamps, printHeader, fid, ccdModule, ccdOutput, modOut,version1Str,version2Str );
        printHeader = false;
        
    end
    
    
    if(~isempty(validCadences1))
        h1 = plot(validCadences1, metricValues1(j,validCadences1),'ro-');
    end
    hold on;
    
    if(~isempty(validCadences2))
        h2 = plot(validCadences2, metricValues2(j,validCadences2) ,'b.-');
    end
    lastCadence = validCadences2(end)+1;
    xlim([0 lastCadence+2]);
    set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
    
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    title(modOutStr, 'Color','k', 'fontweight', 'bold');
    
    set(0,'CurrentFigure',fh2);
    subplot(10,10, indexOfCcdModuleInMatrix(indexOfModOut));
    
    h3 = plot(validCadences2, metricUncertainties(j,validCadences2),'b.--');
    hold on;
    h4 = plot(validCadences2, -metricUncertainties(j,validCadences2),'b.--');
    h5 = plot(validCadences2, metricValues2(j,validCadences2) - metricValues1(j,validCadences2),'m.-');
    
    
    xlim([0 lastCadence+2]);
    set(gca, 'xTick', 0:lastCadence:lastCadence+2, 'xTickLabel', [1 lastCadence]');
    
    set(gca, 'fontsize', 8);
    
    modOutStr = {[num2str(modOut) ' [' num2str(ccdModule) ',' num2str(ccdOutput) ']']};
    title(modOutStr, 'Color','k', 'fontweight', 'bold');
    
end

set(0,'CurrentFigure',fh1);
ah1 = annotation('textbox',[0.35 0.95 0.5 0.05], 'LineStyle', 'none');
set(ah1, 'String', annotateString1, 'fontsize', 12)

saveas(gcf, [figureFileName1 '.fig']);


set(0,'CurrentFigure',fh2);
ah2 = annotation('textbox',[0.3 0.95 0.5 0.05], 'LineStyle', 'none');
set(ah2, 'String', annotateString2, 'fontsize', 12)

saveas(gcf, [figureFileName2 '.fig']);

if(printJpgFlag)
    
    set(0,'CurrentFigure',fh2);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperType', 'C');
    
    set(gcf, 'PaperPosition',[0 0 22 17]);
    
    %     fprintf('\n\nSaving the plot to a file named %s \n', fileName);
    %     fprintf('Please wait....\n\n');
    
    print('-djpeg', '-zbuffer', [figureFileName2 '.jpg']);
    
end
if(printJpgFlag)
    
    set(0,'CurrentFigure',fh1);
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperType', 'C');
    
    set(gcf, 'PaperPosition',[0 0 22 17]);
    
    %     fprintf('\n\nSaving the plot to a file named %s \n', fileName);
    %     fprintf('Please wait....\n\n');
    
    print('-djpeg', '-zbuffer', [figureFileName1 '.jpg']);
    
end



if(fid ~= -1)
    if(~printHeader)
        
        fprintf(fid, '________________________________________________________________________________________________________________________\n\n');
        fprintf(     '________________________________________________________________________________________________________________________\n\n');
    end
    fclose(fid);
end

return

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function print_report_changes_to_metric(metricValues2, metricValues1, metricUncertainties, metricNameString,...
    cadenceTimeStamps, printHeader, fid, ccdModule, ccdOutput, modOut,version1Str,version2Str )
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


metricValues1 = metricValues1(:);
metricValues2 = metricValues2(:);
metricUncertainties = metricUncertainties(:);

if(printHeader)
    
    fprintf(fid, '\n\n________________________________________________________________________________________________________________________\n\n');
    fprintf(     '\n\n________________________________________________________________________________________________________________________\n\n');
    
    fprintf(fid, '%s \n', metricNameString);
    fprintf('%s \n', metricNameString);
    
    fprintf(fid, '________________________________________________________________________________________________________________________\n');
    fprintf(     '________________________________________________________________________________________________________________________\n');
end


fprintf(fid, '\n%s Discrepancies Detected for ccd module = %d, ccd output = %d, modout = %d\n', metricNameString, ccdModule, ccdOutput, modOut);
fprintf('\n%s Discrepancies Detected for ccd module = %d, ccd output = %d, modout = %d\n', metricNameString, ccdModule, ccdOutput, modOut);

fprintf(fid, '------------------------------------------------------------------------------------------------------------------------\n');
fprintf('------------------------------------------------------------------------------------------------------------------------\n');

if(length(version1Str) > 20)
    version1Str = version1Str(1:20);
else
    spaceStr = repmat(' ', 1, 20-length(version1Str));
    version1Str = [version1Str spaceStr];
end
if(length(version2Str) > 20)
    version2Str = version2Str(1:20);
else
    spaceStr = repmat(' ', 1, 20-length(version2Str));
    version2Str = [version2Str spaceStr];
end



fprintf(fid, '| TimeStamp MJD | TimeStamp UTC          |  %s  |  %s |  Difference  |  Uncertainty |\n', version1Str, version2Str);
fprintf( '| TimeStamp MJD | TimeStamp UTC          |  %s  |  %s |  Difference  |  Uncertainty |\n', version1Str, version2Str);


nCadences = length(cadenceTimeStamps);

for jCadence = 1:nCadences
    
    changeInMetricValues = metricValues2(jCadence) - metricValues1(jCadence);
    if(metricUncertainties(jCadence) ~= -1)
        
        if(abs(changeInMetricValues) > metricUncertainties(jCadence))
            
            cadenceTimesUtcString = mjd_to_utc(cadenceTimeStamps(jCadence));
            fprintf(fid, '|  %f | %s |       %12.2f     |       %12.2f    |%14.4f|%14.4f|\n', ...
                cadenceTimeStamps(jCadence), cadenceTimesUtcString, metricValues1(jCadence),metricValues2(jCadence), ...
                abs(metricValues1(jCadence) - metricValues2(jCadence)), metricUncertainties(jCadence));
            fprintf( '|  %f | %s |       %12.2f     |       %12.2f    |%14.4f|%14.4f|\n', ...
                cadenceTimeStamps(jCadence), cadenceTimesUtcString, metricValues1(jCadence),metricValues2(jCadence), ...
                abs(metricValues1(jCadence) - metricValues2(jCadence)), metricUncertainties(jCadence));
        end
    end
    
end

return
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

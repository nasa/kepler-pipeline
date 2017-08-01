function print_alerts_report(pdqOutputStruct)

% pdqOutputStruct.errorCrossingsSummary
%
% ans =
%
%     metricName: {2x1 cell}
%     crossTimes: {2x1 cell}
%     normValues: {2x1 cell}
%         module: [2x1 double]
%         output: [2x1 double]
%          index: [2x1 double]
%
% pdqOutputStruct.errorPredictionsSummary
%
% ans =
%
%     metricName: {}
%      crossTime: []
%         module: []
%         output: []
%          index: []
%
%
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

nFixedBoundsBroken = length(pdqOutputStruct.errorCrossingsSummary.metricName);


%--------------------------------------------------------------------------------------------------
% Fixed bound crossing
%--------------------------------------------------------------------------------------------------

fid = fopen('PDQ_Fixed_Bound_Crossings_Report.txt', 'wt');
if(nFixedBoundsBroken > 0)



    fprintf(fid, '|------------------------------------------------------------------------------|\n');
    fprintf(fid, '| Module/Output                Metric Name             MJD         Metric Value|\n');
    fprintf(fid, '|  [ModOut]                                                          in Sigma  |\n');
    fprintf(fid, '|------------------------------------------------------------------------------|\n');


    for j = 1:nFixedBoundsBroken

        metricName = pdqOutputStruct.errorCrossingsSummary.metricName{j};
        crossTimes = pdqOutputStruct.errorCrossingsSummary.crossTimes{j};
        normValues = pdqOutputStruct.errorCrossingsSummary.normValues{j};

        module = pdqOutputStruct.errorCrossingsSummary.module(j);
        output = pdqOutputStruct.errorCrossingsSummary.output(j);
        modout = pdqOutputStruct.errorCrossingsSummary.index(j);

        for k =1:length(crossTimes)

            if(modout ~= 0)

                fprintf(fid, '| %2d/%1d [%2d]       %27s      %12.5f     %10.3f |\n', module, output, modout, metricName, crossTimes(k), normValues(k));
                fprintf(fid, '|------------------------------------------------------------------------------|\n');

            else

                fprintf(fid, '| Focal Plane     %27s      %12.5f     %10.3f |\n',  metricName, crossTimes(k), normValues(k));
                fprintf(fid, '|------------------------------------------------------------------------------|\n');

            end

        end
    end

    fclose(fid);

else
    fprintf('No fixed bounds were crossed... no report to print!\n');
    fprintf(fid, 'No fixed bounds were crossed!\n');
    fclose(fid);
end

%--------------------------------------------------------------------------------------------------
% Fixed bound crossing predictions
%--------------------------------------------------------------------------------------------------

nFixedBoundPredictedToBeBroken = length(pdqOutputStruct.errorPredictionsSummary.metricName);
fid = fopen('PDQ_Fixed_Bound_Crossing_Prediction_Report.txt', 'wt');

if(nFixedBoundPredictedToBeBroken > 0)



    fprintf(fid, '|------------------------------------------------------------------|\n');
    fprintf(fid, '| Module/Output                Metric Name             MJD         |\n');
    fprintf(fid, '|  [ModOut]                                                        |\n');
    fprintf(fid, '|------------------------------------------------------------------|\n');


    for j = 1:nFixedBoundPredictedToBeBroken

        metricName = pdqOutputStruct.errorPredictionsSummary.metricName{j};
        crossTimes = pdqOutputStruct.errorPredictionsSummary.crossTime(j);

        module = pdqOutputStruct.errorPredictionsSummary.module(j);
        output = pdqOutputStruct.errorPredictionsSummary.output(j);
        modout = pdqOutputStruct.errorPredictionsSummary.index(j);

        for k =1:length(crossTimes)

            if(modout ~= 0)
                fprintf(fid, '| %2d/%1d [%2d]       %27s      %12.5f    |\n', module, output, modout, metricName, crossTimes(k));
                fprintf(fid, '|------------------------------------------------------------------|\n');

            else
                fprintf(fid, '| Focal Plane     %27s      %12.5f    |\n',  metricName, crossTimes(k) );
                fprintf(fid, '|------------------------------------------------------------------|\n');

            end



        end
    end

    fclose(fid);

else
    fprintf('No fixed bounds were predicted to be broken... no report to print!\n');
    fprintf(fid, 'No fixed bounds were predicted to be broken!\n');
    fclose(fid);
end


%--------------------------------------------------------------------------------------------------
% Adaptive bound crossings
%--------------------------------------------------------------------------------------------------


nAdaptiveBoundsBroken = length(pdqOutputStruct.warningCrossingsSummary.metricName);

fid = fopen('PDQ_Adaptive_Bound_Crossings_Report.txt', 'wt');
if(nAdaptiveBoundsBroken > 0)


    fprintf(fid, '|------------------------------------------------------------------------------|\n');
    fprintf(fid, '| Module/Output                Metric Name             MJD         Metric Value|\n');
    fprintf(fid, '|  [ModOut]                                                          in Sigma  |\n');
    fprintf(fid, '|------------------------------------------------------------------------------|\n');


    for j = 1:nAdaptiveBoundsBroken

        metricName = pdqOutputStruct.warningCrossingsSummary.metricName{j};
        crossTimes = pdqOutputStruct.warningCrossingsSummary.crossTimes{j};
        normValues = pdqOutputStruct.warningCrossingsSummary.normValues{j};

        module = pdqOutputStruct.warningCrossingsSummary.module(j);
        output = pdqOutputStruct.warningCrossingsSummary.output(j);
        modout = pdqOutputStruct.warningCrossingsSummary.index(j);

        for k =1:length(crossTimes)

            if(modout ~= 0)

                fprintf(fid, '| %2d/%1d [%2d]       %27s      %12.5f     %10.3f |\n', module, output, modout, metricName, crossTimes(k), normValues(k));
                fprintf(fid, '|------------------------------------------------------------------------------|\n');
            else
                fprintf(fid, '| Focal Plane     %27s      %12.5f     %10.3f |\n',  metricName, crossTimes(k), normValues(k));
                fprintf(fid, '|------------------------------------------------------------------------------|\n');

            end
        end

    end

    fclose(fid);
else
    fprintf('No adaptive bounds were broken... no report to print!\n');
    fprintf(fid, 'No adaptive bounds were broken!\n');
    fclose(fid);
end


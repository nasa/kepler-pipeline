% identify_saturated_targets.m
%
% attitudeSolutionStruct(1)
% ans =
%             raStars: [312x1 double]
%            decStars: [312x1 double]
%        centroidRows: [312x1 double]
%     centroidColumns: [312x1 double]
%        CcentroidRow: [312x312 double]
%     CcentroidColumn: [312x312 double]
%           ccdModule: [312x1 double]
%           ccdOutput: [312x1 double]
%     nominalPointing: [290.670892718604 44.4954655450556 -0.00163825162992222]
%         cadenceTime: 54964.0212106088
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

% inputsStruct.stellarPdqTargets(1)
% ans =
%                  ccdModule: 2
%                  ccdOutput: 1
%                     labels: {'PDQ_STELLAR'}
%            referencePixels: [1x122 struct]
%                   keplerId: 7870062
%                    raHours: 18.80324
%                 decDegrees: 43.64218
%                  keplerMag: 11.8680000305176
%     fluxFractionInAperture: 0.952910318068244

close all;
clc;
nTargets = length(attitudeSolutionStruct(1).raStars);


inputRaHour = cat(1,inputsStruct.stellarPdqTargets.raHours);
inputDec = cat(1,inputsStruct.stellarPdqTargets.decDegrees);
kepMag = cat(1,inputsStruct.stellarPdqTargets.keplerMag);
attitudeSolutionStruct(1).kepMag = zeros(nTargets,1);

for j = 1:nTargets


    raHours = attitudeSolutionStruct(1).raStars(j)/15;
    dec = attitudeSolutionStruct(1).decStars(j);

    [a, b, c] = intersect(single([inputRaHour, inputDec]), single([raHours, dec]), 'rows');

    if(~isempty(c))
        attitudeSolutionStruct(1).kepMag(j) = kepMag(b);
    else
        fprintf('couldn''t find mag..\n');

    end


end

%%
attitudeSolutionStruct = pdqOutputStruct.attitudeSolutionUncertaintyStruct;
kepMag = attitudeSolutionStruct(1).keplerMags;

figure;
for k = 1:length(attitudeSolutionStruct)
    crowsigma = sqrt(diag(attitudeSolutionStruct(k).CcentroidRow));
    ccolsigma = sqrt(diag(attitudeSolutionStruct(k).CcentroidColumn));

    robustWts = attitudeSolutionStruct(k).robustWeights;

    cols = attitudeSolutionStruct(k).centroidColumns;
    rows = attitudeSolutionStruct(k).centroidRows;
    validColIndex = find(cols ~= -1);
    validRowIndex = find(rows ~= -1);

    %subplot(2,1,1)
    h1 = plot(kepMag(validColIndex),ccolsigma(validColIndex),  'rp');
    text(kepMag(validColIndex),ccolsigma(validColIndex), {num2str(validColIndex)},'color','r');
    hold on;
    h2 = plot(kepMag(validRowIndex),crowsigma(validRowIndex),  'bp');
    text(kepMag(validRowIndex),crowsigma(validRowIndex), {num2str(validRowIndex)},'color','b');



    legend([h1 h2], {'uncertainties in centroid columns';'uncertainties in centroid rows'});

    title(['PDQ Stellar targets: magnitude versus uncertainties in the centroid row/centroid column for cadence ' num2str(k)]);
    xlabel('kepler magnitude')
    ylabel('uncertainties in \sigma')


    rowZeroIndex = find(robustWts(1:length(validRowIndex)) == 0 );
    %  rowZeroIndex = find(robustWts(1:length(validRowIndex)) <= 0.2 );

    h3 = [];

    if(~isempty(rowZeroIndex))
        h3 = plot(kepMag(validRowIndex(rowZeroIndex)),crowsigma(validRowIndex(rowZeroIndex)),  'ks','MarkerEdgeColor','k',...
            'MarkerFaceColor',[1 .49  .63],'MarkerSize', 8);
        hold on;
    end


    colZeroIndex = find(robustWts(length(validRowIndex)+1:end) == 0 );
    %colZeroIndex = find(robustWts(length(validRowIndex)+1:end) <= 0.2 );
    h4 = [];

    if(~isempty(colZeroIndex))

        h4 = plot(kepMag(validColIndex(colZeroIndex)),ccolsigma(validColIndex(colZeroIndex)),  'ms',  'MarkerEdgeColor','k',...
            'MarkerFaceColor',[.49 1 .63],'MarkerSize', 8);

        hold on;
        if(~isempty(h3))
            legend([h1 h2 h3 h4], {'uncertainties in centroid columns';'uncertainties in centroid rows';'centroid rows ignored ignored by robust wt';'centroid columns ignored by robust wt'});
        end

        if(isempty(h3))
            legend([h1 h2 h4], {'uncertainties in centroid columns';'uncertainties in centroid rows';'centroid columns ignored by robust wt'});
        end
    else

        if(~isempty(h3))
            legend([h1 h2 h3 ], {'uncertainties in centroid columns';'uncertainties in centroid rows';'centroid rows ignored ignored by robust wt';});
        else

            legend([h1 h2], {'uncertainties in centroid columns';'uncertainties in centroid rows';});
        end


    end


    %     title(['PDQ Stellar targets: magnitude versus robust weights for cadence ' num2str(k)]);
    %     xlabel('kepler magnitude')
    %     ylabel('robust weights assigned by nlinfit')


    %     subplot(2,1,2)
    %
    %     h3 = plot(kepMag(validRowIndex),robustWts(1:length(validRowIndex)),  'bp');
    %     hold on;
    %     text(kepMag(validRowIndex),robustWts(1:length(validRowIndex)), {num2str(validRowIndex)},'color','b');
    %
    %     h4 = plot(kepMag(validColIndex),robustWts(length(validRowIndex)+1:end),  'rp');
    %     text(kepMag(validColIndex),robustWts(length(validRowIndex)+1:end), {num2str(validColIndex)},'color','r');
    %
    %
    %     legend([h3 h4], {'robust wts for centroid rows';'robust wts for centroid columns'});
    %     title(['PDQ Stellar targets: magnitude versus robust weights for cadence ' num2str(k)]);
    %     xlabel('kepler magnitude')
    %     ylabel('robust weights assigned by nlinfit')


    paperOrientationFlag = false;
    includeTimeFlag = false;
    printJpgFlag = true;

    fileNameStr = ['PDQ magnitude versus uncertainties in the centroid for cadence ' num2str(k)];
    plot_to_file(fileNameStr, paperOrientationFlag, includeTimeFlag, printJpgFlag);
    close all;
end







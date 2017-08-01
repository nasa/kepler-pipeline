function [requantizationResultsStruct] = requantization_matlab_controller(requantizationInputStruct)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function [requantizationResultsStruct] =
% requantization_matlab_controller(requantizationInputStruct) This function
% forms the MATLAB side of the science interface and it receives inputs via
% the structure requantizationInputStruct. It first calls the constructor
% for the requantizationClass with requantizationInputStruct as input where
% the fields of the input structure are validated. Then it invokes the
% method generate_requantization_table on this object and obtains the
% requantization table as an output. Relevant fields are copied to the
% requantizationResultsStruct structure and returned to the java side of
% the controller.
%
% Input: A data structure 'requantizationInputStruct' with the following fields:
%     requantModuleParameters: [1x1 struct]
%                 scConfigParameters: [1x1 struct]
%                    twoDBlackModels: [1x84 struct]
%                          gainModel: [1x1 struct]
%                     readNoiseModel: [1x1 struct]
%                        fcConstants: [1x1 struct]
% ........................................................
% requantizationInputStruct.requantModuleParameters
% ........................................................
%                                  guardBandHigh: 0.0500
%                           quantizationFraction: 0.2500
%     expectedSmearMaxBlackCorrectedPerReadInAdu: 533
%     expectedSmearMinBlackCorrectedPerReadInAdu: 0.4400
%            rssOutOriginalQuantizationNoiseFlag: 1
%                                      debugFlag: 3
% ........................................................
%  requantizationInputStruct.scConfigParameters
% ........................................................
%                          scConfigId: 1
%                                 mjd: 55000
%             fgsFramesPerIntegration: 59
%             millisecondsPerFgsFrame: 103.79
%              millisecondsPerReadout: 518.95
%         integrationsPerShortCadence: 9
%         shortCadencesPerLongCadence: 30
%             longCadencesPerBaseline: 48
%           integrationsPerScienceFfi: 270
%                       smearStartRow: 1047
%                         smearEndRow: 1051
%                       smearStartCol: 12
%                         smearEndCol: 1111
%                      maskedStartRow: 3
%                        maskedEndRow: 7
%                      maskedStartCol: 12
%                        maskedEndCol: 1111
%                        darkStartRow: 0
%                          darkEndRow: 1069
%                        darkStartCol: 3
%                          darkEndCol: 7
%                  requantFixedOffset: 80000
% ........................................................
%  requantizationInputStruct.twoDBlackModels
% ........................................................
%                 1x84 struct array with fields:
%                 mjds
%                 rows
%                 columns
%                 blacks
%                 uncertainties
% ........................................................
%  requantizationInputStruct.gainModel
% ........................................................
%                  mjds: 54505
%             constants: [1x1 struct]
% ........................................................
%  requantizationInputStruct.readNoiseModel
% ........................................................
%                  mjds: 54504
%             constants: [1x1 struct]
% ........................................................
% requantInputsStruct.fcConstants
% ........................................................
%                                 BITS_IN_ADC: 14
%                                nRowsImaging: 1024
%                                nColsImaging: 1100
%                               nLeadingBlack: 12
%                              nTrailingBlack: 20
%                               nVirtualSmear: 26
%                                nMaskedSmear: 20
%                        REQUANT_TABLE_LENGTH: 65536 (2^16)
%                     REQUANT_TABLE_MIN_VALUE: 0
%                     REQUANT_TABLE_MAX_VALUE: 8388607 (2^23-1)
%                     MEAN_BLACK_TABLE_LENGTH: 84
%                  MEAN_BLACK_TABLE_MIN_VALUE: 0
%                  MEAN_BLACK_TABLE_MAX_VALUE: 16383 (2^14-1)
%                              MODULE_OUTPUTS: 84
%
% Output:
%
% requantizationOutputStruct =
%                       requantizationTable: [65536x1 double]
%                  requantizationMainStruct: [1x1 struct]
%                   requantizationLowStruct: [1x1 struct]
%                  requantizationHighStruct: [1x1 struct]
%     requantizationMainTableVerifyFraction: [56623x1 double]
%                            tableLengthLow: 4456
%                           tableLengthMain: 56624
%                           tableLengthHigh: 4456
%                            meanBlackTable: [84x1 double]
%                               fixedOffset: 420000
% requantizationResultsStruct =
%       requantTable.requantEntries
%       requantTable.meanBlackEntries
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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

% make sure the module interface gets all the models for the most
% recent mjd (Jon thinks that we might want to run this code on earlier
% black2D, read noise, gain models for comparison purposes)

% validate the inputs
fprintf('GAR:Requantization:Validating inputs...\n');
requantizationInputStruct = validate_requantization_inputs(requantizationInputStruct);

% extract compact structure (also save it as a .mat file)
fprintf('GAR:Requantization:Extracting compact data structure from input data...\n');
compactInputStruct = extract_compact_data_structure(requantizationInputStruct);

% instantiate table object
requantizationTableObject = requantizationTableClass(compactInputStruct);


% selectively clear the 84 2D black models
requantizationInputStruct.twoDBlackModels = [];


% should we report back to the user that the high end of the table occupies  <
% .05*(2^16) (allotted for upper guard band?)

% generate the requant table
fprintf('GAR:Requantization:Generating requantization table...\n');
requantizationOutputStruct = generate_requantization_table(requantizationTableObject);

% validate the outputs using the unit tests already written
fprintf('GAR:Requantization:Validating the requantization table...\n');
validate_requantization_outputs(requantizationOutputStruct, requantizationInputStruct);




if(requantizationInputStruct.requantModuleParameters.debugFlag)

    fprintf('GAR:Requantization:Saving outputs as a .mat file...\n');

    dateString = datestr(now);
    dateString = strrep(dateString, '-', '_');
    dateString = strrep(dateString, ' ', '_');
    dateString = strrep(dateString, ':', '_');
    % time stamp the file
    fileName = ['requantization_run_' dateString '.mat'];

    save(fileName, 'requantizationInputStruct', 'requantizationOutputStruct');
end;

% prepare results to return back to the module interface
requantTable = struct('externalId', -1, 'startMjd', -1, 'endMjd', -1, 'requantEntries', [], 'meanBlackEntries', []);

requantizationResultsStruct.requantTable = requantTable;
requantizationResultsStruct.requantTable.requantEntries = requantizationOutputStruct.requantizationTable;
requantizationResultsStruct.requantTable.meanBlackEntries = requantizationOutputStruct.meanBlackTable;

close all;

return;





%--------------------------------------------------------------------------
% an excerpt from Jon's email dated 5/12/2008
%--------------------------------------------------------------------------

%  If we say that the maximum number of co-adds is 512 (for a long
%  cadence to avoid wrapping), and take the fixed offset to be the
%  nominal value for the lower guard band in ADU, then we have
%  FIXED_OFFSET = .05*(2^14-1)*512 = 419404.8
%
%  It's hard to imagine being broken if we use this value (or a value
%  close to it), given that the hardware was supposed to put the black
%  measurements at this position.
%
%  Should we adopt a value of 419,400?
%
%  This should be more than adequate to guard against underflows when
%  handling pixels. If we take the maximum negative deviation from the
%  mean black to be 15 ADU, and 512 co-adds and assume 10 black, masked
%  smear and virtual smear rows, then the largest negative collateral
%  pixel value would be 15*512*10 = 76,800.
%
%  The value of the fixed offset should not affect the mean black table
%  values. Can we change the fixed offset to 419405, as I recommended to Jeb?






%--------------------------------------------------------------------------
% Jon's quick analysis using 1 day ETEM2 run using new requantization table
%
% based on the histogram computes the theoretical compression rate in bits
% per pixel
%--------------------------------------------------------------------------

% fid = fopen('requantizedCadenceData.dat', 'r', 'ieee-be');
% 
% x = fread(fid, inf, 'uint32');
% 
% % number of cadences in the file 49
% xi = interp1(requantizationTable,(1:length(requantizationTable)),x,'near');
% 
% x = reshape(x,52760,49);
% 
% xi = reshape(xi,52760,49);
% 
% plot(xi(1,:))
% plot(xi(1:100,:)')
% 
% xiResidual = xi-repmat(xi(:,1),1,49); % subtracting baseline
% 
% [nn,xx] = hist(colvec(xiResidual(:,2:end-1)),(-2^16:2^16)); % ignore the first baseline cadence
% 
% freqSymbols = nn/sum(nn);
% theoreticalEntropy =  -sum(freqSymbols(freqSymbols>0).*log2(freqSymbols(freqSymbols>0)));
% 
% maxPossibleCompression =   (48*theoreticalEntropy + 16)/48; % 16 bits are required to encode the baseline pixel
% 
% %(48*5+16)/48
% 
% semilogy(xx,nn)




function [mapByQuarterStruct]=count_by_quarter(mapStructFileName,outputFilePath)
% function [mapByQuarterStruct]=count_by_quarter(mapStructFileName,outputFilePath)
% This takes a matlab structure file containing a map of the quarter and
% the black algorithm applied, per module output, and converts it into a 
% struct of structs, by quarter. The per-quarter struct is returned.
%
% Input arguments:
%   mapStructFileName (string):   Full path to the structure containing the
%                                 map of the quarter to black algorithm.
%                                 This struct, named mapOut, was produced
%                                 by Bruce for KSOP-2440. The struct 
%                                 contains:
%                                   taskFileFullPath (string)
%                                   module (integer)
%                                   output (integer)
%                                   channel (integer)
%                                   skyGroupId (integer)
%                                   season (integer)
%                                   quarter (integer)
%                                   k2Campaign (integer, is -1 for Kepler)
%                                   isK2Uow (logical)
%                                   cadenceTimes (struct)
%                                   startCadence (integer)
%                                   endCadence (integer)
%                                   blackAlgorithmApplied (string)
%   outputFilePath (string):      Full path to a location to write output
%                                 in a text file, and to save the output
%                                 struct file as a *.mat
%
% Output arguments:
%   mapByQuarterStruct (struct array):
%                                 The struct array of the per-quarter
%                                 structs. This is a sub-set of the data
%                                 from the mapOut, input, struct, with
%                                 additional information. The sub-struct
%                                 contains:
%                                 mapByQuarterStruct.quarterString:
%                                   quarter (integer)
%                                   modules (1xN duoble)
%                                   outputs  (1xN duoble)
%                                   blackAlgorithmAppliedArray (Nx10 char)
%                                   blackAlgorithmAppliedKeyArray  (1xN duoble)
%                                       key of the black algorithm: 
%                                           1 = exponential1DBlack
%                                           2 = dynablack
%                                   exp1DBlackIndices (1xI array of indices of
%                                       the mod/out pair where 1-D black
%                                       was applied)
%                                   dynablackIndices (1xJ array of indices of
%                                       the mod/out pair where dynablack
%                                       was applied)
%                                   count1DBlack (intger, number of mod/out
%                                       that used 1-D black)
%                                   countDynaBlack (intger, number of mod/out
%                                       that used dynablack)
%                                   
%
% Author: Jennifer Campbell, October, 2015
% KSOP-2440, KSOC-4924
%% --------------------------------------------------------------------- %%
% Load the input struct file and convert a sub-set of the struct into a 
% bunch of arrays.
% Write a subset of the data to an output text file (may be easier to use 
% then the *.mat file)
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

load(mapStructFileName)

fid1=fopen([outputFilePath,'map_quarterModuleOutput_to_blackAlgorithm.txt'],'w');
fprintf(fid1,'quarter,module,output,blackAlgorithmApplied\n');

for i=1:length(mapOut)
    quartersArray(i)=mapOut(i).quarter;
    modulesArray(i)=mapOut(i).module;
    outputsArray(i)=mapOut(i).output;
    
    % create an integer key for identifying the algorithm
    blackTypeFirstLetter=mapOut(i).blackAlgorithmApplied(1);
    if blackTypeFirstLetter == 'e'
        % change exponentialOneDBlack to exp1DBlack to be 10 characters long
        blackAlgorithmAppliedArray(i,:)='exp1DBlack';
        blackAlgorithmAppliedKeyArray(i)=1;
    elseif blackTypeFirstLetter == 'd'
        % add the space to make the string 10 characters long
        blackAlgorithmAppliedArray(i,:)='dynablack '; 
        blackAlgorithmAppliedKeyArray(i)=2;
    else
        fprintf('\twarning: not 1-D or Dyn\n')
        fprintf('\t\tQ%i, m%i, o%i: %s\n',mapOut(i).quarter,mapOut(i).module,mapOut(i).output,mapOut(i).blackAlgorithmApplied)
    end
    
    % write some data to a text file:
    fprintf(fid1,'%i,%i,%i,%s\n',mapOut(i).quarter, mapOut(i).module, ...
        mapOut(i).output, mapOut(i).blackAlgorithmApplied);
        
end

fclose(fid1);

%% --------------------------------------------------------------------- %%
% Make a count of the Black Algorithm Used (1-D black or Dynablack) for 
% each quarter. Save the information into a text file.

fid2=fopen([outputFilePath,'quarterModOut_1DBlack_list.txt'],'w');
fprintf(fid2,'quarter,mod,out\n');

for quarterNumber=0:17
    % Re-organize into a struct of struct, organized by quarter
    qIndex=find(quartersArray == quarterNumber);
    quarterString=['q', num2str(quarterNumber)];
    mapByQuarterStruct.(quarterString).quarter=quarterNumber;
    mapByQuarterStruct.(quarterString).modules=modulesArray(qIndex);
    mapByQuarterStruct.(quarterString).outputs=outputsArray(qIndex);
    mapByQuarterStruct.(quarterString).blackAlgorithmAppliedArray=blackAlgorithmAppliedArray(qIndex,:);
    mapByQuarterStruct.(quarterString).blackAlgorithmAppliedKeyArray=blackAlgorithmAppliedKeyArray(qIndex);
    
    % Count the mod/out with each black type
    exp1DBlackIndices=find(blackAlgorithmAppliedKeyArray(qIndex) == 1);
    dynablackIndices=find(blackAlgorithmAppliedKeyArray(qIndex) == 2);
    count1DBlack=length(exp1DBlackIndices);
    countDynaBlack=length(dynablackIndices);
    % add to the structure
    mapByQuarterStruct.(quarterString).exp1DBlackIndices=exp1DBlackIndices;
    mapByQuarterStruct.(quarterString).dynablackIndices=dynablackIndices;
    mapByQuarterStruct.(quarterString).count1DBlack=count1DBlack;
    mapByQuarterStruct.(quarterString).countDynaBlack=countDynaBlack;
    
    % Print the mod/out which reverted to 1-D black
    % Skip Q0, Q1, Q17 which were all 1-D black
    if quarterNumber >=2 && quarterNumber <=16
        fprintf('\n----------------\n')
        fprintf('Quarter: %i \t 1-D Black: %i \t Dynablack: %i\n', quarterNumber, ...
            mapByQuarterStruct.(quarterString).count1DBlack, ... 
            mapByQuarterStruct.(quarterString).countDynaBlack)
        fprintf('1-D Black mod/out pairs:\n')
        for i=1:count1DBlack
            fprintf('mod %i out %i\n', ...
                mapByQuarterStruct.(quarterString).modules(exp1DBlackIndices(i)),...
                mapByQuarterStruct.(quarterString).outputs(exp1DBlackIndices(i)) )
            % print to a file
            fprintf(fid2,'%i,%i,%i\n',quarterNumber, ...
                mapByQuarterStruct.(quarterString).modules(exp1DBlackIndices(i)),...
                mapByQuarterStruct.(quarterString).outputs(exp1DBlackIndices(i)) );
        end
        
    end
end    

%% --------------------------------------------------------------------- %%
% close the text file, save the output struct, and return

fclose(fid2);

outputMatFile=[outputFilePath,'mapByQuarterStruct.mat'];
save(outputMatFile, 'mapByQuarterStruct');

return

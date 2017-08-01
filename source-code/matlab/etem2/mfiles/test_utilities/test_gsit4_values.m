% script to reconstruct long-cadence pixel values for gsit-4 from FFIs
% must be run from the ETEM2 directory
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

numCcdRows = 1070;
numCcdCols = 1132;
numCoAdds = 270;

modules = [2:4, 6:20, 22:24];

% ffiLocation = '/disk2/gsit4/gsit4_ffis/';
ffiLocation = '/disk2/gsit4/gsit4_ffis3/';
% load the quantization table
load 'configuration_files/requantizationTable.mat';

for m=1:length(modules)
    module = modules(m);
    for output = 1:4
        
        modOutNum = (m-1)*4 + output;

%         targetStruct = retrieve_tad(module, output, 'gsit-4-a-lc1');
        targetStruct = retrieve_tad(module, output, 'gsit-4-b-lc1');
        display(['checking module = ' num2str(module), ' output = ' num2str(output)]);
        mDefs = targetStruct.maskDefinitions;
        tDefs = targetStruct.targetDefinitions;
        
        % build all row and column indices for targets on this mod/out
        % it is critical to retain the order in the target defs
        rows = [];
        cols = [];
        for t=1:length(tDefs)
            maskIndex = tDefs(t).maskIndex + 1;
            refRow = tDefs(t).referenceRow + 1;
            refCol = tDefs(t).referenceColumn + 1;
            rows = [rows, refRow + [mDefs(maskIndex).offsets.row]];
            cols = [cols, refCol + [mDefs(maskIndex).offsets.column]];
        end
        % make linear index into the ffi array
        targetPixIndex = sub2ind([numCcdRows, numCcdCols], rows, cols);
        
        % load the FFI
%         disp(['loading ' [ffiLocation filesep 'output_' num2str(modOutNum) '.bin']]);
        fid = fopen([ffiLocation filesep 'output_' num2str(modOutNum) '.bin'], 'r', 'ieee-be');
        ffiImage = numCoAdds*fread(fid, [numCcdCols numCcdRows], 'uint16')';
        
        % make image of target pixels only
        targetImage = zeros(size(ffiImage));
        targetImage(targetPixIndex) = ffiImage(targetPixIndex);
        
        targetPixValues = targetImage(targetPixIndex);
        quantizedTargetPixValues = uint16(interp1(requantizationTable, ...
            1:length(requantizationTable), targetPixValues, 'nearest'))-1;
        reQuantTargetPixelValues = requantizationTable(quantizedTargetPixValues+1);
        
%         fitsTables = fitsread(...
%             '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012123180618_lcs-targ.fits', ...
%             'binTable', modOutNum);
        fitsTables = fitsread(...
            '/path/to/recdels/gsit-4/rec/dmc/v1/kplr2012181152531_lcs-targ.fits', ...
            'binTable', modOutNum);
        dmcData = fitsTables(1);
        dmcData = dmcData{1,1};
        if all(dmcData == reQuantTargetPixelValues)
            disp('check OK');
        else
            disp(['target mismatch in module = ' num2str(module), ' output = ' num2str(output)]);
        end
%         figure(1000);
%         imagesc(ffiImage, numCoAdds*[820, 1.6e3]);
%         colormap(hot);
%         figure(1001);
%         imagesc(targetImage, numCoAdds*[820, 1.6e3]);
%         colormap(hot);
    end
end
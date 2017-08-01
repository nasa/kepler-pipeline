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
clear;
ffiDataLoc = '/disk2/gsit4/gsit4_ffis3/';
imageDataLoc = [ffiDataLoc 'ql/'];
modules = [2:4 6:20 22:24];
nModules = length(modules);
nRows = 1070;
nCols = 1132;
rowStart = [nRows+1 nRows+1 1 1];
colStart = [1 nCols+1 nCols+1 1];
rowOrient = [1 1 0 0];
colOrient = [0 1 1 0];
rotationCount = [ 0 0 0 ...
                1 0 0 3 3 ...
                1 1 1 3 3 ...
                1 1 2 2 3 ...
                  2 2 2 ];
thismod = 1;
for m=1:nModules
    moduleImage.image = zeros(2*nRows, 2*nCols);
    for o=1:4
        modOut = (m-1)*4 + o;
        fid = fopen([ffiDataLoc 'output_' num2str(modOut) '.bin'], 'r', 'ieee-be');
        image = fread(fid, [nCols, nRows], 'uint16');
        origImage = image;
        if rowOrient(o)
            image = fliplr(image);
        end
        if colOrient(o)
            image = flipud(image);
        end
        moduleImage.image(rowStart(o):rowStart(o)+nRows-1, colStart(o):colStart(o)+nCols-1) = ...
            image';
%         moduleImage.part(o).image = image';
%         moduleImage.part(o).origImage = origImage';
    end
    moduleImage.image = rot90(moduleImage.image, rotationCount(m));
    
    if modules(m) < 10
        mocImage = imread([imageDataLoc 'm_0' num2str(modules(m)) '.png']);
    else
        mocImage = imread([imageDataLoc 'm_' num2str(modules(m)) '.png']);
    end

    thismod = m;
    colorRange = 1.6e3;
    figure(1);
    imagesc(moduleImage.image, [820, colorRange]);
    title(['module ' num2str(modules(thismod))]);
    colormap(gray);

    figure(5);
    imagesc(mocImage);
    title(['module ' num2str(modules(thismod))]);
    colormap(gray);

%     figure(2);
%     place = [3 4 2 1];
%     for o=1:4
%         subplot(2,2,place(o));
%         imagesc(moduleImage.part(o).image, [820, colorRange]);
%         title(num2str(o));
%         colormap(gray);
%     end
%     figure(3);
%     for o=1:4
%         subplot(2,2,place(o));
%         imagesc(moduleImage.part(o).origImage, [820, colorRange]);
%         title(num2str(o));
%         colormap(gray);
%     end
    pause;
end

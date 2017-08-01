function xTalkOutputStruct  = read_crosstalk_fits_file(xTalkFitsFileName)
%______________________________________________________________________
% function xTalkOutputStruct  = read_crosstalk_fits_file(xTalkFitsFileName)
% Reads the  cross talk image delivered as a fits file and is checked
% into svn along with TCAT scripts
%______________________________________________________________________
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

%_________________________________________________________________________
% read crosstalk image fits file
%_________________________________________________________________________

clockStateMask = fitsread(xTalkFitsFileName);

figure;
imagesc(clockStateMask); 

set(gca, 'ydir', 'normal');

set(gca, 'fontsize',12);
colorbar;


%_________________________________________________________________________
% save the figure to file
%_________________________________________________________________________

titleStr = ['Crosstalk Pixel Map from ' xTalkFitsFileName];
titleStr = strrep(titleStr, '_','-');
titleStr = strrep(titleStr, '.','-');

title(titleStr);
plot_to_file(titleStr);

close all;
%_________________________________________________________________________
% copy to output struct
%
% Parallel crosstalk pixels are 1 through 32 in number and have pixel values
% of 32 through 63 in the clock stae mask image hand-delivered by SO.
% Frame transfer crosstalk pixels are 1 through 16 in number and have pixel values
% of 16 through 31 in the clock stae mask image hand-delivered by SO.
%_________________________________________________________________________

xTalkOutputStruct.fgsXtalkIndexImage = clockStateMask;

xTalkOutputStruct.numberOfFgsParallelPixels = 32;

xTalkOutputStruct.fgsParallelPixelValues = (32:63)';

xTalkOutputStruct.numberOfFgsFramePixels = 16;

xTalkOutputStruct.fgsFramePixelValues = (16:31)';


return
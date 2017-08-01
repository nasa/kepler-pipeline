function  downSampledStruct = dg_downsample_image(ffiName,  varargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% function downSampledStruct = dg_downsample_image(ffiName, vargin)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% dg_downsample_image downsamples all 84 image channels of the star region 
% from an ffi by a factor of approx. 2*binFactor^2
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT: 
%               ffiName: [string] name of fits file
%              varargin: [int] optional, user specified binFactor, if not
%                        specified, default binFactor of 10 is used
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUTS: 
%           downSampledStruct, a struct with 21 entries with the following fields-
%
%               module : [int] CCD module number
%                output: [int] CCD output number
%             binFactor: [int] the default or user specified binFactor
%  binnedStarImage: [array single]: downsampled star image, normalized by
%  number of coadds
%
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

% check number of input arguments, if no vargin specified binFactor = 10
% also assume user is smart enought to input an integer that is reasonable
if nargin == 2,
    binFactor = varargin{1};
else
    binFactor = 10;
end



ffiKeywordStruct = retrieve_fits_primary_keywords(ffiName,'NUM_FFI');
numCoadds = ffiKeywordStruct.NUM_FFI;
info = fitsinfo(ffiName); % this is needed to validate that module and ouput are the 'real ones'
NumChannels = size(info.Image);



% error out if fits file does not have 84 images
if NumChannels ~= 84
    error('missing at least one module output in fits file')
end

% create big structure with 84 entries
downSampledStruct = repmat(struct('module', 0,  'output', 0, 'binFactor', 0, ...
    'binnedStarImage', []),1, 84);

% prepare file for fitsreading
table = prepare_for_fitsread(ffiName);


% get the star row and col locations
[starRowStar, starRowEnd, starColStart, starColEnd] = define_pixel_regions();

disp(sprintf('downsampling all 84 module outputs \t this will take a few minutes\n'))
% read all of 84 modouts

channel = 1; % channel is used as a counter here


for module =[ 2:4, 6:20, 22:24]
    
    for output = 1:4
        
        

        image =single(fitsread_check_modout(ffiName, module, output, table));

        % normalize images by number of coadds
        ffiImage = image/numCoadds;

        % trim image and discard collaterla regions
        ffiStarImage = ffiImage(starRowStar:starRowEnd, starColStart:starColEnd);

        % downsample ffiStarImage
        binnedImage = binavgmat(ffiStarImage, binFactor, binFactor);

        % place into struct
        downSampledStruct(channel).binnedStarImage= binnedImage;
        downSampledStruct(channel).module = module;
        downSampledStruct(channel).output = output;
        downSampledStruct(channel).binFactor = binFactor;
        channel = channel + 1;

disp(sprintf('downsampled module %d output %d', module, output))
    end

end




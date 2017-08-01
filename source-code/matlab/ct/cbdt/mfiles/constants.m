%% Constants
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

global FcConstants;

if ( isunix )
    % import the Kepler globally defined constants
     %import gov.nasa.kepler.common.FcConstants;
     a                   = FcConstants;
     load FcConstants
    %warning('Uncomment the code for Unix');
elseif ( ispc )
    % load pre-saved constant struct
    constFile = 'C:\path\to\matlab\ct\cbdt\mfiles\FcConstants.mat';
    load(constFile);
else
    error('Error: Unknown platform');
end

% FFI constants
MOD_OUT_NO          = FcConstants.MODULE_OUTPUTS;  % The number of module outputs
IDX_MOD_OUTS        = [2:4, 6:20, 22:24];   % the valid modout index

MOD_NO              = FcConstants.nModules;    % the number of modules
OUTPUT_NO           = FcConstants.nOutputsPerModule;  % the number of outputs

% Dimension of FFI images
FFI_ROWS            = FcConstants.CCD_ROWS;   % the default number of image rows
FFI_COLS            = FcConstants.CCD_COLUMNS;   % the default number of image cols

% FcConstants row and column locations use 0 based, so they need increment
% 1 to 1 based used in Matlab array indexing

% Collateral constants: valid collateral columns and rows per BALL KEPLER.DFM.FPA.015
LEADING_BLACK_COLS  = (FcConstants.LEADING_BLACK_START:FcConstants.LEADING_BLACK_END) + 1;
TRAILING_BLACK_COLS = (FcConstants.TRAILING_BLACK_START:FcConstants.TRAILING_BLACK_END) + 1;
MASKED_SMEAR_ROWS	= (FcConstants.MASKED_SMEAR_START:FcConstants.MASKED_SMEAR_END) + 1;
VIRTUAL_SMEAR_ROWS	= (FcConstants.VIRTUAL_SMEAR_START:FcConstants.VIRTUAL_SMEAR_END) + 1;

% science CCD region
SCIENCE_COLS         = [LEADING_BLACK_COLS(end)+1 : TRAILING_BLACK_COLS(1)-1];
SCIENCE_ROWS         = [MASKED_SMEAR_ROWS(end)+1 : VIRTUAL_SMEAR_ROWS(1)-1];

% region excluding the virtual smear
DISPLAY_REGION     = int32(1:FFI_ROWS); % int32(1:FcConstants.VIRTUAL_SMEAR_START);
EXCLUDE_REGION     = [FcConstants.VIRTUAL_SMEAR_START+1, FFI_ROWS];

SCIENCE_REGION_ROWS= int32(FcConstants.MASKED_SMEAR_END:FcConstants.VIRTUAL_SMEAR_START) + 1;
SCIENCE_REGION_COLS= int32(FcConstants.LEADING_BLACK_END:FcConstants.TRAILING_BLACK_START) + 1;

% order of the polynomials
POLY_FIT_ORDER     = 0;

% injection region that has values outside normal range
SMEAR_INJECTION_ROW_START = 1060;
SMEAR_INJECTION_ROW_END   = 1063;
SMEAR_INJECTION_COL_START = 13;
SMEAR_INJECTION_COL_END   = FFI_COLS;

SMEAR_INJECTION_ROWS=(SMEAR_INJECTION_ROW_START:SMEAR_INJECTION_ROW_END);
SMEAR_INJECTION_COLS=(SMEAR_INJECTION_COL_START:SMEAR_INJECTION_COL_END);

% Pixel types in cbdBadPixelsClass: non standard, CBD own definitions
HOT_PIXEL           = 255;
DEAD_PIXEL          = 200;
GAP_PIXEL           = 128;
XTALK_PIXEL         = 64;
BLACK_PIXEL         = 0;  


% what are the reasonable high and low guards for black FFIs?
HIGH_GUARD          = 2^14 - 1;
LOW_GUARD           = 10;
GAP_TAG             = (2^32 - 1);


function pixelSeries = extract_SC_pixel_time_series_from_etem2(etem2RunDirName, ...
    etem2RunDir, pixelDataMatFilename, getRequantizedPixFlag, includeCosmicRaysFlag, requantTableID)
%function extract_SC_pixel_time_series_from_etem2(etem2RunDirName, etem2RunDir, ...
%   pixelDataMatFilename, getRequantizedPixFlag, includeCosmicRaysFlag)
%
% function to extract short cadence pixel time series from an ETEM2 run.  
%
% Options are to extract requantized pixels (getRequantizedPixFlag = true)
% and to include the injected cosmic rays (includeCosmicRaysFlag = true). 
% By default (if only three arguments are given), the pixels extracted are 
% requantized and do not include cosmic rays.
%
% Example inputs:
%  etem2RunDirName  = 'calSC_ETEM_2D_st_sm_dc_nl_lu_ff_rn_qn_sn_dir'
%  etem2RunDir      = 'run_short_m7o4s1'
%  pixelDataMatFilename     = 'calSC_pixelSeries_2D_st_sm_dc_nl_lu_ff_rn_qn_sn'
%
%
% etem2RunDirName are directories that have been created from individual 
% etem2 runs, all located in:   /path/to/matlab/etem2/mfiles/
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


if (nargin == 3)

    % by default extract requantized pixels without cosmic rays
    getRequantizedPixFlag = false;
    includeCosmicRaysFlag = false;
elseif (nargin == 4)

    % by default extract pixels without cosmic rays
    includeCosmicRaysFlag = false;
end


tic;
outputLocation = [etem2RunDirName, '/', etem2RunDir];

%eval(['cd ' outputLocation ]);

%--------------------------------------------------------------------------
% extract pixel time series for all pixel types (not corrected for
% fixed offset or mean black)
%
% pixelSeries = get_cal_SC_pixel_time_series(location, quantize, cosmicRays)
%
% pixelSeries = 
% 1x2 struct array with fields:
%     pixelValues
%     pixelRows
%     pixelCols
%     blackValues
%     maskedSmearValues
%     virtualSmearValues
%     blackMaskedValue
%     blackVirtualValue
%--------------------------------------------------------------------------
pixelSeries = get_cal_SC_pixel_time_series(outputLocation, getRequantizedPixFlag, includeCosmicRaysFlag, requantTableID); %#ok<NASGU>


%--------------------------------------------------------------------------
% save all (target, background, and collateral) pixel time series, target
% definitions, and mask definitions.
%--------------------------------------------------------------------------
eval(['cd ' outputLocation ]);

duration = toc;

if (getRequantizedPixFlag && ~includeCosmicRaysFlag)

    %cd ..
    eval(['save ' pixelDataMatFilename '_RQ_cr.mat ' ...
        ' pixelSeries'])

    display(['Requantized SC pixel data extracted (without cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);

elseif (getRequantizedPixFlag && includeCosmicRaysFlag)

    %cd ..
    eval(['save ' pixelDataMatFilename '_RQ_CR.mat ' ...
        ' pixelSeries'])


    display(['Requantized SC pixel data extracted (with cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);

elseif (~getRequantizedPixFlag && ~includeCosmicRaysFlag)

    %cd ..
    eval(['save ' pixelDataMatFilename '_rq_cr.mat ' ...
        ' pixelSeries'])

    
    display(['Unrequantized SC pixel data extracted (without cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);

elseif  (~getRequantizedPixFlag && includeCosmicRaysFlag)

    %cd ..
    eval(['save ' pixelDataMatFilename '_rq_CR.mat ' ...
           ' pixelSeries'])

    display(['Unrequantized SC pixel data extracted (with cosmic rays) for ETEM2 run ' etem2RunDirName ' : ' num2str(duration/60) ' minutes']);
end

cd ..
return;

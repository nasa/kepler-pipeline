%% function fluxOut = spsd_fill_gaps(fluxIn,uncertainties,gapIndicators,gapFillConfigurationStruct)
%
%   NOTE: this function is only a convenient wrapper for Hema's gap filler. It is called in:
%         - spsdCorrectedFluxClass.correct_from_preloaded (spsd post correction for short cadence targets)
%
%   INPUTS:
%
%   fluxIn:                       input flux. should be an Nx1 vector of double
%   uncertainties:                flux uncertainties. should be an Nx1 vector of double
%   gapIndicators:                gap indicators. should be an Nx1 vector of logical
%   gapFillConfigurationStruct:   OPTIONAL. one of the main points of this helper function is to have a simple
%                                 and light-weight wrapper for the gapfiller. so this can gladly be omitted if
%                                 default parameters are okay
%
%   OUTPUTS:
%
%   fluxOut:                      output flux, with gaps filled. Nx1 vector of double
%%
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

function fluxOut = spsd_fill_gaps(fluxIn,uncertainties,gapIndicators,varargin)

    if (isempty(varargin))
        gapFillConfigurationStruct = create_default_gapFillConfigurationStruct;
    else
        gapFillConfigurationStruct = varargin{1};
    end
    
   fluxOut = pdc_fill_data_gaps(fluxIn,gapIndicators,[],uncertainties,gapFillConfigurationStruct,false,0);

end


function gapFillConfigurationStruct = create_default_gapFillConfigurationStruct
% function gapFillConfigurationStruct = create_default_gapFillConfigurationStruct
%    default values taken from PDC inputs as of 8.3
% TODO: get this out of here! These should be imported as parameters
        gapFillConfigurationStruct = struct( ...
                         'madXFactor' , 10 , ...
                         'maxGiantTransitDurationInHours' , 72 , ...
                         'maxDetrendPolyOrder' , 25 , ...
                         'maxArOrderLimit' , 25 , ...
                         'maxCorrelationWindowXFactor' , 5 , ...
                         'gapFillModeIsAddBackPredictionError' , 1 , ...
                         'waveletFamily' , 'daub' , ...
                         'waveletFilterLength' , 12 , ...
                         'giantTransitPolyFitChunkLengthInHours' , 72 , ...
                         'removeEclipsingBinariesOnList' , 1 , ...
                         'arAutoCorrelationThreshold' , 0.0500 , ...
                         'cadenceDurationInMinutes'  , 30 );
        
end

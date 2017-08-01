function detectionResultsStruct = detect( obj )
%%  detect 
% Identifys SPSDs in timeseries
% spsd = Sudden Pixel Sensitivity Dropouts
% 
%   Revision History:
%
%       Version 0 -   3/14/11     released for Science Office use
%       Version 0.1 - 4/30/11     improved/corrected documentation
%                                 replaced some enumerated values with
%                                 variable names
%       Version 0.11 - 3/05/12    outsourced original .detect() into .detect_from_scratch()
%                                 to support .detect_from_preloaded() for SC processing
% 
% <html>
% <style type="text/css"> pre.codeinput {background: #FFFF66; padding: 30px;} </style>
% </html>
% 
%
%function detectionResultsStruct = detect(detectorStruct, timeseriesStruct);
%% 1.0 ARGUMENTS
% 
% Function returns:
%
% * |detectionResultsStruct     -| structure containing output parameters. 
% * |.clean                     -| Information about CLEAN targets:
% * |-.count                    -| how many
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |.spsds                     -| Information about spsd-containing targets:
% * |-.count                    -| how many?
% * |-.index                    -| which ones, relative to input timeseries order
% * |-.keplerId                 -| which ones, Kepler IDs
% * |-.keplerMag                -| kepler magnitude
% * |-.spsdCadence          	-| LC number relative to start of timeseries (See |detect.m| )
% * |-.longCoefs                -| local fit coefficients for long window (See |detect.m| )
% * |-.longStepHeight          	-| estimated step height for long window (See |detect.m| )
% * |-.longMADs              	-| MAD of residuals & MAD of residual differences for long window (See |detect.m| )
% * |-.shortCoefs        	    -| local fit coefficients for short window (See |detect.m| )
% * |-.shortStepHeight       	-| estimated step height for short window (See |detect.m| )
% * |-.shortMADs           	    -| MAD of residuals & MAD of residual differences for short window (See |detect.m| )
%
% Function Arguments:
%
% * |detectorStruct      -| structure detector information. 
% * See | init_filter.m | for structure details
%
% * |timeseriesStruct   -| structure containing timeseries information. 
% * See | Get_input_timeseries.m | for structure details
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

    if (obj.detectionParamsStruct.quickSpsdEnabled==false)
        detectionResultsStruct = obj.detect_from_scratch();
    else        
        detectionResultsStruct = obj.detect_from_preloaded();
    end

end




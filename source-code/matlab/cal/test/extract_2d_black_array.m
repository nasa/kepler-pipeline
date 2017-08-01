function [twoDBlackArray twoDBlackUncert] = extract_2d_black_array(ccdModule, ccdOutput, ...
    startMjdForModel, endMjdForModel, rows, cols, mjdsFor2Darray)
%function [twoDBlackArray twoDBlackUncert] = extract_2d_black_array(ccdModule, ccdOutput, ...
%    startMjdForModel, endMjdForModel, rows, cols, mjdsFor2Darray)
%
% function to retrieve 2Dblack model from database, instantiate the object,
% and extract the full (1070 x 1132) or partial 2D black array for a given
% module/output.  Optional arguments are the start/end mjd for the 2D black
% model, and the mjd(s) of the desired 2D black arrays.
%
% INPUTS:
%
%   ccdModule, ccdOutput
%
% OPTIONAL INPUTS:
%
%   startMjdForModel, endMjdForModel      start/end timestamps (mjd) for 2D black model
%
%   rows, cols                            row/cols of desired 2D array in
%                                         Matlab 1-based indexing
%
%   mjdsFor2Darray                        timestamp(s) for desired 2D array(s)
%
% OUTPUTS:
%
%   2D black array (or subset if row/cols are input) in DN.
%   2D black uncertainties
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


if nargin == 7

    % retrieve model from database
    twoDBlackData = retrieve_two_d_black_model(ccdModule, ccdOutput, startMjdForModel, endMjdForModel, rows, cols);

    % instantiate object
    twoDBlackObject = twoDBlackClass(twoDBlackData);

    % extract 2D black array
    [twoDBlackArray twoDBlackUncert] = get_two_d_black(twoDBlackObject, mjdsFor2Darray, rows, cols);
    return;

elseif nargin == 6

    % retrieve model from database
    twoDBlackData = retrieve_two_d_black_model(ccdModule, ccdOutput, startMjdForModel, endMjdForModel, rows, cols);

    mjdsFor2Darray = 100000; % per get_two_d_black, gets the black that is valid for the latest MJD.

    % instantiate object
    twoDBlackObject = twoDBlackClass(twoDBlackData);

    % extract 2D black array
    [twoDBlackArray twoDBlackUncert] = get_two_d_black(twoDBlackObject, mjdsFor2Darray, rows, cols);
    return;


elseif nargin == 4

    % retrieve model from database
    twoDBlackData = retrieve_two_d_black_model(ccdModule, ccdOutput, startMjdForModel, endMjdForModel);

    % instantiate object
    twoDBlackObject = twoDBlackClass(twoDBlackData);

    % extract 2D black array
    [twoDBlackArray twoDBlackUncert] = get_two_d_black(twoDBlackObject);
    return;

elseif nargin == 2

    % retrieve model from database
    twoDBlackData = retrieve_two_d_black_model(ccdModule, ccdOutput);

    % instantiate object
    twoDBlackObject = twoDBlackClass(twoDBlackData);

    % extract 2D black array
    [twoDBlackArray twoDBlackUncert] = get_two_d_black(twoDBlackObject);
    return;

end


return;

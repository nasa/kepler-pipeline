function FGS_Clock_States = get_fgs_clock_states( )
%
% Creates two FFI-sized arrays containing clock state sequence IDs, 
% or simply clock states for FGS-parallel and FGS-frame clocking cross-talk
% characterization in science channels.
% 
% * Function returns:
% * --> |FGS_Clock_States  -| Structure containing FGS parallel and frame clock state sequence IDs.
% * ----> |.Parallel -| Parallel clock state IDs numbered 1 through 566. 
%                       Number one represents first parallel clock cycle in each FGS row. 
%                       Zeros for FGS frame states.
% * ----> |.Frame    -| Frame clock state IDs numbered 1 through 20. 
%                       Numbers 1 through 16 cycle through the first 8130 FGS clock cycles.
%                       Number 17 represents FGS clock cycles 8131 through 8239.
%                       Numbers 18 through 20 represent FGS clock cycles 8240 through 8242.
%                       Zeros for FGS parallel states.
%
% * Function arguments:
% * --> |None | .
%
%% CONSTANTS
% 
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

Constants=struct( ... % Implicit references are science channel references (e.g. row implies science channel row)
        'clocks_per_row',               1455, ...
        'pixels_per_row',               1132, ...
        'rows_per_FGS_frame',           214, ...
        'FGS_frames_per_frame',         5, ...
        'FGS_clocks_per_FGS_row',       566, ...
        'FGS_frame_initial_offset',     250, ...
        'FGS_frame_cyclic_indexCount',  16, ...
        'FGS_frame_cyclic_range',       1:8130, ...
        'FGS_frame_flatline_range',     8131:8239, ...
        'FGS_frame_endtrans_range',     8240:8242 ...
        );
    
Derived=struct( ...
        'FGS_frame_flatline_index',         Constants.FGS_frame_cyclic_indexCount + 1, ...
        'FGS_frame_endtrans_indexRange',    Constants.FGS_frame_cyclic_indexCount + 2 : ...
                                            Constants.FGS_frame_cyclic_indexCount + 1 + ...
                                            length(Constants.FGS_frame_endtrans_range), ...
        'FGS_frame_clock_count',            Constants.FGS_frame_endtrans_range(end), ...
        'clocks_per_FGS_frame',             Constants.clocks_per_row*Constants.rows_per_FGS_frame ...
        );
    
%% INITIALIZATION
% 

FGS_Clock_States = struct(    ...
                        'Parallel',  0, ...
                        'Frame',     0 ...
                        );
                    
%% FGS PARALLEL CLOCK STATES
% 
                   
sequence                  = ( 1:Derived.clocks_per_FGS_frame) + ...
                              Constants.FGS_frame_initial_offset - 1;
clockstate                = mod( sequence, ...
                                 Constants.FGS_clocks_per_FGS_row ) + 1;
clockstate(1:Derived.FGS_frame_clock_count) =   0;
clockstate2               = reshape( clockstate, ...
                                     Constants.clocks_per_row, ...
                                     Constants.rows_per_FGS_frame )';
FGS_Clock_States.Parallel = repmat( clockstate2( :, 1:Constants.pixels_per_row ), ...
                                    Constants.FGS_frames_per_frame, 1 );

%% FGS FRAME CLOCK STATES
% 

sequence                  = Constants.FGS_frame_cyclic_range - 1;
clockstate                = zeros( Derived.clocks_per_FGS_frame, 1 );
clockstate(Constants.FGS_frame_cyclic_range)    = mod( sequence, ...
                                                       Constants.FGS_frame_cyclic_indexCount ) + 1;
clockstate(Constants.FGS_frame_flatline_range)  = Derived.FGS_frame_flatline_index;
clockstate(Constants.FGS_frame_endtrans_range)  = Derived.FGS_frame_endtrans_indexRange;
clockstate2               = reshape( clockstate, ...
                                     Constants.clocks_per_row, ...
                                     Constants.rows_per_FGS_frame )';
FGS_Clock_States.Frame    = repmat( clockstate2( :, 1:Constants.pixels_per_row ), ...
                                    Constants.FGS_frames_per_frame, 1 );

%% RETURN
% 
end


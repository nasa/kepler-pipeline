function display_validation_figures()
% 
% (1) SC_cad_med_black_per_cad_per_channel.fig
%     SC_cad_std_black_per_cad_per_channel.fig
%
% (2) SC_cad_med_black_per_row_per_channel.fig
%     SC_cad_std_black_per_row_per_channel.fig
%
%
% (3) SC_cad_med_msmear_per_cad_per_channel.fig
%     SC_cad_std_msmear_per_cad_per_channel.fig
%
% (4) SC_cad_med_vsmear_per_cad_per_channel.fig
%     SC_cad_std_vsmear_per_cad_per_channel.fig
%
% (5) SC_cad_med_smeardiff_per_cad_per_channel.fig
%     SC_cad_std_smeardiff_per_cad_per_channel.fig
%
%
% (6) SC_cad_med_msmear_per_col_per_channel.fig
%     SC_cad_std_msmear_per_col_per_channel.fig
%
% (7) SC_cad_med_vsmear_per_col_per_channel.fig
%     SC_cad_std_vsmear_per_col_per_channel.fig
%
% (8) SC_cad_med_smeardiff_per_col_per_channel.fig
%     SC_cad_std_smeardiff_per_col_per_channel.fig
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



lcFlightDataDir     = '/path/to/flight/q2/i897/';  % <-- 12 mod/outs, 12 dirs
lcEtemDataDir       = '/path/to/etem/q2/i85/';       % <-- 12 mod/outs, 12 dir
% scFligthDataDir   = '/path/to/flight/q2/i956/';
scFlightDataDir     = '~/cal_validation/flight_data_sc_all_12_mod_outs/';      % <-- moved only 1st invocations here
scEtemDataDataDir   = '/path/to/etem/q2/i142/';  % <-- 12 mod/outs, 180 dirs


lcFlightFigureDir   = '/path/to/cal_validation/long_cad_flight_figs_09_Feb_2010_17_28_31/';
lcEtemDataDir       = '/path/to/cal_validation/long_cad_etem_figs_09_Feb_2010_17_36_18/';
scFlightFigureDir   = '/path/to/cal_validation/short_cad_flight_figs_09_Feb_2010_17_18_09/';
scEtemFigureDir     = '/path/to/cal_validation/short_cad_etem_figs_09_Feb_2010_17_03_07/';


%--------------------------------------------------------------------------
% (1) Black per Cadence
%--------------------------------------------------------------------------
open([scEtemFigureDir, 'SC_cad_med_black_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_black_per_cad_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_black_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_black_per_cad_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (2) Black per Row
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_black_per_row_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_black_per_row_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_black_per_row_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_black_per_row_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (3) Msmear per Cadence
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_msmear_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_msmear_per_cad_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_msmear_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_msmear_per_cad_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (4) Vsmear per Cadence
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_vsmear_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_vsmear_per_cad_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_vsmear_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_vsmear_per_cad_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (5) Smear Diff per Cadence
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_smeardiff_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_smeardiff_per_cad_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_smeardiff_per_cad_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_smeardiff_per_cad_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (6) Msmear per Col
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_msmear_per_col_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_msmear_per_col_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_msmear_per_col_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_msmear_per_col_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (7) Vsmear per Col
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_vsmear_per_col_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_vsmear_per_col_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_vsmear_per_col_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_vsmear_per_col_per_channel.fig'])

pause
%--------------------------------------------------------------------------
% (8) Smear Diff per Col
%--------------------------------------------------------------------------
close all
open([scEtemFigureDir, 'SC_cad_med_smeardiff_per_col_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_med_smeardiff_per_col_per_channel.fig'])

open([scEtemFigureDir, 'SC_cad_std_smeardiff_per_col_per_channel.fig'])
open([scFlightFigureDir, 'SC_cad_std_smeardiff_per_col_per_channel.fig'])


return; 


% 
% Scripts for use during TPS V & V or DAWG Analyses
%
% aggregate_tps_dawg_structs_across_tasks:  assembles the full-run DAWG struct by walking
%     through the tps-matlab-#-# directories and picking up the skygroup-level aggregated
%     DAWG structs, incorporating them into a single struct.  At the same time it
%     constructs a struct full of information on TPS tasks which failed.  The DAWG struct
%     is saved into tps-dawg-struct.mat, the failure struct into tps-dawg-errors.mat .
%     Note that this function assumes that the target-level error and DAWG structs have
%     been aggregated to the skygroup level by a function which runs in the pipeline.
%     Syntax:
%
%     aggregate_tps_dawg_structs_across_tasks( topDir )
%
%
%
% get_tces_from_tps_dawg_struct:  assembles a struct which has the same fields as the
%     tpsDawgStruct, except that the CDPP, MES, SES, period, and epoch are now all
%     nTargets x 1.  The preserved values for each target are the ones which constitute
%     the best detection. If there is no detection, then the preserved values will be from
%     the pulse with the max MES.  The pulse # which produced the preserved detection is
%     also saved.  Syntax:
%
%    tceStruct = get_tces_from_tps_dawg_struct( tpsDawgStruct )
%
%
%
% get_tps_struct_by_kepid_from_task_dir_tree:  this uses the tpsDawgStruct or tceStruct
%     to retrieve a TPS struct from the task directories, using the Kepler ID.  It can
%     return the input struct, output struct, or diagnostic struct.  Syntax:
%
%     tpsStruct = get_tps_struct_by_kepid_from_task_dir_tree( tceStruct, keplerId,
%         fileType, useBinFile )
%
%
%
% tps_folding_times_and_errors:  this uses the tpsDawgStruct and targetFailureStruct to
%     distribute processing errors into 3 categories:  tasks which timed out, tasks which
%     error-exited, and tasks which failed and did not produce a log file.  It also
%     reports the median, 99 percentile, and maximum folding times for targets which
%     successfully completed processing.  Syntax:
%
%     [timeoutDirs, errorDirs, noLogDirs] = tps_folding_times_and_errors( tpsDawgStruct, 
%         targetFailureStruct )
%
%
% 
% browse_tps_log_file_tails:  takes one of the 3 outputs from
%     tps_folding_times_and_errors and loops through the last few lines of the log files
%     of each target which is included in that output (ie, errors or timeouts).  This
%     allows the user to see whether there is a pattern to the failures, for example
%     whether the failures all occurred for the same reason in the same place (which is
%     often the situation).  Syntax:
%
%     browse_tps_log_file_tails( errorDirs, nLines )
%
%
%
% parse_koi_xls_file:  read the KOI data file in Excel format, and return it as a data
%     struct with all the information about KOI timing, depth, and SNR.  This requires
%     that ths source Excel file be in about the simplest format available (ie, use "Save
%     As" in Excel and go down to, like, Excel 5.0 compatibile saves).  The user must
%     supply the min # transits required for a transit, the unit of work in KJD (start and
%     end), and the max KOI number, if any, which is to be used (so that the KOIs which
%     are processed can be a chronological subset of the full set).  Syntax:
%
%     koiDataStruct = parse_koi_xls_file( xlsFileName, minSesInMesCount, unitOfWorkKjd, 
%        maxKoiNumber )
%
%
%
% disposition_kois:  determine which KOI stars produced TCEs and which did not.  This
%     returns two structs:  the first struct contains the KOI and TCE information for all
%     KOIS which fall on stars with TCEs; the second struct contains KOI information for
%     all KOIs which were on stars with no TCE in this run.  A count of the # of KOI stars
%     which did not run in TPS is also returned.  Syntax:
%
%     [koisWithTcesStruct, koisMissingTcesStruct] = disposition_kois( koiDataStruct, 
%         tceStruct )
%
%
%
% match_tce_with_multiplanet_koi:  this function attempts to match KOIs and TCEs, in
%     particular in the case of stars which contain multiple KOIs.  This is done by
%     computing an ephemeris match for each KOI-TCE pair.  For multi-KOI stars, the KOI
%     which has the best ephemeris match is paired with the TCE.  Syntax:
%
%     koiAndTceStruct = match_tce_with_multiplanet_koi( koisWithTcesStruct, tceStruct )
%
%
%
% match_multiplanet_tce_with_multiplanet_koi:  this function is similar to the one listed
%     above, except that it operates in a context in which a star can have multiple TCEs
%     as well as multiple KOIs.  This is generally the case when there are DV-generated
%     TCEs in the data products.  This produces a struct with matched KOIS and TCEs, in
%     which each KOI is paired with the best-matching TCE.  For target stars where the #
%     of KOIs exceeds the # of TCEs, or vice-versa, there are structs of unmatched KOIs
%     and TCEs.  Syntax:
%
%     [koiAndTceStruct, koiOnlyStruct, tceOnlyStruct] = match_multiplanet_tce_with_
%         multiplanet_koi( koisWithTcesStruct, tceStruct )
%
%
%
% ephemeris_match:  this function computes a dimensionless matching parameter between two
%     ephemerides, given their epochs and periods, the transit duration, and the unit of
%     work in KJD (start and end).  The two ephemerides are identified as the
%     shorter-period ephemeris (with more transits) and the longer-period ephemeris (with
%     fewer transits); the match parameter is the fraction of short-period transits which
%     fall within half a transit duration of a long-period transit.  The resulting number
%     is always between 1.0 (indicating that every transit in one ephemeris coincides with
%     a transit in the other) and 0.0 (indicating that none of the transits in the two
%     ephemerides coincide).  Syntax:
%
%     rho = ephemeris_match( epoch1, period1, epoch2, period2, durationHours, unitOfWork )
%
%
%
% plot_folded_tps_flux:  filters and folds the quarter-stitched TPS flux of a selected
%     target, plotting the filtered flux and the folded, binned, summed TPS flux.  The
%     filtering can use either a median filter or a whitening filter.  This function uses
%     syntax which permits it to be used with plotter_loop to plot a list of targets one
%     after the other.  Syntax:
%
%     plot_folded_tps_flux( tceStruct, keplerIdList, pulseDurations, nPulseDurationsZoom,
%         nTransitsPlotMax, filterType, iTarget ) 
%
%     
%
% plot_tps_flux_from_kepler_id:  plots the TPS input flux and the TPS quarter-stitched
%     flux for a target selected by Kepler ID.  The syntax permits use of plotter_loop to
%     plot one target after another.  Syntax:
%
%     plot_tps_flux_from_kepler_id( tceStruct, keplerIdList, koiPeriods, tpsPeriods,
%         medianCorrectionFlag, iTarget )
%     
%
%
% plot_tps_flux_koi_and_tce_timing:  produce plots related to a target which has both a
%     KOI and a TCE on it.  This produces 5 subplots:  the median corrected TPS flux, the
%     TPS detrended (quarter-stitched) flux, the single event statistics time series, the
%     whitened flux folded at the KOI timing, and the whitened flux folded at the TCE
%     timing.  In the first 3 plots, the expected transit locations and depths from the
%     KOI data are superimposed.  Syntax:
%
%     plot_tps_flux_koi_and_tce_timing( koiWithTceStruct, tceStruct, iTarget )
%
%
%
% plot_tps_flux_for_missing_kois:  in the case of KOIs which did not produce TCEs, plot
%     the median-corrected TPS input flux, the quarter-stitched TPS flux, the single event
%     statistics time series, and the whitened flux folded at the KOI period.  On the first 3
%     plots, superimpose the expected KOI timing.  Syntax:
%
% plot_tps_flux_for_missing_kois( koisWithoutTcesStruct, tceStruct, iTarget )
%
%
%
% get_midTimestamps_filling_gaps:  construct a fully-monotonic vector of timestamps by
%     linearly interpolating from good cadence timestamps to gapped cadence timestamps.
%     Syntax:
%
%     timestampsMjd = get_midTimestamps_filling_gaps( cadenceTimes )
%
%     
%
% get_normal_and_fill_chunks:  returns cell arrays in which each cell is a list of
%     contiguous cadences of either good data or fill.  Syntax:
%
%     [normalChunks,fillChunks] = get_normal_and_fill_chunks( gapInfo, fillInfo,
%         nCadences, oneBased )
%
%     Arguments gapInfo and fillInfo can be either indices or indicators, and if indices
%     can be either one- or zero-based.
%
%
%
% plot_data_and_fill:  this is a generic function for plotting good data in blue and
%     filled data in red.  Syntax:
%
%     plot_data_and_fill( xAxisVector, yAxisVector, normalChunks, fillChunks )
%
%     
%
% construct_cadence_histogram:  this function builds the histogram of
%     contributions each cadence makes to a MES (AKA skyline plot). Syntax:
%
%     outlierStruct = construct_cadence_histogram(tceStruct, inputsStruct, ...
%         dynamicallyUpdateFlag, targetIndicator, useCINFlag, ...
%         generateOutlierStructFlag)
%
%
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

%
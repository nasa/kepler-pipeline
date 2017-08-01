function [anomalyTable, summaryTable] = pmd_get_table_of_anomalies( report, ...
    nAnomaliesPerMnemonicMax )
%
% pmd_get_table_of_anomalies -- assemble the anomalies from a PMD report into a cell
% array.
%
% anomalyTable = pmd_get_table_of_anomalies( report ) goes through the pmdOutputStruct
%    report and condenses all anomalies into a cell array.  The cells of the array have
%    the following definitions:
%
%    anomalyTable{:,1} == mnemonic for the metric
%    anomalyTable{:,2} == MJD of the anomaly
%    anomalyTable{:,3} == bound which was broken:  a choice of "AdaptiveUpper",
%                         "AdaptiveLower", "FixedUpper", "FixedLower"
%    anomalyTable{:,4} == value of the broken bound at the time of breakage
%    anomalyTable{:,5} == value of the metric at the time of breakage.
%
% The anomalyTable is sorted by MJD, with earliest first.
%
% [anomalyTable, summaryTable] = pmd_get_table_of_anomalies( report ) produces the anomaly
%    table plus a summary table.  The summary table is a cell array in which the cells are
%    defined as follows:
%
%    summaryTable{:,1} == mnemonic for the metric
%    summaryTable{:,2} == total number of anomalies for the specified metric
%    summaryTable{:,3} == MJD of the earliest anomaly for this mnemonic
%    summaryTable{:,4} == MJD of the latest anomaly for this mnemonic.
%
% [...] = pmd_get_table_of_anomalies( report, nAnomaliesPerMnemonicMax ) produces an
%    anomaly table in which any mnemonic which has a number of anomalies which exceeds
%    nAnomaliesPerMnemonicMax is removed from the table in its entirety.  The summary
%    table, if requested, will include both mnemonics which are removed from the anomaly
%    table and mnemonics which are not removed.
%
% Version Date:  2009-November-19.
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

% Modification History:
%
%    2009-November-19, PT:
%        produce summary table and limit composition of anomaly table.
%
%=========================================================================================

% if no max # of anomalies per mnemonic, then set a default of inf.

  if ~exist( 'nAnomaliesPerMnemonicMax','var' ) || isempty( nAnomaliesPerMnemonicMax )
      nAnomaliesPerMnemonicMax = inf ;
  end

% Some of the report fields have only 1 set of metrics in them, and others have more.
% Build a modified report structure in which all of the fields have the same sub-structure
% and level of nesting.

  reportNew = flatten_pmd_report_structure( report ) ;

  boundType = {'AdaptUpper' , 'AdaptLower' , 'FixedUpper' , 'FixedLower'} ;
  anomalyTable = {'Metric' , 'MJD', 'BoundType' , 'BoundValue' , 'MetricValue' } ;
  
% loop over fields in the flattened structure

  metricName = fieldnames(reportNew) ;
  for iMetric = 1:length(metricName)
      
%     loop over types of anomalies -- adaptive and fixed -- and get the data out of the
%     report as a matrix

      anomalyMatrix = [] ;
      anomalyType = {'adaptiveBoundsReport' , 'fixedBoundsReport'} ;
      for iAnomaly = 1:2
           
          anomalyMatrix = [anomalyMatrix ; get_anomalies( ...
              reportNew.(metricName{iMetric}).(anomalyType{iAnomaly}), iAnomaly )] ;
          
      end
      
%     put the values from the matrix into the table

      lengthAnomalyTable = size(anomalyTable,1) ;
      nAnomaly = size(anomalyMatrix,1) ;
      for iAnomaly2 = 1:nAnomaly
          anomalyTable{lengthAnomalyTable+iAnomaly2,1} = metricName{iMetric} ;
          anomalyTable{lengthAnomalyTable+iAnomaly2,2} = anomalyMatrix(iAnomaly2,1) ;
          anomalyTable{lengthAnomalyTable+iAnomaly2,3} = ...
              boundType{ anomalyMatrix(iAnomaly2,2) } ;
          anomalyTable{lengthAnomalyTable+iAnomaly2,4} = anomalyMatrix(iAnomaly2,3) ;
          anomalyTable{lengthAnomalyTable+iAnomaly2,5} = anomalyMatrix(iAnomaly2,4) ;
      end
      
  end % loop over report fields
  
% produce the summary table 

  summaryTable = generate_summary_table( anomalyTable ) ;
  
% trim the anomaly table according to the max # of anomalies permitted per mnemonic

  anomalyTable = trim_anomaly_table( anomalyTable, nAnomaliesPerMnemonicMax ) ;
  
% Get a sortkey for the MJDs

  if (size(anomalyTable,1) > 1)
      mjdAnomaly = [anomalyTable{2:end,2}] ;
      [mjdInOrder,sortKey] = sort(mjdAnomaly) ;
      sortKey = sortKey + 1 ;

      anomalyTableSorted = anomalyTable ;
      for iAnomaly = 2:size(anomalyTable,1)
          for iColumn = 1:5
              anomalyTableSorted{iAnomaly,iColumn} = ...
              anomalyTable{sortKey(iAnomaly-1),iColumn} ;
          end
          anomalyTableSorted{iAnomaly,2} = num2str(anomalyTableSorted{iAnomaly,2},'%11.5f') ;
      end
      anomalyTable = anomalyTableSorted ;
  end
    
% and that's it!

%
%
%

%=========================================================================================

% function which flattens the report structure and renames the metrics when necessary

function reportNew = flatten_pmd_report_structure( report )

  reportNew.dummy = [] ;

% get the field names from report

  reportMetrics = fieldnames(report) ;
  
% loop over the metrics

  for iMetric = 1:length(reportMetrics)
      
%     use a switch statement to identify cases in which we need to drill down

      switch reportMetrics{iMetric}
          
          case { 'ldeUndershoot' } % 3 sub-structs under the metric
              
              for iSubField = 1:length(report.ldeUndershoot)
                  metricName = ['lde',num2str(iSubField)] ;
                  reportNew = add_metric(reportNew, metricName, ...
                      report.ldeUndershoot(iSubField)) ;
              end
              
          case { 'twoDBlack' } % 4 sub-structs under the metric
                  
              for iSubField = 1:length(report.twoDBlack)
                  metricName = ['twoDBlack',num2str(iSubField)] ;
                  reportNew = add_metric(reportNew, metricName, ...
                      report.twoDBlack(iSubField)) ;
              end
              
          case { 'blackCosmicRayMetrics', 'maskedSmearCosmicRayMetrics', ...
                 'virtualSmearCosmicRayMetrics', 'targetStarCosmicRayMetrics', ...
                 'backgroundCosmicRayMetrics' } % 5 sub-structs under the metric
             
             switch reportMetrics{iMetric} % get the new metric name
                 case { 'blackCosmicRayMetrics' }
                     metricNameBase = 'blckCR' ;
                 case { 'maskedSmearCosmicRayMetrics' }
                     metricNameBase = 'mskdCR' ;
                 case { 'virtualSmearCosmicRayMetrics' }
                     metricNameBase = 'virtCR' ;
                 case { 'targetStarCosmicRayMetrics' }
                     metricNameBase = 'targCR' ;
                 case { 'backgroundCosmicRayMetrics' }
                     metricNameBase = 'bkgdCR' ;
             end
             
             crType = fieldnames(report.(reportMetrics{iMetric})) ;
             crTypeName = {'HitRate','Energy','Variance','Skewness','Kurtosis'} ;
             for iCrType = 1:length(crType)
                 metricName = [metricNameBase,crTypeName{iCrType}] ;
                 reportNew = add_metric(reportNew, metricName, ...
                     report.(reportMetrics{iMetric}).(crType{iCrType}) ) ;
             end
             
          case { 'cdppMeasured' , 'cdppExpected' , 'cdppRatio' } % CDPP nesting is deep!
              
              switch reportMetrics{iMetric} % abbreviated names
                  case { 'cdppMeasured' }
                      metricNameBase = 'cdppMeas' ;
                  case { 'cdppExpected' }
                      metricNameBase = 'cdppExp' ;
                  case { 'cdppRatio' }
                      metricNameBase = 'cdppRat' ;
              end
              
              cdppMag = fieldnames(report.(reportMetrics{iMetric})) ;
              magTypeName = {'M09','M10','M11','M12','M13','M14','M15'} ;
              for iMag = 1:length(cdppMag)
                  
                  cdppTime = fieldnames(report.(reportMetrics{iMetric}).(cdppMag{iMag})) ;
                  timeName = {'03hr','06hr','12hr'} ;
                  
                  for iTime = 1:length(cdppTime)
                      metricName = [metricNameBase,timeName{iTime},magTypeName{iMag}] ;
                      reportNew = add_metric(reportNew, metricName, ...
                          report.(reportMetrics{iMetric}).(cdppMag{iMag}).(cdppTime{iTime})) ;
                  end
                  
              end
              
          case { 'theoreticalCompressionEfficiency' } % shorter name needed
              
              reportNew = add_metric(reportNew, 'theoCompEff', ...
                  report.(reportMetrics{iMetric})) ;
              
          case { 'achievedCompressionEfficiency' } % shorter name needed
              
              reportNew = add_metric(reportNew, 'achCompEff', ...
                  report.(reportMetrics{iMetric})) ;
              
          otherwise % no nesting, very simple
              
              reportNew = add_metric(reportNew, reportMetrics{iMetric}, ...
                  report.(reportMetrics{iMetric})) ;
              
      end % switch statement
      
  end % loop over fields in the original report structure
  
  reportNew = rmfield(reportNew,'dummy') ;  
  
% and that's it!

%
%
%

%=========================================================================================

% function which appends a new substructure onto the reportNew structure

function reportNew = add_metric( reportNew, metricName, metricStruct ) ;

% pretty simple, really:

  reportNew.(metricName) = metricStruct ;
  
% and that's it!

%
%
%

%=========================================================================================

% function which extracts the anomalies from a boundsReport

function anomalyMatrix = get_anomalies( anomalyReport, adaptOrFixed )

  anomalyUpper = [] ; anomalyLower = [] ;

% first get the out of upper bounds values

  if (anomalyReport.outOfUpperBoundsCount > 0)
      anomalyUpper = anomalyReport.outOfUpperBoundsTimes(:) ;
      anomalyUpper(:,2) = 1+(adaptOrFixed-1)*2 ;
      anomalyUpper(:,3) = anomalyReport.upperBound(:) ;
      anomalyUpper(:,4) = anomalyReport.outOfUpperBoundsValues ;
  end
  
% then get the out-of-lower bounds values

  if (anomalyReport.outOfLowerBoundsCount > 0)
      anomalyLower = anomalyReport.outOfLowerBoundsTimes(:) ;
      anomalyLower(:,2) = 2+(adaptOrFixed-1)*2 ;
      anomalyLower(:,3) = anomalyReport.lowerBound(:) ;
      anomalyLower(:,4) = anomalyReport.outOfLowerBoundsValues ;
  end
  
% put it all together

  anomalyMatrix = [anomalyUpper ; anomalyLower] ;
  
% and that's it!

%
%
%

%=========================================================================================

% subfunction which produces the summary table from the anomaly table

function summaryTable = generate_summary_table( anomalyTable )

% define the header row of the summary table

  summaryTable = { 'Metric' , '# Anomalies' , 'MJD First' , 'MJD Last' } ;
  
% proceed only if there are some anomalies

  if ( size( anomalyTable, 1 ) > 1 )

%     strip off the first row of the anomaly table, since that is the header row, and get
%     the mnemonic names and MJDs

      anomalyTableMnemonics = anomalyTable(2:end,1) ;
      anomalyTableMjds      = anomalyTable(2:end,2) ;
      
%     get the unique list of nmemonics

      uniqueMnemonics = unique( anomalyTableMnemonics ) ;
      
%     for each unique mnemonic, find the # of anomalies, the MJD of the earliest, and the
%     MJD of the lastest

      for iMnemonic = 1:length(uniqueMnemonics) 
          mnemonicPointer = find( strcmp( uniqueMnemonics{iMnemonic}, ...
              anomalyTableMnemonics ) ) ;
          nAnomalies = length(mnemonicPointer) ;
          mjdFirst = min( cell2mat( anomalyTableMjds(mnemonicPointer) ) ) ;
          mjdLast  = max( cell2mat( anomalyTableMjds(mnemonicPointer) ) ) ;
          
          summaryTable{iMnemonic+1,1} = uniqueMnemonics{iMnemonic} ;
          summaryTable{iMnemonic+1,2} = nAnomalies ;
          summaryTable{iMnemonic+1,3} = mjdFirst ;
          summaryTable{iMnemonic+1,4} = mjdLast ;
          
      end % loop over unique mnemonics
      
  end % anomaly existence conditional

return

% and that's it!

%
%
%

%=========================================================================================

% subfunction which trims the anomaly table based on the max # of anomalies per mnemonic

function anomalyTable = trim_anomaly_table( anomalyTable, nAnomaliesPerMnemonicMax )

% get a version of the table which does not have the header line

  if ( size(anomalyTable, 1) > 1 )
      
      anomalyTableHeader = anomalyTable(1,:) ;
      anomalyTable = anomalyTable(2:end,:) ;
      
%     get the list of unique mnemonics

      uniqueMnemonics = unique( anomalyTable(:,1) ) ;
      
%     go through the mnemonics and figure out how many there are of each, and where they
%     are

      for iMnemonic = 1:length( uniqueMnemonics )
          
          mnemonicPointer = find( strcmp( uniqueMnemonics{iMnemonic}, ...
              anomalyTable(:,1) ) ) ;
          
%         if the # exceeds the max allowed, delete them all

          if ( length( mnemonicPointer ) > nAnomaliesPerMnemonicMax )
              anomalyTable( mnemonicPointer, : ) = [] ; 
          end
          
      end % loop over mnemonics
  
% reattach the header line

      anomalyTable = [anomalyTableHeader ; anomalyTable] ;
      
  end % anomaly existence conditional
  
return

% and that's it!

%
%
%

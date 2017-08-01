    function self = test_retrieve_ts(self)
%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
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
    tic;

    display('test_retrieve_ts');
    display(datestr(now()));
    
    keplerIds = 8413815 ;
    keplerId = 8413815 ;
    coordinate=37;
    ccdMod=7;
    ccdOut=2;

   test_inputs
       fprintf('mjdStartq0 is %f, mjdEndq0 is %f, mjdStartq1 is %f, mjdEndq1 is %f, mjdStartq2 is %f, mjdEndq2 is %f,mjdStartq3 is %f, mjdEndq3 is %f, mjdStartq4 is %f, mjdEndq4 is %f, mjdStartq5 is %f, mjdEndq5 is %f, mjdStartq6 is %f, mjdEndq6 is %f, q0targetListSetName is %s, q1targetListSetName is %s, q2targetListSetName is %s, q3targetListSetName is %s, q4targetListSetName is %s, q5targetListSetName is %s, q6targetListSetName is %s, startCadenceq0 is %d, endCadenceqq0 is %d,startCadenceq1 is %f, endCadenceqq1 is %d, startCadence is %d, endCadenceqq2 is %d, startCadenceq3 is %d, endCadenceqq3 is %d,  startCadenceq4 is %d, endCadenceq4 is %d, startCadenceq5 is %d, endCadenceqq5 is %d, startCadenceq6 is %d, endCadenceqq6 is %d \n', ...  
               mjdStartq0, mjdEndq0, mjdStartq1, mjdEndq1, mjdStartq2, mjdEndq2, mjdStartq3, mjdEndq3, mjdStartq4, mjdEndq4,mjdStartq5, mjdEndq5,mjdStartq6, mjdEndq6,q0targetListSetName,q1targetListSetName,q2targetListSetName, q3targetListSetName, q4targetListSetName,q5targetListSetName, q6targetListSetName, startCadenceq0 , endCadenceq0, startCadenceq1, endCadenceq1, startCadence , endCadenceq3, startCadenceq4 , endCadenceq4, startCadenceq5 , endCadenceq5,  startCadenceq6 , endCadenceq6);
    
    display('Test : SapRawFluxLongUncert');
    
    tsFlux  = retrieve_ts('SapRawFluxLongUncert', keplerIds, startCadence, endCadence);
     
        if (isempty(tsFlux))
        assert(1, 0, 'The retrieved structure is empty.');
        end
    clear tsFlux;

    display('Done');
    
    display('test : SapRawFluxLongUncert ');
    
    tsFluxUncertainties = retrieve_ts('SapRawFluxLongUncert', keplerIds, startCadence, endCadence);
    if (isempty(tsFluxUncertainties))
        assert(1, 0, 'The retrieved structure is empty.');
    end


    clear tsFluxUncertainties;


    display('Test : PrfCentroidRows  ');
    
    tsPrfCentRow       = retrieve_ts('PrfCentroidRows',       keplerIds,startCadence, endCadence );
    if (isempty(tsPrfCentRow))
        assert(1, 0, 'The retrieved structure is empty.');
    end

    clear tsPrfCentRow;

    display('Test : PrfCentroidRowsUncert');
    tsPrfCentRowUncert = retrieve_ts('PrfCentroidRowsUncert', keplerIds, startCadence, endCadence);

    if (isempty(tsPrfCentRowUncert))
        assert(1, 0, 'The retrieved structure is empty.');
    end

    clear tsPrfCentRowUncert;


    display('Test :PrfCentroidCols');
    tsPrfCentCol       = retrieve_ts('PrfCentroidCols',       keplerIds,startCadence, endCadence );

    if (isempty(tsPrfCentCol))
        assert(1, 0, 'The retrieved structure is empty.');
    end;
    clear tsPrfCentCol;
    
    
    display('Test :PrfCentroidColsUncert ');
    tsPrfCentColUncert = retrieve_ts('PrfCentroidColsUncert', keplerIds, startCadence, endCadence);

    if (isempty(tsPrfCentColUncert))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear tsPrfCentColUncert;

    %  Get raw centroid rows/columns:
    
    display('Test :PrfCentroidCols');
    cols = retrieve_ts('CentroidCols', keplerIds, startCadence, endCadence);

    if (isempty(cols))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear cols;
    
    display('Test : CentroidRows');
    rows = retrieve_ts('CentroidRows', keplerIds,startCadence, endCadence );

    if (isempty(rows))
        assert(1, 0, 'The retrieved structure is empty.');
    end

    clear rows;
   
    display('Test : FluxWeightedCentroidRows');
    fwcRows       = retrieve_ts('FluxWeightedCentroidRows',       keplerIds,startCadence, endCadence);

    if (isempty(fwcRows))
        assert(1, 0, 'The retrieved structure is empty.');
    end

    clear fwcRows;
    
    display('Test :FluxWeightedCentroidRowsUncert ');
    fwcRowsUncert = retrieve_ts('FluxWeightedCentroidRowsUncert', keplerIds,startCadence, endCadence);

    if (isempty(fwcRowsUncert))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear fwcRowsUncert;
    
    display('Test : FluxWeightedCentroidCols');
    fwcCols       = retrieve_ts('FluxWeightedCentroidCols',       keplerIds,startCadence, endCadence );

    if (isempty(fwcCols))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear fwcCols;
    
    display('Test : FluxWeightedCentroidColsUncert');
    fwcColsUncert = retrieve_ts('FluxWeightedCentroidColsUncert', keplerIds, startCadence, endCadence);


    if (isempty(fwcColsUncert))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear fwcColsUncert;

    %    Get the SAP centroids and uncertainties for three Kepler IDS, plot them
    %   individually with errorbars, and also display a row/column plot:

    display('Test :SapCentroidCols ');
    sapCols       = retrieve_ts('SapCentroidCols',       keplerIds, startCadence, endCadence );

    if (isempty(sapCols))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear sapCols;
    
    display('Test :SapCentroidColsUncert  ');
    sapColsUncert = retrieve_ts('SapCentroidColsUncert', keplerIds,startCadence, endCadence );

    if (isempty(sapColsUncert))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear sapColsUncert;
    
    display('Test : SapCentroidRows');
    sapRows       = retrieve_ts('SapCentroidRows',       keplerIds,startCadence, endCadence );
    
    if (isempty(sapRows))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear sapRows ;
    
    display('Test : SapCentroidRowsUncert');
    sapRows   = retrieve_ts('SapCentroidRowsUncert', keplerIds, startCadence, endCadence );
    
    if (isempty(sapRows))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear sapRows;


    %  Get the CR mean energy for a mod/out and plot it:
    display('Test :PaLcCosmicRayMeanEnergy ');

    cosmicRayMeanEnergy = retrieve_ts('PaLcCosmicRayMeanEnergy', ccdMod, ccdOut,startCadence, endCadence  );
    
    if (isempty(cosmicRayMeanEnergy))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear cosmicRayMeanEnergy ;

    %  Get various  metrics time series and plot them for mod 7/out 3 for cadences 0-360:
    
   display('Test : CalAchievedCompEfficiencyCountsMetric');   
   ts = retrieve_ts('CalAchievedCompEfficiencyCountsMetric',ccdMod ,ccdOut , startCadence, endCadence);
    
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;

    display('Test : CalBlackLevelMetric');
   ts = retrieve_ts('CalBlackLevelMetric',ccdMod ,ccdOut , startCadence, endCadence );

   
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :CalBlackLevelUncertMetric ');
     ts = retrieve_ts('CalBlackLevelUncertMetric',ccdMod ,ccdOut ,startCadence, endCadence );


    
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :CalDarkCurrentMetric ');
 ts = retrieve_ts('CalDarkCurrentMetric',ccdMod ,ccdOut , startCadence, endCadence );


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test : CalDarkCurrentMetric');
    ts = retrieve_ts('CalDarkCurrentMetric',ccdMod, ccdOut, startCadence, endCadence);

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test : CalSmearLevelMetric');
     ts = retrieve_ts('CalSmearLevelMetric',ccdMod ,ccdOut ,startCadence, endCadence  );

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
  display('Test : CalSmearLevelUncertMetric');  
    
     ts = retrieve_ts('CalSmearLevelUncertMetric',ccdMod ,ccdOut , startCadence, endCadence );

  
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test : CalTheoreticalCompEffCountsMetric');
     ts = retrieve_ts('CalTheoreticalCompEffCountsMetric',ccdMod ,ccdOut ,startCadence, endCadence );


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    %  Get PA metrics time series and plot them for mod 7/out 3 and for cadences 0-360
    display('Test : PaLcCosmicRayMeanEnergy');  
    ts = retrieve_ts('PaLcCosmicRayMeanEnergy',ccdMod ,ccdOut ,startCadence, endCadence );
 
    

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
  display('Test : PaBrightness');  
     ts = retrieve_ts('PaBrightness',ccdMod ,ccdOut ,startCadence, endCadence );


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
  display('Test : PaBrightnessUncert');  
     ts = retrieve_ts('PaBrightnessUncert',ccdMod ,ccdOut ,startCadence, endCadence );

 
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaBgCosmicRayEnergyKurtosis ');
    
 ts = retrieve_ts('PaBgCosmicRayEnergyKurtosis',ccdMod ,ccdOut ,startCadence, endCadence );


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaBgCosmicRayEnergySkewness');
    
    ts = retrieve_ts('PaBgCosmicRayEnergySkewness',ccdMod ,ccdOut ,startCadence, endCadence );


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
   %  ts = retrieve_ts('PaBgEnergyVariance',ccdMod ,ccdOut ,startCadence, endCadence );
    display('Test :PaBgEnergyVariance');
    ts = retrieve_ts('PaBgEnergyVariance', 7, 3, 0, 360);
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaBgHitRate');
     ts = retrieve_ts('PaBgHitRate',ccdMod ,ccdOut ,startCadence, endCadence);


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PrfCentroidCols');
     ts = retrieve_ts('PaBgMeanEnergy',ccdMod ,ccdOut ,startCadence, endCadence );

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaLcEnergyKurtosis');
    
     ts = retrieve_ts('PaLcEnergyKurtosis',ccdMod ,ccdOut ,startCadence, endCadence );

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaLcEnergySkewness');
     ts = retrieve_ts('PaLcEnergySkewness',ccdMod ,ccdOut ,startCadence, endCadence );

 
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaLcEnergyVariance');
     ts = retrieve_ts('PaLcEnergyVariance',ccdMod ,ccdOut ,startCadence, endCadence );

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaLcHitRate');
 ts = retrieve_ts('PaLcHitRate',ccdMod ,ccdOut ,startCadence, endCadence );


    
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaLcMeanEnergy');
     ts = retrieve_ts('PaLcMeanEnergy',ccdMod ,ccdOut ,startCadence, endCadence );

 
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaEncircledEnergy');
     ts = retrieve_ts('PaEncircledEnergy',ccdMod ,ccdOut ,startCadence, endCadence );

  
    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PaEncircledEnergyUncert');
    
     ts = retrieve_ts('PaEncircledEnergyUncert',ccdMod ,ccdOut ,startCadence, endCadence );

   

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;

    % Get the DR collateral data for mod 7/out 3, coordinate 37 for cadences 0-400:

    display('Test :DrCollateralLongVirtualSmear');
     ts = retrieve_ts('DrCollateralLongVirtualSmear',ccdMod ,ccdOut,coordinate,startCadence, endCadence );

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    display('Test : DrCollateralLongMaskedSmear');
    ts = retrieve_ts('DrCollateralLongMaskedSmear',ccdMod ,ccdOut,coordinate ,startCadence, endCadence);


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    display('Test :DrCollateralLongBlack');
    ts = retrieve_ts('DrCollateralLongBlack',ccdMod ,ccdOut,coordinate  ,startCadence, endCadence );


    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;


    %  Get PPA covariance matrices:
    display('Test :PpaMaxAttitudeFocalPlaneResidual');
    
    ts = retrieve_ts('PpaMaxAttitudeFocalPlaneResidual', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;
display('Test :PpaCovarianceMatrix11');
    ts = retrieve_ts('PpaCovarianceMatrix11', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;
display('Test :PpaCovarianceMatrix12');
    ts = retrieve_ts('PpaCovarianceMatrix12', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;
display('Test :PpaCovarianceMatrix13');
    ts = retrieve_ts('PpaCovarianceMatrix13', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;
display('Test :PpaCovarianceMatrix22');
    ts = retrieve_ts('PpaCovarianceMatrix22', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;

display('Test :PpaCovarianceMatrix23');
    ts = retrieve_ts('PpaCovarianceMatrix23', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;
    display('Test :PpaCovarianceMatrix33');
    ts = retrieve_ts('PpaCovarianceMatrix33', 0, 400);
    if (isempty(ts))
        assert(true, 'The retrieved structure is empty.');
    end;

    clear ts ;


    % Get various PDQ data:
%     startCadenceq5 = 0;
%     endCadenceq5 = 500;

    display('Test :PdcSapCorrectedFlux');
    ts = retrieve_ts('PdcSapCorrectedFlux',       9283708, startCadence, endCadence );

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PdcSapCorrectedFluxUncert');
    ts = retrieve_ts('PdcSapCorrectedFluxUncert', 9283708, startCadence, endCadence);

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;
    
    display('Test :PdcSapFilledIndices');
    ts = retrieve_ts('PdcSapFilledIndices',       9283708, startCadence, endCadence);

    if (isempty(ts))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear ts ;

    display('Test :PaBarycentricTimeOffsetLong');
    barycentricTimeOffsetLong  = retrieve_ts('PaBarycentricTimeOffsetLong',  1723671, startCadence, endCadence);
    if (isempty(barycentricTimeOffsetLong))
        assert(1, 0, 'The retrieved structure is empty.');
    end;

    clear barycentricTimeOffsetLong ;


    toc;


    display('*********Done*******');
    end

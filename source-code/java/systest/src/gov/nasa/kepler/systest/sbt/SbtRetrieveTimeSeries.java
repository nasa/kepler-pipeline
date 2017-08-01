/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.systest.sbt;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.Cadence.CadenceType;
import static gov.nasa.kepler.common.Cadence.CadenceType.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.ArrayUtils;

import com.google.common.collect.*;

import static gov.nasa.kepler.systest.sbt.SbtRetrieveTimeSeries.TimeSeriesType.*;

public class SbtRetrieveTimeSeries extends AbstractSbt {
    public static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-time-series.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    private static final Map<String, TimeSeriesMetadata> fsIdMap;
    
    static {
        fsIdMap = initFsIdMap();
    }
    
    private static final class TimeSeriesMetadata {
        private final String mnemonic;
        private final String fsIdFormatString;
        private final TimeSeriesType timeSeriesType;
        private final String parameterDescription;
        private final CadenceType cadenceType;
        public TimeSeriesMetadata(String userName, String fsIdFormatString,
            TimeSeriesType timeSeriesType,
            String parameterDescription,
            CadenceType cadenceType,
            ImmutableSortedMap.Builder<String, TimeSeriesMetadata> allMetadata) {

            this.mnemonic = userName;
            this.fsIdFormatString = fsIdFormatString;
            this.parameterDescription = parameterDescription;
            this.timeSeriesType = timeSeriesType;
            this.cadenceType = cadenceType;
            allMetadata.put(this.mnemonic, this);
        }
    }
    
    public static class TimeSeriesContainer implements Persistable {
        List<SingleTimeSeriesContainer> timeSeries;
        
        public TimeSeriesContainer() {
            this.timeSeries = new ArrayList<SingleTimeSeriesContainer>();
        }
        

        public TimeSeriesContainer(TimeSeries[] multipleTimeSeries) {
            this.timeSeries = new ArrayList<SingleTimeSeriesContainer>();
            for (TimeSeries singleTimeSeries : multipleTimeSeries) {
                SingleTimeSeriesContainer singleTimeSeriesContainer = new SingleTimeSeriesContainer(singleTimeSeries);
                this.timeSeries.add(singleTimeSeriesContainer);
            }
        }
    }
    
    
    
    public static enum TimeSeriesType {
        FLOAT_TIME_SERIES,
        INT_TIME_SERIES,
        TIMESERIES_LISTING
    }
    
    public static class SingleTimeSeriesContainer implements Persistable {
        public float[] fdata = new float[0];
        public int[] idata = new int[0];
        public boolean[] gapIndicators = new boolean[0];
        boolean isFloat;
        public int startCadence;
        public int endCadence;
        public List<SimpleInterval> validCadences = newArrayList();
        
        public SingleTimeSeriesContainer(TimeSeries timeSeries) {
            this.gapIndicators = timeSeries.getGapIndicators();
            this.startCadence = timeSeries.startCadence();
            this.endCadence = timeSeries.endCadence();
            this.validCadences = timeSeries.validCadences();

            this.isFloat = timeSeries.isFloat();
            if (this.isFloat) {
                this.fdata = (float[]) timeSeries.series();
                this.idata = new int[0];
            } else {
                this.fdata = new float[0];
                this.idata = (int[]) timeSeries.series();
            }
        }
    }

    public SbtRetrieveTimeSeries(){
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }
    
    public String cadenceTypeForMnemonic(String mnemonic) {
        return fsIdMap.get(mnemonic).cadenceType.getName();
    }
    
    public String listTimeSeries(String lsFsIdKey, String pathPart) throws Exception {
        List<List<Object>> args = new ArrayList<List<Object>>();
        args.add(new ArrayList<Object>());
        args.get(0).add(pathPart);
        int fakeStartCadence = 0;
        int fakeEndCadence = 0;
        return retrieveTimeSeries(lsFsIdKey, args, fakeStartCadence, fakeEndCadence);
    }
    
    /**
     * Produce a human readable list of help for all the mnemonics available.
     * There is some matlab specific syntax here, but I feel like that is acceptable
     * since this is called from matlab.
     * @return non-null string
     */
    public String mnemonics() {
        StringBuilder bldr = new StringBuilder(2048);
        for (TimeSeriesMetadata metadata : fsIdMap.values()) {
            bldr.append("retrieve_ts(");
            bldr.append("'").append(metadata.mnemonic).append("'").append(',').
                append(metadata.parameterDescription);
            if (bldr.charAt(bldr.length() - 1) != ',') {
                bldr.append(',');
            }
            bldr.append(" startCadence, endCadence)\n");
        }
        return bldr.toString();
    }
    
    public String retrieveSpecificFsIds(String[] fsIdNames, int startCadence, int endCadence, boolean isTimeSeriesFloat) throws Exception {
        if (! validateDatastores()) {
            return "";
        }

        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());

        TicToc.tic("Retrieving time series...");        
        
        FsId[] fsIds = new FsId[fsIdNames.length];
        for (int ii = 0; ii < fsIdNames.length; ++ii) {
            fsIds[ii] = new FsId(fsIdNames[ii]);
        }
        
        TimeSeries[] multipleTimeSeries = new TimeSeries[0];
        if (isTimeSeriesFloat) {
            multipleTimeSeries = fileStoreClient.readTimeSeriesAsFloat(fsIds, startCadence, endCadence, false);
        } else {
            multipleTimeSeries = fileStoreClient.readTimeSeriesAsInt(fsIds, startCadence, endCadence, false);
        }
        TimeSeriesContainer timeSeriesContainer = new TimeSeriesContainer(multipleTimeSeries);
        
        TicToc.toc();
        return makeSdf(timeSeriesContainer, SDF_FILE_NAME);        
    }
    
    public String retrieveTimeSeries(String fsIdKey, List<List<Object>> args, int startCadence, int endCadence) throws Exception {
        if (! validateDatastores()) {
            return "";
        }

        Pair<FsId[], TimeSeriesType> fsIdsPair = buildFsIds(fsIdKey, args);
        FsId[] fsIds = fsIdsPair.left;
        TimeSeriesType timeSeriesType = fsIdsPair.right;
        
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());

        TicToc.tic("Retrieving time series...");        
        TimeSeries[] multipleTimeSeries = new TimeSeries[0];
        switch (timeSeriesType) {
            case FLOAT_TIME_SERIES:
                multipleTimeSeries = fileStoreClient.readTimeSeriesAsFloat(fsIds, startCadence, endCadence, false);
                break;
            case INT_TIME_SERIES:
                multipleTimeSeries = fileStoreClient.readTimeSeriesAsInt(fsIds, startCadence, endCadence, false);
                break;
            case TIMESERIES_LISTING:
                System.out.println("this should be listing something");
                String pathPart = (String) args.get(0).get(0); 
                runListing(pathPart);
                break;
            default:
                break;
        }
        TimeSeriesContainer timeSeriesContainer = new TimeSeriesContainer(multipleTimeSeries);
        
        TicToc.toc();
        return makeSdf(timeSeriesContainer, SDF_FILE_NAME);
    }
    
    private void runListing(String pathPart) {
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance(ConfigurationServiceFactory.getInstance());
        String queryString = "TimeSeries@" + pathPart + "/*";
        Set<FsId> fsIds = fileStoreClient.queryIds2(queryString);
        for (FsId fsId : fsIds) {
            System.out.println(fsId.toString());
        }
    }

    private Pair<FsId[], TimeSeriesType> buildFsIds(String fsIdMapKey, List<List<Object>> args) {
        TimeSeriesMetadata metadata = getFsIdMetadata(fsIdMapKey);
        
        String printfString = metadata.fsIdFormatString;
        TimeSeriesType timeSeriesType = metadata.timeSeriesType;
        
        List<Object[]> printfArgs = generatePrintfArgsPerFsID(args);
        
        FsId[] fsIds = new FsId[printfArgs.size()];
        for (int ifsid = 0; ifsid < fsIds.length; ++ifsid) {
           Object[] coercedPrintfArguments = 
                coerceToFormatStringType(printfString, printfArgs.get(ifsid));
            String fsIdName = String.format(printfString, coercedPrintfArguments);
            fsIds[ifsid] = new FsId(fsIdName);
        }

        if (log.isDebugEnabled()) {
            log.debug("FsIds to retrieve.");
            log.debug(Arrays.toString(fsIds));
        }
        return Pair.of(fsIds, timeSeriesType);
    }
    
    /**
     * Attempt to convert the arguments presented in formatArguments to the
     * types required by printfString.
     * TODO:  This function does not coerce types for all possible format strings.
     * @param printfString
     * @param formatArguments
     */
    private Object[] coerceToFormatStringType(String printfString, Object[] formatArguments) {
        Pattern printfFormatPattern = Pattern.compile("%[dsgf]");
        Matcher m = printfFormatPattern.matcher(printfString);
        Object[] outputList  = new Object[formatArguments.length];
        int codeIndex = 0;
        while (m.find()) {
            String formatCode = m.group();
            Object formatArg = formatArguments[codeIndex];
            if (formatCode.indexOf('d') != -1) {
                //Coerce to integral value.
                if (formatArg instanceof Integer) {
                    //OK
                } else if (formatArg instanceof Long) {
                    //OK
                } else if (formatArg instanceof String) {
                    if (((String) formatArg).indexOf('.') != -1) {
                        formatArg = (long) Double.parseDouble((String) formatArg);
                    } else {
                        formatArg = Long.parseLong((String) formatArg);
                    }
                } else if (formatArg instanceof Double) {
                    long longValue = (long) ((Double) formatArg).doubleValue();
                    formatArg = longValue;
                } else if (formatArg instanceof Float) {
                    float floatValue = ((Float)formatArg).floatValue();
                    formatArg = (long) floatValue;
                }
            }
            outputList[codeIndex] = formatArg;
            codeIndex++;
        }
        return outputList;
    }

    private List<Object[]> generatePrintfArgsPerFsID(List<List<Object>> args) {
        List<Object[]> printfArgs = new ArrayList<Object[]>();

        if (args.size() == 0) {
            printfArgs.add(ArrayUtils.EMPTY_OBJECT_ARRAY);
            return printfArgs;
        }
        int numRequestedFsIds = args.get(0).size(); 
        for (int ifsid = 0; ifsid < numRequestedFsIds; ++ifsid) {
        
            List<Object> argsForThisFsId = new ArrayList<Object>();
            
            for (List<Object> arg : args) {
                boolean isArgVector = arg.size() > 1;
                int indexForThisFsIdsArgValue = isArgVector ? ifsid : 0;
                argsForThisFsId.add(arg.get(indexForThisFsIdsArgValue));
            }
            
            printfArgs.add(argsForThisFsId.toArray());
        }
        return printfArgs;
    }

    private TimeSeriesMetadata getFsIdMetadata(String mnemonic) {
        TimeSeriesMetadata metadata = fsIdMap.get(mnemonic);
        if (metadata == null) {
            throw new IllegalArgumentException("Invalid mnemonic \"" + mnemonic + "\"\n");
        }
        return metadata;
    }
 
    private static Map<String, TimeSeriesMetadata> initFsIdMap() {
        ImmutableSortedMap.Builder<String, TimeSeriesMetadata> bldr = 
            new ImmutableSortedMap.Builder<String, TimeSeriesMetadata>(Ordering.natural());

       for (CollateralType collateralType : CollateralType.values()) {
           for (CosmicRayMetricType cosmicRayMetricType : CosmicRayMetricType.values()) {
               if (collateralType != CollateralType.BLACK_MASKED && collateralType != CollateralType.BLACK_VIRTUAL) {
                   new TimeSeriesMetadata("CalLongCRMetric_" + collateralType.getName() + "_" + cosmicRayMetricType.getName(),
                       "/cal/metrics/CosmicRayMetrics/long:%d:%d:" + collateralType.getName() + ":" + cosmicRayMetricType.getName(),
                            FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
               }
               new TimeSeriesMetadata("CalShortCRMetric_" + collateralType.getName() + "_" + cosmicRayMetricType.getName(),
                        "/cal/metrics/CosmicRayMetrics/short:%d:%d:"+ collateralType.getName() + ":" + cosmicRayMetricType.getName(),
                        FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
           }
       }
       
      
        new TimeSeriesMetadata("CalAchievedCompEfficiencyMetric", "/cal/metrics/long:AchievedCompressionEfficiency:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("CalAchievedCompEfficiencyShortMetric", "/cal/metrics/short:AchievedCompressionEfficiency:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalAchievedCompEfficiencyCountsMetric", "/cal/metrics/long:AchievedCompressionEfficiencyCounts:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("CalAchievedCompEfficiencyCountsShortMetric", "/cal/metrics/short:AchievedCompressionEfficiencyCounts:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalBlackLevelMetric", "/cal/metrics/long:BlackLevel:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput",  LONG, bldr);
        new TimeSeriesMetadata("CalBlackLevelShortMetric", "/cal/metrics/short:BlackLevel:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalBlackLevelUncertMetric", "/cal/metrics/long:BlackLevelUncertainties:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput",  LONG, bldr);
        new TimeSeriesMetadata("CalBlackLevelUncertShortMetric", "/cal/metrics/short:BlackLevelUncertainties:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalDarkCurrentMetric", "/cal/metrics/long:DarkCurrent:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput",  LONG, bldr);
        new TimeSeriesMetadata("CalDarkCurrentShortMetric", "/cal/metrics/short:DarkCurrent:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalDarkCurrentUncertMetric", "/cal/metrics/long:DarkCurrentUncertainties:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("CalDarkCurrentUncertShortMetric", "/cal/metrics/short:DarkCurrentUncertainties:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalSmearLevelMetric", "/cal/metrics/long:SmearLevel:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput",  LONG, bldr);
        new TimeSeriesMetadata("CalSmearLevelShortMetric", "/cal/metrics/short:SmearLevel:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalSmearLevelUncertMetric", "/cal/metrics/long:SmearLevelUncertainties:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput",  LONG, bldr);
        new TimeSeriesMetadata("CalSmearLevelUncertShortMetric", "/cal/metrics/short:SmearLevelUncertainties:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalTheoreticalCompEffMetric", "/cal/metrics/long:TheoreticalCompressionEfficiency:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("CalTheoreticalCompEffShortMetric", "/cal/metrics/short:TheoreticalCompressionEfficiency:%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("CalTheoreticalCompEffCountsMetric", "/cal/metrics/long:TheoreticalCompressionEfficiencyCounts:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("CalTheoreticalCompEffCountsShortMetric", "/cal/metrics/short:TheoreticalCompressionEfficiencyCounts:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);

        new TimeSeriesMetadata("CalLongCadence", "/cal/pixels/SocCal/lct/%d/%d/%d:%d", FLOAT_TIME_SERIES,"ccdModule, ccdOutput, ccdRow, ccdCol", LONG, bldr);
        new TimeSeriesMetadata("CalShortCadence", "/cal/pixels/SocCal/sct/%d/%d/%d/%d",  FLOAT_TIME_SERIES,"ccdModule, ccdOutput, ccdRow, ccdCol", SHORT, bldr);
       
        for (CollateralType collateralType : CollateralType.values()) {
            if (collateralType != CollateralType.BLACK_MASKED && collateralType != CollateralType.BLACK_VIRTUAL) {
                new TimeSeriesMetadata("CalLongCollateral_" + collateralType.getName(),  "/cal/pixels/SocCal/collateral/long/%d/%d/" + collateralType.getName() + ":%d",  FLOAT_TIME_SERIES, "ccdModule, ccdOutput, ccdRowOrCcdCol", LONG, bldr);
            }
            new TimeSeriesMetadata("CalShortCollateral_" + collateralType.getName(), "/cal/pixels/SocCal/collateral/short/%d/%d/" + collateralType.getName() + ":%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput, ccdRowOrCcdCol", SHORT, bldr);
        }
        new TimeSeriesMetadata("CalBackgroundPixels", "/cal/pixels/SocCal/bgp/%d/%d/%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput, ccdRow, ccdColumn", LONG, bldr);

        new TimeSeriesMetadata("DrCollateralLongBlack", "/dr/pixel/col/Orig/long/BlackLevel:%d:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("DrCollateralLongBlackShort", "/dr/pixel/col/Orig/short/BlackLevel:%d:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("DrCollateralLongMaskedSmear", "/dr/pixel/col/Orig/long/MaskedSmear:%d:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("DrCollateralLongMaskedSmearShort", "/dr/pixel/col/Orig/short/MaskedSmear:%d:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("DrCollateralLongVirtualSmear", "/dr/pixel/col/Orig/long/MaskedSmear:%d:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("DrCollateralLongVirtualSmearShort", "/dr/pixel/col/Orig/short/MaskedSmear:%d:%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput", SHORT, bldr);
        new TimeSeriesMetadata("DrLongCadencePixels", "/dr/pixel/sci/Orig/lct/%d/%d/%d:%d", INT_TIME_SERIES, "ccdModule, ccdOutput, ccdRow, ccdColumn", LONG, bldr);
        new TimeSeriesMetadata("DrBackgroundPixels","/dr/pixel/sci/Orig/bgp/%d/%d/%d:%d", INT_TIME_SERIES,  "ccdModule, ccdOutput, ccdRow, ccdColumn", LONG, bldr);
        new TimeSeriesMetadata("SapRawFluxLong", "/pa/targets/SapRawFlux/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("SapRawFluxShort", "/pa/targets/SapRawFlux/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("SapRawFluxLongUncert", "/pa/targets/SapRawFluxUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("SapRawFluxShortUncert", "/pa/targets/SapRawFluxUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);

        new TimeSeriesMetadata("PrfCentroidCols", "/pa/targets/Sap/Prf/CentroidCols/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PrfCentroidColsShort", "/pa/targets/Sap/Prf/CentroidCols/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("PrfCentroidColsUncert", "/pa/targets/Sap/Prf/CentroidColsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PrfCentroidColsUncertShort", "/pa/targets/Sap/Prf/CentroidColsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("PrfCentroidRows", "/pa/targets/Sap/Prf/CentroidRows/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PrfCentroidRowsShort", "/pa/targets/Sap/Prf/CentroidRows/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("PrfCentroidRowsUncert", "/pa/targets/Sap/Prf/CentroidRowsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PrfCentroidRowsUncertShort", "/pa/targets/Sap/Prf/CentroidRowsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidRows", "/pa/targets/Sap/FluxWeighted/CentroidRows/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidRowsShort", "/pa/targets/Sap/FluxWeighted/CentroidRows/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidRowsUncert", "/pa/targets/Sap/FluxWeighted/CentroidRowsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidRowsUncertShort", "/pa/targets/Sap/FluxWeighted/CentroidRowsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidCols", "/pa/targets/Sap/FluxWeighted/CentroidCols/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidColsShort", "/pa/targets/Sap/FluxWeighted/CentroidCols/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidColsUncert", "/pa/targets/Sap/FluxWeighted/CentroidColsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("FluxWeightedCentroidColsUncertShort", "/pa/targets/Sap/FluxWeighted/CentroidColsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("SapCentroidCols", "/pa/targets/Sap/CentroidCols/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("SapCentroidColsShort", "/pa/targets/Sap/CentroidCols/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("SapCentroidColsUncert", "/pa/targets/Sap/CentroidColsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("SapCentroidColsUncertShort", "/pa/targets/Sap/CentroidColsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("SapCentroidRows", "/pa/targets/Sap/CentroidRows/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("SapCentroidRowsShort", "/pa/targets/Sap/CentroidRows/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("SapCentroidRowsUncert", "/pa/targets/Sap/CentroidRowsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("SapCentroidRowsUncertShort", "/pa/targets/Sap/CentroidRowsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("CentroidCols", "/pa/targets/CentroidCols/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("CentroidColsShort", "/pa/targets/CentroidCols/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("CentroidColsUncert", "/pa/targets/CentroidColsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("CentroidColsUncertShort", "/pa/targets/CentroidColsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("CentroidRows", "/pa/targets/CentroidRows/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("CentroidRowsShort", "/pa/targets/CentroidRows/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("CentroidRowsUncert", "/pa/targets/CentroidRowsUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("CentroidRowsUncertShort", "/pa/targets/CentroidRowsUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);

        new TimeSeriesMetadata("PaLcCosmicRayMeanEnergy", "/pa/metrics/CosmicRay/%d:%d:lct:MeanEnergy", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBrightness", "/pa/metrics/Brightness/%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBrightnessUncert", "/pa/metrics/BrightnessUncertainties/%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBgCosmicRayEnergyKurtosis", "/pa/metrics/CosmicRay/%d:%d:bgp:EnergyKurtosis", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBgCosmicRayEnergySkewness", "/pa/metrics/CosmicRay/%d:%d:bgp:EnergySkewness", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBgEnergyVariance", "/pa/metrics/CosmicRay/%d:%d:bgp:EnergyVariance", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBgHitRate", "/pa/metrics/CosmicRay/%d:%d:bgp:HitRate", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaBgMeanEnergy", "/pa/metrics/CosmicRay/%d:%d:bgp:MeanEnergy", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaLcEnergyKurtosis", "/pa/metrics/CosmicRay/%d:%d:lct:EnergyKurtosis", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaLcEnergySkewness", "/pa/metrics/CosmicRay/%d:%d:lct:EnergySkewness", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaLcEnergyVariance", "/pa/metrics/CosmicRay/%d:%d:lct:EnergyVariance", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaLcHitRate", "/pa/metrics/CosmicRay/%d:%d:lct:HitRate", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaLcMeanEnergy", "/pa/metrics/CosmicRay/%d:%d:lct:MeanEnergy", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaEncircledEnergy", "/pa/metrics/EncircledEnergy/%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);
        new TimeSeriesMetadata("PaEncircledEnergyUncert", "/pa/metrics/EncircledEnergyUncertainties/%d:%d", FLOAT_TIME_SERIES, "ccdModule, ccdOutput", LONG, bldr);

        new TimeSeriesMetadata("PaBarycentricTimeOffsetLong", "/pa/targets/BarycentricTimeOffset/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PaBarycentricTimeOffsetShort", "/pa/targets/BarycentricTimeOffset/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);

        new TimeSeriesMetadata("PpaMaxAttitudeFocalPlaneResidual", "/ppa/MaxAttitudeFocalPlaneResidual",  FLOAT_TIME_SERIES, "", LONG, bldr);
                                                                    
        new TimeSeriesMetadata("PpaCovarianceMatrix13", "/ppa/CovarianceMatrix13", FLOAT_TIME_SERIES, "", LONG, bldr);
        new TimeSeriesMetadata("PpaCovarianceMatrix11", "/ppa/CovarianceMatrix11", FLOAT_TIME_SERIES, "", LONG, bldr);
        new TimeSeriesMetadata("PpaCovarianceMatrix12", "/ppa/CovarianceMatrix12", FLOAT_TIME_SERIES, "", LONG, bldr);
        new TimeSeriesMetadata("PpaCovarianceMatrix23", "/ppa/CovarianceMatrix23", FLOAT_TIME_SERIES, "", LONG, bldr);
        new TimeSeriesMetadata("PpaCovarianceMatrix33", "/ppa/CovarianceMatrix33", FLOAT_TIME_SERIES, "", LONG, bldr);
        new TimeSeriesMetadata("PpaCovarianceMatrix22", "/ppa/CovarianceMatrix22", FLOAT_TIME_SERIES, "", LONG, bldr);

        new TimeSeriesMetadata("PdcSapCorrectedFlux", "/pdc/SapCorrectedFlux/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PdcSapCorrectedFluxUncert", "/pdc/SapCorrectedFluxUncertainties/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PdcSapCorrectedFluxShort", "/pdc/SapCorrectedFlux/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("PdcSapCorrectedFluxUncertShort", "/pdc/SapCorrectedFluxUncertainties/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);

        new TimeSeriesMetadata("PdcSapFilledIndices", "/pdc/sap/FilledIndices/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PdcSapFilledIndicesShort", "/pdc/sap/FilledIndices/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        new TimeSeriesMetadata("PdcSapOutliers", "/pdc/sap/Outliers/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PdcSapOutliersShort", "/pdc/sap/Outliers/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
 
        new TimeSeriesMetadata("PdcSapOutliersUncert", "/pdc/sap/OutliersUncertainies/long/%d", FLOAT_TIME_SERIES, "keplerId", LONG, bldr);
        new TimeSeriesMetadata("PdcSapOutliersUncertShort", "/pdc/sap/OutliersUncertainies/short/%d", FLOAT_TIME_SERIES, "keplerId", SHORT, bldr);
        return bldr.build();
    }
    
    public static void main(String[] args) throws Exception {
        String fsIdKey = "PaLcCosmicRayMeanEnergy";
        SbtRetrieveTimeSeries sbt = new SbtRetrieveTimeSeries();
        
//        String[] realArgs = { fsIdKey, "7 7 23 24", "1 2 3 3", "0", "500"}; 
//        String path = sbt.retrieveTimeSeries(realArgs);
        
        List<List<Object>> sbtArgs = new ArrayList<List<Object>>();
        sbtArgs.add(new ArrayList<Object>(Arrays.asList(7, 7, 23, 24))); // module #
        sbtArgs.add(new ArrayList<Object>(Arrays.asList(1, 2,  3,  3))); // output #
        int startCadence = 0; // startCadence
        int endCadence = 500;
        String pathList = sbt.retrieveTimeSeries(fsIdKey, sbtArgs, startCadence, endCadence);

        String path2 = sbt.listTimeSeries("ls", "/pa/targets/SapRawFlux/long");
        
        String[] fsIdNames = { "/pa/targets/Sap/FluxWeighted/CentroidRows/short", "/pa/targets/Sap/FluxWeighted/CentroidRows/long" };
        String path3 = sbt.retrieveSpecificFsIds(fsIdNames, startCadence, endCadence, true);

        System.out.println(pathList);
        System.out.println(path2);
        System.out.println(path3);
    }
    
}

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

package gov.nasa.kepler.ar.exporter.cal;

import static gov.nasa.kepler.ar.exporter.cal.FsIdFactoryType.CALIBRATED;
import static gov.nasa.kepler.ar.exporter.cal.FsIdFactoryType.CALIBRATED_UNCERT;
import static gov.nasa.kepler.ar.exporter.cal.FsIdFactoryType.ORIG;
import static gov.nasa.kepler.common.Cadence.CADENCE_LONG;
import static gov.nasa.kepler.common.Cadence.CADENCE_SHORT;
import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.spiffy.common.collect.LruCache;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.*;

import nom.tam.fits.*;
import nom.tam.util.Cursor;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


enum PixelDataType implements PixelTypeInterface {
    SHORT_TARGET(CADENCE_SHORT, "scs-targ", 
                            SHORT_CADENCE_PMRF_KW, TargetType.SHORT_CADENCE), 
     LONG_TARGET(CADENCE_LONG, "lcs-targ",
                         LONG_CADENCE_PMRF_KW, TargetType.LONG_CADENCE), 
    BACKGROUND(CADENCE_LONG, "lcs-bkg", BACKGROUND_PMRF_KW, 
                        TargetType.BACKGROUND),
    SHORT_COLLATERAL(CADENCE_SHORT, "scs-col", 
                                    SHORT_CADENCE_COLLATERAL_PMRF_KW, null), 
    LONG_COLLATERAL(CADENCE_LONG, "lcs-col", 
                                    LONG_CADENCE_COLLATERAL_PMRF_KW, null);

    
    private final static Log log = LogFactory.getLog(PixelDataType.class);
    
    private final static String CAL_COL_TYPE_KW = "TTYPE2";
    private final static String CAL_COL_TYPE_VALUE = "cal_value";
    private final static String CAL_COL_FORM_KW = "TFORM2";
    private final static String CAL_COL_FORM_VALUE = "1E";
    private final static String CAL_COL_DISP_KW = "TDISP2";
    private final static String CAL_COL_DISP_VALUE = "F16.3";
    private final static String CAL_COL_UNIT_KW = "TUNIT2";
    private final static String CAL_COL_UNIT_VALUE = "e-";
    private final static String CAL_COL_UNIT_COMMENT = "calibrated pixel value in photo electrons";

    
    private final static String UNCERT_COL_TYPE_KW = "TTYPE3";
    private final static String UNCERT_COL_TYPE_VALUE = "cal_uncert";
    private final static String UNCERT_COL_FORM_KW = "TFORM3";
    private final static String UNCERT_COL_FORM_VALUE = "1E";
    private final static String UNCERT_COL_DISP_KW = "TDISP3";
    private final static String UNCERT_COL_DISP_VALUE = "F16.3";
    private final static String UNCERT_COL_UNIT_KW = "TUNIT3";
    private final static String UNCERT_COL_UNIT_VALUE = "sd e-";
    private final static String UNCERT_COL_UNIT_COMMENT = "standard deviation, in photo electrons";
    
    private final static int MAX_CACHED_PMRF = 6;
    private final static int MAX_CACHED_FSID_LIST = 32;
    
    private final int cadenceType;
    private final String fitsName;
    private final String pixelMappingKeyword;
    private final TargetType targetTableType;
    private final Map<String, Fits> pmrfCache = 
        Collections.synchronizedMap(new LruCache<String, Fits>(MAX_CACHED_PMRF, true));
    private final Map<String, List<FsId>> cachedFsIds =
        Collections.synchronizedMap(new LruCache<String, List<FsId>>(MAX_CACHED_FSID_LIST,true));


    private PixelDataType(int cadenceType, String fitsName,
        String pixelMappingKeyword, TargetType targetTableType) {
        this.cadenceType = cadenceType;
        this.fitsName = fitsName;
        this.pixelMappingKeyword = pixelMappingKeyword;
        this.targetTableType = targetTableType;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.ar.exporter.cal.PixelTypeInterface#targetTableType()
	 */
    public TargetType targetTableType() {
        if (targetTableType == null) {
            throw new IllegalArgumentException("Invalid DataType " + this
                + ".");
        }

        return targetTableType;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.ar.exporter.cal.PixelTypeInterface#isCollateral()
	 */
    public boolean isCollateral() {
        return targetTableType == null;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.ar.exporter.cal.PixelTypeInterface#pmrfFits(nom.tam.fits.Fits, gov.nasa.kepler.fs.api.FileStoreClient)
	 */
    public Pair<Fits, String> pmrfFits(Fits pixelExportFits, FileStoreClient fileStore)
        throws FitsException,
        IOException {

        BasicHDU mainHdu = pixelExportFits.getHDU(0);
        String pmrfName = 
            mainHdu.getHeader().getStringValue(pixelMappingKeyword);

        log.debug("Fetching pmrf " + pmrfName);
        if (pmrfCache.containsKey(pmrfName)) {
            Fits cachedPmrf = pmrfCache.get(pmrfName);
            cachedPmrf.getHDU(0);
            return Pair.of(cachedPmrf, pmrfName);
        }

        FsId pmrfId = DrFsIdFactory.getPmrfFile(pmrfName);
        BlobResult pmrfFileData = fileStore.readBlob(pmrfId);
        ByteArrayInputStream pmrfBin = new ByteArrayInputStream(
            pmrfFileData.data());

        Fits pmrfFits = new Fits(pmrfBin);
        pmrfFits.read();
        pmrfCache.put(pmrfName, pmrfFits);

        return Pair.of(pmrfFits, pmrfName);
    }

    /**
     * Gets the data type of the specified cadence log.
     * @param cadenceLog
     * @return
     */
    public static PixelDataType valueOf(PixelLog cadenceLog) {
        String fitsName = cadenceLog.getFitsFilename();
        for (PixelDataType type : PixelDataType.values()) {
            if (fitsName.indexOf(type.fitsName) != -1) {
                return type;
            }
        }
        throw new IllegalArgumentException(
            "CadenceLog does not come from a known pixel data type: \""
                + fitsName + "\".");
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.ar.exporter.cal.PixelTypeInterface#cadenceType()
	 */
    public int cadenceType() {
        return cadenceType;
    }

     /* (non-Javadoc)
	 * @see gov.nasa.kepler.ar.exporter.cal.PixelTypeInterface#pixelIds(gov.nasa.kepler.ar.exporter.cal.OutputFileInfo, int, int, gov.nasa.kepler.ar.exporter.cal.FsIdFactoryType)
	 */
    public List<FsId> pixelIds(OutputFileInfo info, int module, int output, FsIdFactoryType factoryType) 
        throws FitsException, IOException {
        
    	String cachedPixelIdsKey = cachedPixelIdsKey(info, module, output, factoryType);
    	if (this.cachedFsIds.containsKey(cachedPixelIdsKey)) {
    		return this.cachedFsIds.get(cachedPixelIdsKey);
    	}
    	
        BinaryTableHDU mappingTable = findHDU(info.pmrf(), module, output, info.pmrfName());
        
        List<FsId> ids = null;
        if (isCollateral()) {
            byte[] type = (byte[]) mappingTable.getColumn(0);
            short[] offset = (short[]) mappingTable.getColumn(1);
            
            ids = collateralPixelIds(type, offset, module, output, factoryType);
        } else {
            short[] row = (short[]) mappingTable.getColumn(0);
            short[] col = (short[]) mappingTable.getColumn(1);

            ids = visiblePixelIds(row, col, module, output, factoryType);
        }
        
        cachedFsIds.put(cachedPixelIdsKey, ids);
        return ids;
    }
    
    private String cachedPixelIdsKey(OutputFileInfo info, int module,
			int output, FsIdFactoryType factoryType) {

    	StringBuilder bldr = new StringBuilder();
    	bldr.append(info.pmrfName()).append(module).append(output)
    		.append(factoryType.toString());
    	return bldr.toString();
	}

	private List<FsId> collateralPixelIds(byte[] type, short[] offset, 
                                    int module, int output, 
                                    FsIdFactoryType factoryType) 
        throws IOException {
       
        
        List<FsId> ids = new ArrayList<FsId>();
  
        Cadence.CadenceType cadenceType =
            Cadence.CadenceType.valueOf(cadenceType());
        
        CalFsIdFactory.PixelTimeSeriesType pixelTimeSeriesType = null;
        for (int i=0; i < offset.length; i++) {
            FsId nextId = null;
            CollateralType cType = CollateralType.valueOf(type[i]);
            switch (factoryType) {
                case CALIBRATED:
                    pixelTimeSeriesType =
                        CalFsIdFactory.PixelTimeSeriesType.SOC_CAL;
                nextId =
                	CalFsIdFactory.getCalibratedCollateralFsId(cType, 
                			pixelTimeSeriesType, cadenceType, module, output, offset[i]);
                break;
            case ORIG:
                DrFsIdFactory.TimeSeriesType timeSeriesType =
                    DrFsIdFactory.TimeSeriesType.ORIG;
                
                nextId =
                    DrFsIdFactory.getCollateralPixelTimeSeries(timeSeriesType,
                        cadenceType, cType, module, output, offset[i]);
                break;
            case CALIBRATED_UNCERT:
                pixelTimeSeriesType = CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES;
                nextId = CalFsIdFactory.getCalibratedCollateralFsId(cType, pixelTimeSeriesType, 
                    cadenceType, module, output, offset[i]);
                break;
            case COSMIC_RAY:
            	nextId = 
            		CalFsIdFactory.getCosmicRaySeriesFsId(cType, cadenceType, module, output, offset[i]);
            	break;
            default:
                    throw new IllegalStateException("Unhandled case.");
            }
            
            ids.add(nextId);
        }
        
        return ids;
    }
    
    private List<FsId> visiblePixelIds(short[] row, short[] col, int module, int output, 
                                                         FsIdFactoryType factoryType) 
        throws IOException {

        List<FsId> ids = new ArrayList<FsId>();
        for (int i=0; i < row.length; i++) {
            FsId nextId = null;
            switch (factoryType) {
            case CALIBRATED:
                nextId =
                    CalFsIdFactory.getTimeSeriesFsId(
                        CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, targetTableType, 
                        module, output, row[i], col[i]);
                break;
            case ORIG:
                nextId = 
                DrFsIdFactory
                    .getSciencePixelTimeSeries(
                        DrFsIdFactory.TimeSeriesType.ORIG, targetTableType,
                        module, output, row[i], col[i]);
                break;
            case CALIBRATED_UNCERT:
                nextId = CalFsIdFactory.getTimeSeriesFsId(
                    CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES, 
                        targetTableType, module, output, row[i], col[i]);
                 break;
            case COSMIC_RAY:
            	nextId = PaFsIdFactory.getCosmicRaySeriesFsId(targetTableType, 
            			module, output, row[i], col[i]);
            	break;
            default:
                    throw new IllegalStateException("Unhandled case.");
            }
            
             ids.add(nextId);
        }

        return ids;
    }
    
    
    private BinaryTableHDU findHDU(Fits fits, int module, int output, String fileName)
        throws FitsException, IOException {
        
        BinaryTableHDU mappingTable = null;
        for (int i=0; i <= fits.getNumberOfHDUs(); i++) {
            BasicHDU basicHdu = fits.getHDU(i);
            int moduleKw = basicHdu.getHeader().getIntValue(MODULE_KW, -1);
            int outputKw = basicHdu.getHeader().getIntValue(OUTPUT_KW, -1);
            
            if (moduleKw == -1 || outputKw == -1) continue;
            if (output  != outputKw || module != moduleKw) continue;
            
            mappingTable = (BinaryTableHDU) basicHdu;
            break;
        }
        
        if (mappingTable == null) {
            throw new IllegalStateException("Missing HDU for module " +
                module + " output " + output + " for file " + fileName);
        }
        return mappingTable;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.ar.exporter.cal.PixelTypeInterface#update(gov.nasa.kepler.ar.exporter.cal.OutputFileInfo, int, int, java.util.Map, java.util.Map, gov.nasa.kepler.ar.exporter.cal.ProcessingHistoryFile)
	 */
    public void update(OutputFileInfo info, int module, int output,
        Map<FsId, IntTimeSeries> uncalibratedData, 
        Map<FsId, FloatTimeSeries> calibratedData,
        ProcessingHistoryFile historyFile)
    throws FitsException, IOException {
        
    	info.headerOffsets().add(info.output().getFilePointer());
    	
        List<FsId> calibratedIds = pixelIds(info, module, output, CALIBRATED );
        List<FsId> uncalibratedIds = pixelIds(info, module, output, ORIG);
        List<FsId> uncertainIds = pixelIds(info,module,output, CALIBRATED_UNCERT);
        
        int[] uncalCol = new int[calibratedIds.size()];
        int i=0;
        for (FsId ucid : uncalibratedIds) {
            IntTimeSeries uncalSeries = uncalibratedData.get(ucid);
            int cadenceIndex =  info.cadence() - uncalSeries.startCadence();
            uncalCol[i++] = uncalSeries.iseries()[cadenceIndex];
            int originatorIndex = uncalSeries.originatorByCadence(info.cadence());
            if (originatorIndex != -1) {
                historyFile.addTaskId(uncalSeries.originators().get(originatorIndex).tag());
            }
        }
        
        float[] calCol = new float[calibratedIds.size()];
        i=0;
        for (FsId cid : calibratedIds) {
            FloatTimeSeries calSeries =  calibratedData.get(cid);
            int cadenceIndex = info.cadence() - calSeries.startCadence();
            calCol[i++] = calSeries.fseries()[cadenceIndex];
            int originatorIndex = calSeries.originatorByCadence(info.cadence());
            if (originatorIndex != -1) {
                historyFile.addTaskId(calSeries.originators().get(originatorIndex).tag());
            }
        }
        
        float[] ummCol = new float[uncertainIds.size()];
        i=0;
        for (FsId ummId : uncertainIds) {
            FloatTimeSeries ummSeries = calibratedData.get(ummId);
            int cadenceIndex = info.cadence() - ummSeries.startCadence();
            ummCol[i++] = ummSeries.fseries()[cadenceIndex];
            int originatorIndex = ummSeries.originatorByCadence(info.cadence());
            if (originatorIndex != -1) {
                historyFile.addTaskId(ummSeries.originators().get(originatorIndex).tag());
            }
        }

        if (ummCol.length != calCol.length) {
        	throw new PipelineException("ummCol and calCol lengths do not match.");
        }
        if (ummCol.length != uncalCol.length) {
        	throw new PipelineException("ummCol and uncalCol lengths do not match.");
        }
        
        BinaryTableHDU original = 
            (BinaryTableHDU) findHDU(info.headerInfo(), module, output, info.headerFileName());
        
        Header copy = FitsUtils.copyHeader(original.getHeader());
        setCalibratedHeaderFields(copy, ummCol.length);
        info.naxis2().add(ummCol.length);
        FitsUtils.trimHeader(copy);

        BinaryTable newBinTable = 
            new BinaryTable(new Object[] { uncalCol, calCol, ummCol} );
        BinaryTableHDU newHdu = 
            new BinaryTableHDU(copy, newBinTable);
        
        newHdu.write(info.output());
        info.output().flush();

    }
    
    void setCalibratedHeaderFields(Header header, int naxis2) throws HeaderCardException {
        header.addValue(NAXIS1_KW, 12,"");
        header.addValue(TFIELDS_KW, 3, "");
        
        Cursor c = header.iterator();
        while (c.hasNext()) {
            c.next();
        }

        header.addValue(CAL_COL_TYPE_KW, CAL_COL_TYPE_VALUE,"");
        header.addValue(CAL_COL_DISP_KW, CAL_COL_DISP_VALUE,"");
        header.addValue(CAL_COL_FORM_KW, CAL_COL_FORM_VALUE, "");
        header.addValue(CAL_COL_UNIT_KW, CAL_COL_UNIT_VALUE, CAL_COL_UNIT_COMMENT);
        
        header.addValue(UNCERT_COL_DISP_KW, UNCERT_COL_DISP_VALUE, "");
        header.addValue(UNCERT_COL_FORM_KW, UNCERT_COL_FORM_VALUE,"");
        header.addValue(UNCERT_COL_TYPE_KW, UNCERT_COL_TYPE_VALUE, "");
        header.addValue(UNCERT_COL_UNIT_KW, UNCERT_COL_UNIT_VALUE, UNCERT_COL_UNIT_COMMENT);
        
        header.addValue(NAXIS1_KW, 12, "length of first data axis");
        header.addValue(NAXIS2_KW, naxis2, "length of second data axis");
        header.addValue(TFIELDS_KW, 3, "number of fields in each table row");
    }
    
}

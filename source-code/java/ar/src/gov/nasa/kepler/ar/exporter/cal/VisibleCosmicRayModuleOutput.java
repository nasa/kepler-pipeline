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


import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.parseCosmicRaySeriesFsId;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CCD_MODULE;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CCD_OUTPUT;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.COLUMN;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.ROW;
import gnu.trove.TFloatArrayList;
import gnu.trove.TIntArrayList;
import gnu.trove.TShortArrayList;
import gov.nasa.kepler.ar.exporter.cal.TargetAndApertureIdMap.TargetAndApertureId;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.*;

/**
 * The cosmic rays for the visible portion of a  single CCD  module/output.
 * This includes target and background pixels.
 * 
 * @author Sean McCauliff
 *
 */
public class VisibleCosmicRayModuleOutput implements CosmicRayFitsModuleOutput {

    
    //Binary table column names.
    private static final String APERTURE_CN = "aperture_id";
    private static final String TARGET_CN = "target_id";
    private static final String ROW_CN = "row";
    private static final String COL_CN = "column";
    
    private short module;
    private short output;
    private int cadence;
    private double mjd;
    
    private TShortArrayList rows = new TShortArrayList();
    private TShortArrayList cols = new TShortArrayList();
    private TFloatArrayList rays = new TFloatArrayList();
    private TIntArrayList targetIds = new TIntArrayList();
    private TShortArrayList apertureIds = new TShortArrayList();
  
    
    public VisibleCosmicRayModuleOutput(short module, short output, int cadence, double mjd) {
        this.module = module;
        this.output = output;
        this.cadence = cadence;
        this.mjd = mjd;
    }
    
    public short module() { return module; }
    public short output() { return output; }
    private float[] rays() { return rays.toNativeArray(); }
    private int[] targetId() { return targetIds.toNativeArray(); }
    private short[] apertureId() { return apertureIds.toNativeArray(); }
    private short[] rows() { return rows.toNativeArray(); }
    private short[] cols() { return cols.toNativeArray(); }

    
    public BinaryTableHDU  toBinaryTableHdu() throws FitsException {
        Object[] dataCols = new Object[5];
        dataCols[0] = rows();
        dataCols[1] = cols();
        dataCols[2] = rays();
        dataCols[3] = targetId();
        dataCols[4] = apertureId();
        
        BinaryTable fitsBinaryData = (BinaryTable) BinaryTableHDU.encapsulate(dataCols);
        @SuppressWarnings("deprecation")
        Header binaryTableHeader = FitsUtils.manufactureBinaryTableHeader(fitsBinaryData);
        binaryTableHeader.addValue(TIMESYS_KW, TIMESYS_VALUE, TIMESYS_COMMENT);
        binaryTableHeader.addValue(MODULE_KW, module, "CCD module");
        binaryTableHeader.addValue(OUTPUT_KW, output, "CCD output");
        binaryTableHeader.addValue(CHANNEL_KW, FcConstants.getChannelNumber(module, output), "CCD channel");
        binaryTableHeader.addValue("TTYPE1", ROW_CN,"");
        binaryTableHeader.addValue("TFORM1", "1I","");
        binaryTableHeader.addValue("TDISP1", "I4.1","");
        binaryTableHeader.addValue("TUNIT1", "pixels","");
        binaryTableHeader.addValue("TTYPE2", COL_CN,"");
        binaryTableHeader.addValue("TFORM2", "1I","");
        binaryTableHeader.addValue("TDISP2", "I4.1","");
        binaryTableHeader.addValue("TUNIT2", "pixels","");
        binaryTableHeader.addValue("TTYPE3", correction_CN,"");
        binaryTableHeader.addValue("TFORM3", "1E","");
        binaryTableHeader.addValue("TDISP3", "F16.3","");
        binaryTableHeader.addValue("TUNIT3", "ADU","");
        binaryTableHeader.addValue("TTYPE4", TARGET_CN,"");
        binaryTableHeader.addValue("TFORM4", "1J","");
        binaryTableHeader.addValue("TDISP4", "I10","");
        binaryTableHeader.addValue("TTYPE5", APERTURE_CN,"");
        binaryTableHeader.addValue("TFORM5", "1I","");
        binaryTableHeader.addValue("TDISP5", "I5","");
        BinaryTableHDU binaryTableHDU = 
            new BinaryTableHDU( binaryTableHeader, fitsBinaryData);
        return binaryTableHDU;
    }
        
        
    /**
     * 
     * @param cosmicRays
     * @param targetIdMap Map of (row,col)->(targetid,apertureid)
     * @throws PipelineException
     */
    void addPixels(Set<FloatMjdTimeSeries> cosmicRays, 
            TargetAndApertureIdMap targetIdMap, ProcessingHistoryFile processingHistory) {
        
        for (FloatMjdTimeSeries raysSeries : cosmicRays) {
            if (CalFsIdFactory.isCosmicRaySeriesFsId(raysSeries.id())) {
                continue; //collateral.
            }
            
            Map<String,Object> seriesFsIdParts = 
                PaFsIdFactory.parseCosmicRaySeriesFsId(raysSeries.id());
            TargetType ttype = (TargetType) seriesFsIdParts.get(PaFsIdFactory.TARGET_TABLE_TYPE);
            boolean isBackground = ttype == TargetType.BACKGROUND;
            double[] raysMjd = raysSeries.mjd();
            int index = Arrays.binarySearch(raysMjd, mjd);
            if (index < 0) {
                throw new IllegalArgumentException("Mjd not found in cosmic" +
                        " ray set for FsId \"" + raysSeries.id() + "\".");
            }
            
            processingHistory.addTaskId(raysSeries.originators()[index]);
            addSingleEntry(raysSeries.id(), isBackground, raysSeries.values()[index], targetIdMap);
        }
    }
    
    private void addSingleEntry(FsId rayId, boolean isBackground,
        float rayValue, TargetAndApertureIdMap targetIdMap)
        {
        
        Map<String, Object> parameters = parseCosmicRaySeriesFsId(rayId);
        int id_module = (Integer) parameters.get(CCD_MODULE);
        int id_output = (Integer) parameters.get(CCD_OUTPUT);
        if (id_module != module) {
            throw new IllegalArgumentException("pixel's module " +
                id_module + " does not match this.module " + module + ".");
        }
        
        if (id_output != output) {
            throw new IllegalArgumentException("pixel's output " + id_output +
                " does not match this.output " + output + ".");
        }
        
        short row =  (short) ((Integer) parameters.get(ROW)).intValue();
        short col = (short) ((Integer) parameters.get(COLUMN)).intValue();
        TargetAndApertureId  targetAndApertureId = 
            targetIdMap.find(module, isBackground, output, row,  col);
        
        if (targetAndApertureId == null) {
            //Pixel id is for someone else's pmrf, e.g. target when this background
            return;
        }
     
        rows.add(row);
        cols.add( col);
        rays.add(rayValue);
        targetIds.add(targetAndApertureId.targetId);
        apertureIds.add(targetAndApertureId.apertureId);

    }
        
    public void fromBinaryTableHdu(BinaryTableHDU dataHDU) throws FitsException {
        Header dataHeader =dataHDU.getHeader();

        output = (short)dataHeader.getIntValue(OUTPUT_KW);
        module = (short)dataHeader.getIntValue(MODULE_KW);
      
        rows = new TShortArrayList((short[]) dataHDU.getColumn(ROW_CN));
        cols = new TShortArrayList((short[]) dataHDU.getColumn(COL_CN));
        rays = new TFloatArrayList((float[]) dataHDU.getColumn("cr_corr_value"));
        targetIds = new TIntArrayList((int[]) dataHDU.getColumn(TARGET_CN));
        apertureIds = new TShortArrayList((short[]) dataHDU.getColumn(APERTURE_CN));
    }
        
    @Override
    public boolean equals(Object o) {
        if (o == null) return false;
        if (this == o) return true;
        if (this.getClass() != o.getClass()) {
            return false;
        }
        VisibleCosmicRayModuleOutput other = (VisibleCosmicRayModuleOutput) o;
        if (this.output != other.output) return false;
        if (this.module != other.module) return false;
        if (this.mjd != other.mjd) return false;
        if (this.cadence != other.cadence) return false;
        
        if (!this.rays.equals(other.rays)) return false;
        if (!this.rows.equals(other.rows)) return false;
        if (!this.cols.equals(other.cols)) return false;
        if (!this.targetIds.equals(other.targetIds)) return false;
        if (!this.apertureIds.equals(other.apertureIds)) return false;
        

        return true;
    }
        
    @Override
    public int hashCode() {
        int code = (module << 16) | output;
        long mjdBits = Double.doubleToLongBits(mjd);
        code = code ^ ((int) (mjdBits >>> 32) | (int) (mjdBits & 0x00000000FFFFFFFFL));
        code = code ^ cadence;
        code = code ^ rays.hashCode();
        code = code ^ rows.hashCode();
        code = code ^ cols.hashCode();
        code = code ^ targetIds.hashCode();
        code = code ^ apertureIds.hashCode();
        
        return code;
    }

}

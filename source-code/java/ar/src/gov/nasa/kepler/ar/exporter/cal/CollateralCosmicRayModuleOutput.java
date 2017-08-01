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

import static gov.nasa.kepler.mc.fs.CalFsIdFactory.parseCosmicRaySeriesFsId;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CCD_MODULE;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.CCD_OUTPUT;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.COLLATERAL_TYPE;
import static gov.nasa.kepler.mc.fs.PixelFsIdFactory.OFFSET;
import gnu.trove.TByteArrayList;
import gnu.trove.TFloatArrayList;
import gnu.trove.TShortArrayList;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FitsUtils;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Arrays;
import java.util.Map;
import java.util.Set;

import nom.tam.fits.*;



/**
 * The collateral cosmic ray format is different from the visible pixel format.
 * See the collateral pixel mapping reference files for why this is the case.
 * 
 * @author Sean McCauliff
 *
 */
public class CollateralCosmicRayModuleOutput implements CosmicRayFitsModuleOutput {

    private static final String TYPE_CN = "col_pixel_type";
    private static final String OFFSET_CN = "offset";
    private short module;
    private short output;
    private int cadence;
    private double mjd;
    
    private TByteArrayList types = new TByteArrayList();
    private TShortArrayList offsets = new TShortArrayList();
    private TFloatArrayList rays = new TFloatArrayList();
    
    /**
     */
    public CollateralCosmicRayModuleOutput(short module, short output,
        int cadence, double mjd) {
        this.module = module;
        this.output = output;
        this.cadence = cadence;
        this.mjd = mjd;
    }   

    private byte[] types() { return types.toNativeArray(); }
    private short[] offsets() { return offsets.toNativeArray(); }
    private float[] rays() { return rays.toNativeArray(); }
    public short module() { return module; }
    public short output() { return output; }
    
    
    /**
     * 
     * @param rays
     * @throws PipelineException
     */
    public synchronized void addCollateralPixels(Set<FloatMjdTimeSeries> rays, 
        ProcessingHistoryFile processingHistory) 
        {
        
        for (FloatMjdTimeSeries raySeries : rays) {
            if (!CalFsIdFactory.isCosmicRaySeriesFsId(raySeries.id())) {
                continue;  //visible
            }
            int index = Arrays.binarySearch(raySeries.mjd(), mjd);
            if (index < 0) {
                throw new IllegalArgumentException("Missing cosmic ray data" +
                        " point in \"" + raySeries.id() + "\".");
            }
            
            processingHistory.addTaskId(raySeries.originators()[index]);
            addSinglePixel(raySeries.id(), raySeries.values()[index]);
        }
    }
    
    private void addSinglePixel(FsId id, float rayValue) {
        Map<String, Object> parameters = parseCosmicRaySeriesFsId(id);
        int id_module = (Integer) parameters.get(CCD_MODULE);
        int id_output = (Integer) parameters.get(CCD_OUTPUT);
        if (id_module != module) {
            throw new IllegalArgumentException("Pixel's module " + id_module 
                + " not equal to this module " + module + ".");
        }
        if (id_output != output) {
            throw new IllegalArgumentException("Pixel's output " + id_output 
                + " not equal to this output " + output + ".");
        }
        
        int offset = (Integer) parameters.get(OFFSET);
        
        CollateralType cType = (CollateralType) parameters.get(COLLATERAL_TYPE);
        types.add(cType.byteValue());
        offsets.add((short) offset);
        rays.add(rayValue);
    }

   public BinaryTableHDU toBinaryTableHdu() throws FitsException {
        Object[] dataCols = new Object[3];
        dataCols[0] = types();
        dataCols[1] = offsets();
        dataCols[2] = rays();
        
        BinaryTable fitsBinaryData =
            (BinaryTable) BinaryTableHDU.encapsulate(dataCols);
        @SuppressWarnings("deprecation")
        Header binaryTableHeader = FitsUtils.manufactureBinaryTableHeader(fitsBinaryData);
        binaryTableHeader.insertComment("Extension parameters");
        binaryTableHeader.addValue(TIMESYS_KW, TIMESYS_VALUE, TIMESYS_COMMENT);
        binaryTableHeader.addValue(MODULE_KW, module, "CCD module");
        binaryTableHeader.addValue(OUTPUT_KW, output, "CCD output");
        binaryTableHeader.addValue(CHANNEL_KW, FcConstants.getChannelNumber(module, output), "CCD channel");
        binaryTableHeader.insertComment("Binary table parameters.");
        binaryTableHeader.addValue("TTYPE1", TYPE_CN,"");
        binaryTableHeader.addValue("TFORM1", "B","");
        binaryTableHeader.addValue("TDISP1", "I2","");
        binaryTableHeader.addValue("TUNIT1", "enum","");
        binaryTableHeader.addValue("TTYPE2", OFFSET_CN,"");
        binaryTableHeader.addValue("TFORM2", "1I","");
        binaryTableHeader.addValue("TDISP2", "I4.1","");
        binaryTableHeader.addValue("TUNIT2", "pixels","");
        binaryTableHeader.addValue("TTYPE3", correction_CN,"");
        binaryTableHeader.addValue("TFORM3", "1E","");
        binaryTableHeader.addValue("TDISP3", "F16.3","");
        
        BinaryTableHDU binaryTableHDU =
            new BinaryTableHDU(binaryTableHeader, fitsBinaryData);
        return binaryTableHDU;
    }
        
   public void fromBinaryTableHdu(BinaryTableHDU dataHDU) throws FitsException {
        Header dataHeader =dataHDU.getHeader();

        output = (short)dataHeader.getIntValue(OUTPUT_KW);
        module = (short)dataHeader.getIntValue(MODULE_KW);
      
        types = new TByteArrayList((byte[]) dataHDU.getColumn(TYPE_CN));
        offsets = new TShortArrayList((short[]) dataHDU.getColumn(OFFSET_CN));
        rays = new TFloatArrayList((float[]) dataHDU.getColumn(correction_CN));
        
        if (types.size() != offsets.size()) {
            throw new IllegalArgumentException("types column must be same length as offsets column");
        }
        if (offsets.size() != rays.size()) {
            throw new IllegalArgumentException("rays column must be same length as offsets column");
        }
        
        //Check all collateral types.
        for (int i=0; i < types.size(); i++) {
            byte t = types.get(i);
            CollateralType.valueOf(t);
        }

    }
        
    @Override
    public boolean equals(Object o) {
        if (o == null) return false;
        if (this == o) return true;
        if (!(o instanceof CollateralCosmicRayModuleOutput)) {
            return false;
        }
        
        CollateralCosmicRayModuleOutput other = (CollateralCosmicRayModuleOutput) o;
        
        if (this.module != other.module) return false;
        if (this.output != other.output) return false;
        if (this.cadence != other.cadence) return false;
        if (this.mjd != other.mjd) return false;
        
        if (!this.rays.equals(other.rays)) return false;
        if (!this.offsets.equals(other.offsets)) return false;
        if (!this.types.equals(other.types)) return false;
        
        
        return true;
    }
    
    @Override
    public int hashCode() {
        int code = (module << 16) | output;
        code = code ^ cadence;
        long mjdBits = Double.doubleToLongBits(mjd);
        code = code ^ ((int) (mjdBits >>> 32));
        code = code ^ ((int) (mjdBits & 0x00000000FFFFFFFFL));
        code = code ^ rays.hashCode();
        code = code ^ types.hashCode();
        code = code ^ offsets.hashCode();
        
        return code;
    }


}

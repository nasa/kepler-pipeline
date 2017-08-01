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

package gov.nasa.kepler.ar.archive;


import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Collections;
import java.util.List;

/**
 * The inputs into the Matlab controller for the matlab archive process.  These
 * inputs are in common for all computations.
 * 
 * @author Sean McCauliff
 *
 */
public final class ArchiveInputs implements Persistable {

    public static final String FFI_CADENCE_TYPE = "FFI";
    
    /** This is a Human readable description about the intent of the caller.
     */
    @SuppressWarnings("unused")
    private String callComments;
    private boolean debugFlag = false;
    @SuppressWarnings("unused")
    private boolean unpackBackgroundBlob = false;
    private String cadenceType;
    private int ccdModule;
    private int ccdOutput;
    private List<gov.nasa.kepler.common.ConfigMap> configMaps =
        Collections.emptyList();
    
    @SuppressWarnings("unused")
    private FcConstants fcConstants = new FcConstants();
    @SuppressWarnings("unused")
    private BlobFileSeries motionPolyBlobs = new BlobFileSeries();
    @SuppressWarnings("unused")
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();
    private TimestampSeries cadenceTimesStruct;
    private TimestampSeries longCadenceTimesStruct;
    private BackgroundInputs backgroundInputs = new BackgroundInputs();
    private BarycentricInputs barycentricInputs = new BarycentricInputs();
    @SuppressWarnings("unused")
    private WcsInputs wcsInputs = new WcsInputs();
    @SuppressWarnings("unused")
    private DvaInputs dvaInputs = new DvaInputs();
    @SuppressWarnings("unused")
    private SipWcsInputs sipWcsInputs = new SipWcsInputs();
    
    @SuppressWarnings("unused")
    private FfiBarycentricCorrectionInputs ffiBarycentricCorrectionInputs = new FfiBarycentricCorrectionInputs();
    
    @SuppressWarnings("unused")
    private BlobFileSeries cotrendingBasisVectorBlobs = new BlobFileSeries();

    @SuppressWarnings("unused")
    private boolean unpackCbvBlob = false;
    
    /**
     * For Persistable interface.
     */
    public ArchiveInputs() {
        
    }
    
    private ArchiveInputs(
        String callComments,
        String cadenceType, int ccdModule,
        int ccdOutput, 
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        BlobSeries<String> motionPolyBlobSeries,
        RaDec2PixModel raDec2PixModel) {
        
        this.callComments = callComments;
        this.motionPolyBlobs = new BlobFileSeries(motionPolyBlobSeries);
        this.raDec2PixModel = raDec2PixModel;
        this.cadenceType = cadenceType;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.cadenceTimesStruct = cadenceTimesStruct;
        this.configMaps = configMaps;
        this.longCadenceTimesStruct = longCadenceTimesStruct;
       
    }
    
    /**
     * Unpack the co-trending basis vector blobs.
     */
    public ArchiveInputs(BlobFileSeries cbvBlobSeries, TimestampSeries cadenceTimes) {
        this.cotrendingBasisVectorBlobs = cbvBlobSeries;
        this.unpackCbvBlob = true;
        this.cadenceType = CadenceType.LONG.toString();
        this.callComments = "Unpack co-trending basis vectors.";
        this.cadenceTimesStruct = cadenceTimes;
        this.longCadenceTimesStruct = cadenceTimes;
    }
    
    /**
     * Unpack the background blob file in backgroundInputsForUnpacking.
     * 
     * @param backgroundInputsForUnpacking
     * @param ccdModule
     * @param ccdOutput
     */
    public ArchiveInputs(BackgroundInputs backgroundInputsForUnpacking,
        int ccdModule, int ccdOutput) {
        
        this.configMaps = Collections.emptyList();
        this.cadenceTimesStruct = new TimestampSeries();
        this.longCadenceTimesStruct = new TimestampSeries();
        this.motionPolyBlobs = new BlobFileSeries();
        this.raDec2PixModel = new RaDec2PixModel();
        this.barycentricInputs = new BarycentricInputs();
        this.backgroundInputs = backgroundInputsForUnpacking;
        this.dvaInputs = new DvaInputs();
        this.wcsInputs = new WcsInputs();
        
        callComments = "unpack background blob";
        this.unpackBackgroundBlob = true;
        this.cadenceType = CadenceType.LONG.name();
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }
    
    
    /**
     * WCS inputs.
     * @param callComments
     * @param cadenceType
     * @param ccdModule
     * @param ccdOutput
     * @param configMaps
     * @param cadenceTimesStruct
     * @param longCadenceTimesStruct
     * @param motionPolyBlobSeries
     * @param raDec2PixModel
     * @param wcsInputs
     */
    public ArchiveInputs(String callComments,
        String cadenceType, int ccdModule,
        int ccdOutput, 
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        BlobSeries<String> motionPolyBlobSeries,
        RaDec2PixModel raDec2PixModel,
        WcsInputs wcsInputs) {
        
        this(callComments, cadenceType, ccdModule, ccdOutput,
            configMaps, cadenceTimesStruct, longCadenceTimesStruct,
            motionPolyBlobSeries, raDec2PixModel);
        
        this.wcsInputs = wcsInputs;
    }
    
    /**
     * SIP WCS inputs.
     */
    public ArchiveInputs(String callComments,
        String cadenceType, int ccdModule, int ccdOutput,
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        BlobSeries<String> motionPolyBlobSeries,
        SipWcsInputs sipWcsInputs) {
        
        this(callComments, cadenceType, ccdModule, ccdOutput,
             configMaps, cadenceTimesStruct, longCadenceTimesStruct,
             motionPolyBlobSeries, new RaDec2PixModel());
        
        this.sipWcsInputs = sipWcsInputs;
        
    }
    
    /**
     * Barycentric correction inputs.
     * 
     * @param callComments
     * @param cadenceType
     * @param ccdModule
     * @param ccdOutput
     * @param configMaps
     * @param cadenceTimesStruct
     * @param longCadenceTimesStruct
     * @param motionPolyBlobSeries
     * @param raDec2PixModel
     * @param barycentricInputs
     */
    public ArchiveInputs(String callComments,
        String cadenceType, int ccdModule,
        int ccdOutput, 
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        BlobSeries<String> motionPolyBlobSeries,
        RaDec2PixModel raDec2PixModel,
        BarycentricInputs barycentricInputs) {
        
        this(callComments, cadenceType, ccdModule, ccdOutput,
            configMaps, cadenceTimesStruct, longCadenceTimesStruct,
            motionPolyBlobSeries, raDec2PixModel);
        
        this.barycentricInputs = barycentricInputs;
    }
    
    /**
     * FFI barycentric correction inputs.
     */
    public ArchiveInputs(String callComments, int ccdModule, int ccdOutput,
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        RaDec2PixModel raDec2PixModel,
        FfiBarycentricCorrectionInputs ffiBcInputs) {
        
        this.callComments = callComments;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.configMaps = configMaps;
        this.cadenceTimesStruct = cadenceTimesStruct;
        this.longCadenceTimesStruct = longCadenceTimesStruct;
        this.raDec2PixModel = raDec2PixModel;
        this.ffiBarycentricCorrectionInputs = ffiBcInputs;
        this.cadenceType = FFI_CADENCE_TYPE;
    }
    
    /**
     *  Everything that FFI needs to do .
     *
     */
    public ArchiveInputs(String callComments, int ccdModule, int ccdOutput,
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        RaDec2PixModel raDec2PixModel,
        BlobSeries<String> motionPolyBlobSeries,
        FfiBarycentricCorrectionInputs ffiBcInputs,
        SipWcsInputs sipWcsInputs) {
        
        this.callComments = callComments;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.configMaps = configMaps;
        this.cadenceTimesStruct = cadenceTimesStruct;
        this.longCadenceTimesStruct = longCadenceTimesStruct;
        this.raDec2PixModel = raDec2PixModel;
        this.ffiBarycentricCorrectionInputs = ffiBcInputs;
        this.cadenceType = FFI_CADENCE_TYPE;
        this.motionPolyBlobs = new BlobFileSeries(motionPolyBlobSeries);
        this.sipWcsInputs = sipWcsInputs;
    }

    /**
     * Calculate per pixel background estimates from background polynomials.
     * 
     * @param callComments
     * @param cadenceType
     * @param ccdModule
     * @param ccdOutput
     * @param configMaps
     * @param cadenceTimesStruct
     * @param longCadenceTimesStruct
     * @param motionPolyBlobSeries
     * @param raDec2PixModel
     * @param backgroundInputs
     */
    public ArchiveInputs(String callComments,
        String cadenceType, int ccdModule,
        int ccdOutput, 
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        BlobSeries<String> motionPolyBlobSeries,
        RaDec2PixModel raDec2PixModel,
        BackgroundInputs backgroundInputs) {
        
        this(callComments, cadenceType, ccdModule, ccdOutput,
            configMaps, cadenceTimesStruct, longCadenceTimesStruct,
            motionPolyBlobSeries, raDec2PixModel);
        
        this.backgroundInputs =  backgroundInputs;

    }
    
    /**
     * Calculate targets' DVA motion.
     * 
     * @param callComments
     * @param cadenceType
     * @param ccdModule
     * @param ccdOutput
     * @param configMaps
     * @param cadenceTimesStruct
     * @param longCadenceTimesStruct
     * @param motionPolyBlobSeries
     * @param raDec2PixModel
     * @param dvaInputs
     */
    public ArchiveInputs(String callComments,
        String cadenceType, int ccdModule,
        int ccdOutput, 
        List<gov.nasa.kepler.common.ConfigMap> configMaps,
        TimestampSeries cadenceTimesStruct,
        TimestampSeries longCadenceTimesStruct,
        BlobSeries<String> motionPolyBlobSeries,
        RaDec2PixModel raDec2PixModel,
        DvaInputs dvaInputs) {
        
        this(callComments, cadenceType, ccdModule, ccdOutput,
            configMaps, cadenceTimesStruct, longCadenceTimesStruct,
            motionPolyBlobSeries, raDec2PixModel);
        
        this.dvaInputs = dvaInputs;
    }
    
    public BackgroundInputs getBackgroundInputs() {
        return backgroundInputs;
    }
    
    public boolean isDebugFlag() {
        return debugFlag;
    }

    public String getCadenceType() {
        return cadenceType;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public List<gov.nasa.kepler.common.ConfigMap> getConfigMaps() {
        return configMaps;
    }

    public TimestampSeries getCadenceTimesStruct() {
        return cadenceTimesStruct;
    }
    
    public TimestampSeries getLongCadenceTimesStruct() {
        return longCadenceTimesStruct;
    }

    public BarycentricInputs getBarycentricInputs() {
        return barycentricInputs;
    }

}

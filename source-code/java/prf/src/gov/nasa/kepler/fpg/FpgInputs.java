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

package gov.nasa.kepler.fpg;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

/**
 * @author Sean McCauliff
 * 
 */
@ProxyIgnoreStatics
public class FpgInputs implements Persistable {

    /**
     * 0 - initial
     * 1 - use BlobFileSeries.
     */
    private int version = 1;

    private boolean debug = false;

    private FcConstants fcConstants = new FcConstants();

    private TimestampSeries timestampSeries;

    private FpgModuleParameters fpgModuleParameters;

    private RaDec2PixModel raDec2PixModel;
    private BlobFileSeries[] motionBlobsStruct;

    private String geometryBlobFileName;

    public FpgInputs(TimestampSeries timestampSeries,
        FpgModuleParameters fpgModuleParameters, RaDec2PixModel raDec2PixModel,
        BlobFileSeries[] motionBlobsStruct, String geometryBlobFileName) {

        this.timestampSeries = timestampSeries;
        this.fpgModuleParameters = fpgModuleParameters;
        this.raDec2PixModel = raDec2PixModel;
        this.motionBlobsStruct = motionBlobsStruct;
        this.geometryBlobFileName = geometryBlobFileName;
    }

    public int getVersion() {
        return version;
    }

    public boolean isDebug() {
        return debug;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public TimestampSeries getTimestampSeries() {
        return timestampSeries;
    }

    public FpgModuleParameters getFpgModuleParameters() {
        return fpgModuleParameters;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public BlobFileSeries[] getMotionBlobsStruct() {
        return motionBlobsStruct;
    }

    public String getGeometryBlobFileName() {
        return geometryBlobFileName;
    }

}

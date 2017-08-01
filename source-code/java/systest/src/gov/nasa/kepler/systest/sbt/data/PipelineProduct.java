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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;

/**
 * Represents a pipeline product.
 * 
 * @author Miles Cote
 * 
 */
public enum PipelineProduct {

    CAL(CalFsIdFactory.CAL_PATH, true, null),
    PA(PaFsIdFactory.PA_PATH, true, null),
    PDC(PdcFsIdFactory.PDC_PATH, true, null),
    TPS(TpsFsIdFactory.TPS_PATH, true, null),
    DV(DvFsIdFactory.DV_PATH, true, null),
    PPA(PpaFsIdFactory.PPA_PATH_PREFIX, true, null),
    DR(DrFsIdFactory.DR_PATH, false, null),
    BACKGROUND_BLOBS(PaFsIdFactory.PA_PATH
        + BlobSeriesType.BACKGROUND.getName(), false, BlobSeriesType.BACKGROUND),
    MOTION_BLOBS(PaFsIdFactory.PA_PATH + BlobSeriesType.MOTION.getName(),
        false,
        BlobSeriesType.MOTION),
    ANCILLARY(null, false, null);

    private final String fsIdPath;
    private final boolean pipelineModule;
    private final BlobSeriesType blobSeriesType;

    private PipelineProduct(String fsIdPath, boolean pipelineModule,
        BlobSeriesType blobSeriesType) {
        this.fsIdPath = fsIdPath;
        this.pipelineModule = pipelineModule;
        this.blobSeriesType = blobSeriesType;
    }

    public String getFsIdPath() {
        return fsIdPath;
    }

    public boolean isPipelineModule() {
        return pipelineModule;
    }

    public BlobSeriesType getBlobSeriesType() {
        return blobSeriesType;
    }

}

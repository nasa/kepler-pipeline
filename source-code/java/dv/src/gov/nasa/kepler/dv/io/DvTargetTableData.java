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

package gov.nasa.kepler.dv.io;

import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.intervals.BlobFileSeries;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * Non-target specific data for a target table.
 * 
 * @author Forrest Girouard
 */
public class DvTargetTableData extends DvAbstractTargetTableData {

    private List<AncillaryPipelineData> ancillaryPipelineDataStruct = new ArrayList<AncillaryPipelineData>();
    private int[] argabrighteningIndices = ArrayUtils.EMPTY_INT_ARRAY;
    private BlobFileSeries backgroundBlobs = new BlobFileSeries();
    private BlobFileSeries cbvBlobs = new BlobFileSeries();
    private BlobFileSeries motionBlobs = new BlobFileSeries();

    /**
     * Creates a {@link DvTargetTableData}. For use only by mock objects and
     * Hibernate.
     */
    public DvTargetTableData() {
    }

    /**
     * Creates a new immutable {@link DvTargetData} object.
     */
    public DvTargetTableData(int targetTableId, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, int quarter,
        List<AncillaryPipelineData> ancillaryPipelineData,
        int[] argabrighteningIndices, BlobFileSeries backgroundBlobs,
        BlobFileSeries cbvBlobs, BlobFileSeries motionBlobs) {

        super(targetTableId, ccdModule, ccdOutput, startCadence, endCadence,
            quarter);
        this.argabrighteningIndices = argabrighteningIndices;
        ancillaryPipelineDataStruct = ancillaryPipelineData;
        this.backgroundBlobs = backgroundBlobs;
        this.cbvBlobs = cbvBlobs;
        this.motionBlobs = motionBlobs;
    }

    public List<AncillaryPipelineData> getAncillaryPipelineData() {
        return ancillaryPipelineDataStruct;
    }

    public int[] getArgabrighteningIndices() {
        return argabrighteningIndices;
    }

    public BlobFileSeries getBackgroundBlobs() {
        return backgroundBlobs;
    }

    public BlobFileSeries getCbvBlobs() {
        return cbvBlobs;
    }

    public BlobFileSeries getMotionBlobs() {
        return motionBlobs;
    }
}

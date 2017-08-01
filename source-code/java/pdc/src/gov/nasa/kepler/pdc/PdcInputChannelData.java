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

package gov.nasa.kepler.pdc;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * PDC per-channel inputs.
 * 
 * @author Bill Wohler
 */
public class PdcInputChannelData implements Persistable {

    /**
     * The CCD module.
     */
    private int ccdModule;

    /**
     * The CCD output.
     */
    private int ccdOutput;

    /**
     * Contains the ancillary pipeline data for the mnemonics specified in the
     * {@code AncillaryPipelineParameters}.
     */
    private List<AncillaryPipelineData> ancillaryPipelineDataStruct = newArrayList();

    /**
     * Blobs containing co-trending basis vectors.
     */
    private BlobFileSeries cbvBlobs = new BlobFileSeries();

    /**
     * Blobs containing motion polynomials.
     */
    private BlobFileSeries motionBlobs = new BlobFileSeries();

    /**
     * Blobs containing MAP info. Empty for LC.
     */
    private BlobFileSeries pdcBlobs = new BlobFileSeries();

    /**
     * Target flux to be corrected.
     */
    private List<PdcTarget> targetDataStruct = newArrayList();

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public List<AncillaryPipelineData> getAncillaryPipelineData() {
        return ancillaryPipelineDataStruct;
    }

    public void setAncillaryPipelineData(
        List<AncillaryPipelineData> ancillaryPipelineData) {
        this.ancillaryPipelineDataStruct = ancillaryPipelineData;
    }

    public BlobFileSeries getCbvBlobs() {
        return cbvBlobs;
    }

    public void setCbvBlobs(BlobFileSeries cbvBlobs) {
        this.cbvBlobs = cbvBlobs;
    }

    public BlobFileSeries getMotionBlobs() {
        return motionBlobs;
    }

    public void setMotionBlobs(BlobFileSeries motionBlobs) {
        this.motionBlobs = motionBlobs;
    }

    public BlobFileSeries getPdcBlobs() {
        return pdcBlobs;
    }

    public void setPdcBlobs(BlobFileSeries pdcBlobs) {
        this.pdcBlobs = pdcBlobs;
    }

    public List<PdcTarget> getTargetData() {
        return targetDataStruct;
    }

    public void setTargetData(List<PdcTarget> targetData) {
        this.targetDataStruct = targetData;
    }
}

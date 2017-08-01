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

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * This class contains a series of {@link SbtBlob}s.
 * 
 * @author Miles Cote
 * 
 */
public class SbtBlobSeries implements SbtDataContainer {

    private String blobType = "";

    private int[] blobIndices = ArrayUtils.EMPTY_INT_ARRAY;
    private boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    private String cadenceType = "";
    private int startCadence;
    private int endCadence;

    private List<SbtBlob> blobs = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        SbtGapIndicators gapIndicators = new SbtGapIndicators(
            this.gapIndicators);
        SbtList blobIndices = new SbtList(
            SbtDataContainerListFactory.getInstance(this.blobIndices),
            gapIndicators);

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("blobType", new SbtString(
            blobType).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("gapIndicators",
            gapIndicators.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("blobIndices",
            blobIndices.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("cadenceType",
            new SbtString(cadenceType).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startCadence",
            new SbtNumber(startCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endCadence", new SbtNumber(
            endCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("blobs",
            new SbtList(blobs).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtBlobSeries() {
    }

    public SbtBlobSeries(String blobType, int[] blobIndices,
        boolean[] gapIndicators, String cadenceType, int startCadence,
        int endCadence, List<SbtBlob> blobs) {
        this.blobType = blobType;
        this.blobIndices = blobIndices;
        this.gapIndicators = gapIndicators;
        this.cadenceType = cadenceType;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.blobs = blobs;
    }

    public String getBlobType() {
        return blobType;
    }

    public void setBlobType(String blobType) {
        this.blobType = blobType;
    }

    public int[] getBlobIndices() {
        return blobIndices;
    }

    public void setBlobIndices(int[] blobIndices) {
        this.blobIndices = blobIndices;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public void setGapIndicators(boolean[] gapIndicators) {
        this.gapIndicators = gapIndicators;
    }

    public String getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(String cadenceType) {
        this.cadenceType = cadenceType;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public List<SbtBlob> getBlobs() {
        return blobs;
    }

    public void setBlobs(List<SbtBlob> blobs) {
        this.blobs = blobs;
    }

}

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

import gov.nasa.kepler.hibernate.dv.DvCentroidOffsets;

/**
 * This class contains centroid offsets.
 * 
 * @author Miles Cote
 * 
 */
public class SbtCentroidOffsets implements SbtDataContainer {

    private SbtQuantity columnOffset = new SbtQuantity();
    private SbtQuantity decOffset = new SbtQuantity();
    private SbtQuantity focalPlaneOffset = new SbtQuantity();
    private SbtQuantity raOffset = new SbtQuantity();
    private SbtQuantity rowOffset = new SbtQuantity();
    private SbtQuantity skyOffset = new SbtQuantity();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("columnOffset",
            columnOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("decOffset",
            decOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("focalPlaneOffset",
            focalPlaneOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("raOffset",
            raOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("rowOffset",
            rowOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("skyOffset",
            skyOffset.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtCentroidOffsets(DvCentroidOffsets dvCentroidOffsets) {
        columnOffset = new SbtQuantity(dvCentroidOffsets.getColumnOffset());
        decOffset = new SbtQuantity(dvCentroidOffsets.getDecOffset());
        focalPlaneOffset = new SbtQuantity(
            dvCentroidOffsets.getFocalPlaneOffset());
        raOffset = new SbtQuantity(dvCentroidOffsets.getRaOffset());
        rowOffset = new SbtQuantity(dvCentroidOffsets.getRowOffset());
        skyOffset = new SbtQuantity(dvCentroidOffsets.getSkyOffset());
    }

    public SbtCentroidOffsets() {
    }

    public SbtCentroidOffsets(SbtQuantity columnOffset, SbtQuantity decOffset,
        SbtQuantity focalPlaneOffset, SbtQuantity raOffset,
        SbtQuantity rowOffset, SbtQuantity skyOffset) {
        this.columnOffset = columnOffset;
        this.decOffset = decOffset;
        this.focalPlaneOffset = focalPlaneOffset;
        this.raOffset = raOffset;
        this.rowOffset = rowOffset;
        this.skyOffset = skyOffset;
    }

    public SbtQuantity getColumnOffset() {
        return columnOffset;
    }

    public void setColumnOffset(SbtQuantity columnOffset) {
        this.columnOffset = columnOffset;
    }

    public SbtQuantity getDecOffset() {
        return decOffset;
    }

    public void setDecOffset(SbtQuantity decOffset) {
        this.decOffset = decOffset;
    }

    public SbtQuantity getFocalPlaneOffset() {
        return focalPlaneOffset;
    }

    public void setFocalPlaneOffset(SbtQuantity focalPlaneOffset) {
        this.focalPlaneOffset = focalPlaneOffset;
    }

    public SbtQuantity getRaOffset() {
        return raOffset;
    }

    public void setRaOffset(SbtQuantity raOffset) {
        this.raOffset = raOffset;
    }

    public SbtQuantity getRowOffset() {
        return rowOffset;
    }

    public void setRowOffset(SbtQuantity rowOffset) {
        this.rowOffset = rowOffset;
    }

    public SbtQuantity getSkyOffset() {
        return skyOffset;
    }

    public void setSkyOffset(SbtQuantity skyOffset) {
        this.skyOffset = skyOffset;
    }

}

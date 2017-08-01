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

package gov.nasa.kepler.mc.gar;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.spiffy.common.persistable.OracleDouble;
import gov.nasa.spiffy.common.persistable.Persistable;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Contains a requant table for use by MATLAB. This object contains both the
 * requant entries and the mean black entries.
 * 
 * @author Bill Wohler
 * @author Sean McCauliff
 */
public class RequantTable implements Persistable {

    /**
     * The external ID. Only used to debug the bin file.
     */
    private int externalId;

    /**
     * The time that this requant table takes effect.
     */
    @OracleDouble
    private double startMjd;

    /**
     * The requantization entries. This array must have
     * {@link FcConstants#REQUANT_TABLE_LENGTH} entries.
     */
    private int[] requantEntries;

    /**
     * The mean black entries. This array must have
     * {@link FcConstants#MODULE_OUTPUTS} entries.
     * <p>[1002.CAL.5]</p>
     */
    private int[] meanBlackEntries;

    /**
     * Creates a {@link RequantTable}.
     */
    public RequantTable() {
    }

    /**
     * Creates a {@link RequantTable}.
     * 
     * @param requantTable the Hibernate version of the requant table.
     * @param startMjd the time that this requant table takes effect.
     */
    public RequantTable(
        gov.nasa.kepler.hibernate.gar.RequantTable requantTable,
        double startMjd) {

        this.externalId = requantTable.getExternalId();
        this.startMjd = startMjd;

        setRequantEntries(requantTable.getRequantFluxes());
        setMeanBlackEntries(requantTable.getMeanBlackValues());
    }

    public int getExternalId() {
        return externalId;
    }

    public void setExternalId(int externalId) {
        this.externalId = externalId;
    }

    public double getStartMjd() {
        return startMjd;
    }

    public void setStartMjd(double startMjd) {
        this.startMjd = startMjd;
    }


    public int[] getRequantEntries() {
        return requantEntries;
    }

    public final void setRequantEntries(int[] requantEntries) {
        this.requantEntries = requantEntries;
        if (requantEntries == null) {
            throw new NullPointerException("requantEntries can't be null");
        }
        if (requantEntries.length != FcConstants.REQUANT_TABLE_LENGTH) {
            throw new IllegalStateException("requantEntries has only "
                + requantEntries.length + " entries, but "
                + FcConstants.REQUANT_TABLE_LENGTH + " are required");
        }
    }

    public int[] getMeanBlackEntries() {
        return meanBlackEntries;
    }

    public final void setMeanBlackEntries(int[] meanBlackEntries) {
        this.meanBlackEntries = meanBlackEntries;
        if (meanBlackEntries == null) {
            throw new NullPointerException("meanBlackEntries can't be null");
        }
        if (meanBlackEntries.length != FcConstants.MODULE_OUTPUTS) {
            throw new IllegalStateException("meanBlackEntries has only "
                + meanBlackEntries.length + " entries, but "
                + FcConstants.MODULE_OUTPUTS + " are required");
        }
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("externalId", externalId)
            .append("startMjd", startMjd)
            .append("requantEntries count", requantEntries.length)
            .append("meanBlackEntries count", meanBlackEntries.length)
            .toString();
    }
}

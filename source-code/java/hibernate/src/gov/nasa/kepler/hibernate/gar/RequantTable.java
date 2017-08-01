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

package gov.nasa.kepler.hibernate.gar;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.JoinTable;
import javax.persistence.OneToOne;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

@Entity
@Table(name = "GAR_REQUANT_TABLE")
public class RequantTable extends ExportTable {

    /**
     * The {@link PipelineTask} of the {@link PipelineModule} that produced this
     * report. Not included in the report.
     */
    @OneToOne(fetch = FetchType.LAZY)
    private PipelineTask pipelineTask;

    /**
     * An ordered list of the actual rows in the requantization table.
     */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "GAR_RT_REQUANT_ENTRIES")
    private List<RequantEntry> requantEntries = new ArrayList<RequantEntry>();

    /**
     * An ordered list of the mean black entries.
     */
    @CollectionOfElements(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @IndexColumn(name = "IDX")
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "GAR_RT_MEAN_BLACK_ENTRIES")
    private List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>();

    public RequantTable() {
    }

    @Override
    protected String getShortName() {
        return "rq";
    }

    public String generateMeanBlackFileName(Date date) {
        return generateFileName("mb", date);
    }

    public PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }

    public List<RequantEntry> getRequantEntries() {
        return requantEntries;
    }

    public void setRequantEntries(List<RequantEntry> requantEntries) {
        if (requantEntries.size() != FcConstants.REQUANT_TABLE_LENGTH) {
            throw new IllegalArgumentException("Number of requantEntries "
                + requantEntries.size() + " not equal to "
                + FcConstants.REQUANT_TABLE_LENGTH);
        }
        this.requantEntries = requantEntries;
    }

    public List<MeanBlackEntry> getMeanBlackEntries() {
        return meanBlackEntries;
    }
    
    /**
     *
     * @return the mean black value in counts
     */
    public int getMeanBlackValue(int ccdModule, int ccdOutput) {
        int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
        return meanBlackEntries.get(channel - 1).getMeanBlackValue();
    }

    public void setMeanBlackEntries(List<MeanBlackEntry> meanBlackEntries) {
        if (meanBlackEntries.size() != FcConstants.MEAN_BLACK_TABLE_LENGTH) {
            throw new IllegalArgumentException("Number of meanBlackEntries "
                + meanBlackEntries.size() + " not equal to "
                + FcConstants.MEAN_BLACK_TABLE_LENGTH);
        }
        this.meanBlackEntries = meanBlackEntries;
    }

    /**
     * Returns the list of requant entries as an array of requant fluxes.
     * 
     * @return a non-{@code null} array
     */
    public int[] getRequantFluxes() {
        int[] requantValues = new int[requantEntries.size()];
        int i = 0;
        for (RequantEntry entry : requantEntries) {
            requantValues[i++] = entry.getRequantFlux();
        }

        return requantValues;
    }

    /**
     * Returns the list of mean black entries as an array of mean black values.
     * 
     * @return a non-{@code null} array
     */
    public int[] getMeanBlackValues() {
        int[] requantValues = new int[meanBlackEntries.size()];
        int i = 0;
        for (MeanBlackEntry entry : meanBlackEntries) {
            requantValues[i++] = entry.getMeanBlackValue();
        }

        return requantValues;
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }

    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append(pipelineTask).append(
            requantEntries.size() + " requant entries").append(
            meanBlackEntries.size() + " mean black entries").toString();
    }
}

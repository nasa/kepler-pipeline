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
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class PdcOutputs implements Persistable {

    /**
     * "LONG" or "SHORT"
     */
    private String cadenceType = CadenceType.LONG.toString();

    /**
     * Starting cadence number.
     */
    private int startCadence;

    /**
     * Ending cadence number.
     */
    private int endCadence;

    /**
     * corrected target flux
     */
    private List<PdcTargetOutputData> targetResultsStruct = newArrayList();

    /**
     * Per-channel outputs.
     */
    private List<PdcOutputChannelData> channelDataStruct = newArrayList();

    /**
     * Alerts for the operator.
     */
    private List<ModuleAlert> alerts = newArrayList();

    public PdcOutputs() {
    }

    /**
     * Constructs a {@link String} with all attributes in name = value format.
     * 
     * @return a {@link String} representation of this object.
     */
    @Override
    public String toString() {
        // TODO add other fields?
        return new ToStringBuilder(this).append("targetResultsStruct",
            targetResultsStruct)
            .toString();
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

    public List<PdcTargetOutputData> getTargetResultsStruct() {
        return targetResultsStruct;
    }

    public void setTargetResultsStruct(
        List<PdcTargetOutputData> targetResultsStruct) {
        this.targetResultsStruct = targetResultsStruct;
    }

    public List<PdcOutputChannelData> getChannelData() {
        return channelDataStruct;
    }
 
    public void setChannelData(List<PdcOutputChannelData> channelData) {
        this.channelDataStruct = channelData;
    }

    public List<ModuleAlert> getAlerts() {
        return alerts;
    }

    public void setAlerts(List<ModuleAlert> alerts) {
        this.alerts = alerts;
    }

}

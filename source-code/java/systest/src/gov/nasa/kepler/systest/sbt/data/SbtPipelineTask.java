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

/**
 * This class contains pipeline task metadata.
 * 
 * @author Miles Cote
 * 
 */
public class SbtPipelineTask implements SbtDataContainer {

    private long id;
    private String startProcessingTime = "";
    private String endProcessingTime = "";
    private String state = "";
    private String softwareRevision = "";
    private String unitOfWork = "";

    private List<SbtAlert> alerts = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("id",
            new SbtNumber(id).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startProcessingTime",
            new SbtString(startProcessingTime).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endProcessingTime",
            new SbtString(endProcessingTime).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("state",
            new SbtString(state).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("softwareRevision",
            new SbtString(softwareRevision).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("unitOfWork", new SbtString(
            unitOfWork).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("alerts", new SbtList(
            alerts, true).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPipelineTask() {
    }

    public SbtPipelineTask(long id, String startProcessingTime,
        String endProcessingTime, String state, String softwareRevision,
        String unitOfWork, List<SbtAlert> alerts) {
        this.id = id;
        this.startProcessingTime = startProcessingTime;
        this.endProcessingTime = endProcessingTime;
        this.state = state;
        this.softwareRevision = softwareRevision;
        this.unitOfWork = unitOfWork;
        this.alerts = alerts;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getStartProcessingTime() {
        return startProcessingTime;
    }

    public void setStartProcessingTime(String startProcessingTime) {
        this.startProcessingTime = startProcessingTime;
    }

    public String getEndProcessingTime() {
        return endProcessingTime;
    }

    public void setEndProcessingTime(String endProcessingTime) {
        this.endProcessingTime = endProcessingTime;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getSoftwareRevision() {
        return softwareRevision;
    }

    public void setSoftwareRevision(String softwareRevision) {
        this.softwareRevision = softwareRevision;
    }

    public String getUnitOfWork() {
        return unitOfWork;
    }

    public void setUnitOfWork(String unitOfWork) {
        this.unitOfWork = unitOfWork;
    }

    public List<SbtAlert> getAlerts() {
        return alerts;
    }

    public void setAlerts(List<SbtAlert> alerts) {
        this.alerts = alerts;
    }

}

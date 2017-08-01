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
import gov.nasa.kepler.mc.MqTimestampSeries;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class contains all of the data available for a {@link List} of
 * keplerIds.
 * 
 * @author Miles Cote
 * 
 */
public class SbtData implements SbtDataContainer {

    private static final Log log = LogFactory.getLog(SbtData.class);

    private String cadenceType = "";
    private int startCadence;
    private int endCadence;
    private String baseDescription = "";
    private String[] includedProducts = ArrayUtils.EMPTY_STRING_ARRAY;

    private MqTimestampSeries cadenceTimes = new MqTimestampSeries();

    private SbtAttitudeSolution attitudeSolution = new SbtAttitudeSolution();

    private List<SbtSimpleTimeSeries> pagTimeSeriesList = newArrayList();

    private List<SbtTargetTable> targetTables = newArrayList();

    private List<SbtTarget> targets = newArrayList();

    private List<SbtCsci> pipelineMetadata = newArrayList();

    private SbtSpacecraftMetadata spacecraftMetadata = new SbtSpacecraftMetadata();

    private List<SbtAncillaryData> ancillaryData = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        log.info("Creating missing data string.");

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("cadenceType",
            new SbtString(cadenceType).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startCadence",
            new SbtNumber(startCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endCadence", new SbtNumber(
            endCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("baseDescription",
            new SbtString(baseDescription).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "includedProducts",
            new SbtList(
                SbtDataContainerListFactory.getInstance(includedProducts)).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "cadenceTimes",
            new SbtMqTimestampSeries(cadenceTimes).toMissingDataString(parameters)));
        if (!parameters.isShortCadence()) {
            stringBuilder.append(SbtDataUtils.toString("attitudeSolution",
                attitudeSolution.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("pagTimeSeriesList",
                new SbtList(pagTimeSeriesList).toMissingDataString(parameters)));
        }
        stringBuilder.append(SbtDataUtils.toString("targetTables", new SbtList(
            targetTables).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("targets", new SbtList(
            targets).toMissingDataString(parameters)));
        // The gapped cscis will not exist for custom targets because pipeline
        // processing for custom targets stops after cal.
        stringBuilder.append(SbtDataUtils.toString(
            "pipelineMetadata",
            new SbtList(pipelineMetadata, new SbtGapIndicators(new boolean[] {
                false, true, true, true, true, true })).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("spacecraftMetadata",
            spacecraftMetadata.toMissingDataString(parameters)));

        log.info("Completed creating missing data string.");

        return stringBuilder.toString();
    }

    public SbtData() {
    }

    public SbtData(String cadenceType, int startCadence, int endCadence,
        String baseDescription, String[] includedProducts,
        MqTimestampSeries cadenceTimes, SbtAttitudeSolution attitudeSolution,
        List<SbtSimpleTimeSeries> pagTimeSeriesList,
        List<SbtTargetTable> targetTables, List<SbtTarget> targets,
        List<SbtCsci> pipelineMetadata,
        SbtSpacecraftMetadata spacecraftMetadata,
        List<SbtAncillaryData> ancillaryData) {
        this.cadenceType = cadenceType;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.baseDescription = baseDescription;
        this.includedProducts = includedProducts;
        this.cadenceTimes = cadenceTimes;
        this.attitudeSolution = attitudeSolution;
        this.pagTimeSeriesList = pagTimeSeriesList;
        this.targetTables = targetTables;
        this.targets = targets;
        this.pipelineMetadata = pipelineMetadata;
        this.spacecraftMetadata = spacecraftMetadata;
        this.ancillaryData = ancillaryData;
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

    public String getBaseDescription() {
        return baseDescription;
    }

    public void setBaseDescription(String baseDescription) {
        this.baseDescription = baseDescription;
    }

    public String[] getIncludedProducts() {
        return includedProducts;
    }

    public void setIncludedProducts(String[] includedProducts) {
        this.includedProducts = includedProducts;
    }

    public MqTimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(MqTimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public SbtAttitudeSolution getAttitudeSolution() {
        return attitudeSolution;
    }

    public void setAttitudeSolution(SbtAttitudeSolution attitudeSolution) {
        this.attitudeSolution = attitudeSolution;
    }

    public List<SbtSimpleTimeSeries> getPagTimeSeriesList() {
        return pagTimeSeriesList;
    }

    public void setPagTimeSeriesList(List<SbtSimpleTimeSeries> pagTimeSeriesList) {
        this.pagTimeSeriesList = pagTimeSeriesList;
    }

    public List<SbtTargetTable> getTargetTables() {
        return targetTables;
    }

    public void setTargetTables(List<SbtTargetTable> targetTables) {
        this.targetTables = targetTables;
    }

    public List<SbtTarget> getTargets() {
        return targets;
    }

    public void setTargets(List<SbtTarget> targets) {
        this.targets = targets;
    }

    public List<SbtCsci> getPipelineMetadata() {
        return pipelineMetadata;
    }

    public void setPipelineMetadata(List<SbtCsci> pipelineMetadata) {
        this.pipelineMetadata = pipelineMetadata;
    }

    public SbtSpacecraftMetadata getSpacecraftMetadata() {
        return spacecraftMetadata;
    }

    public void setSpacecraftMetadata(SbtSpacecraftMetadata spacecraftMetadata) {
        this.spacecraftMetadata = spacecraftMetadata;
    }

    public List<SbtAncillaryData> getAncillaryData() {
        return ancillaryData;
    }

    public void setAncillaryData(List<SbtAncillaryData> ancillaryData) {
        this.ancillaryData = ancillaryData;
    }

}

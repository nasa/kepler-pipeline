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

package gov.nasa.kepler.etem2;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.etem.TargetPmrfFits;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.mc.tad.TadParameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class DataGenDirManager {

    private DataGenParameters dataGenParameters;
    private PackerParameters packerParameters;
    private TransmissionParameters transmissionParameters;
    private TadParameters tadParameters;

    private String cadenceTypeName;
    private CadenceType cadenceType;
    private List<String> dataSetNames;
    private List<String> transmissionNames;

    public DataGenDirManager(DataGenParameters dataGenParameters) {
        this.dataGenParameters = dataGenParameters;

        validateParams(dataGenParameters);
    }

    public DataGenDirManager(DataGenParameters dataGenParameters,
        PackerParameters packerParameters) {
        this.dataGenParameters = dataGenParameters;
        this.packerParameters = packerParameters;

        validateParams(dataGenParameters);
        validateParams(dataGenParameters, packerParameters);
    }

    public DataGenDirManager(DataGenParameters dataGenParameters,
        PackerParameters packerParameters,
        CadenceTypePipelineParameters cadenceTypeParameters) {
        this.dataGenParameters = dataGenParameters;
        this.packerParameters = packerParameters;

        if (CadenceType.LONG.getName()
            .equalsIgnoreCase(cadenceTypeParameters.getCadenceType())) {
            cadenceTypeName = "long";
            cadenceType = CadenceType.LONG;
        } else if (CadenceType.SHORT.getName()
            .equalsIgnoreCase(cadenceTypeParameters.getCadenceType())) {
            cadenceTypeName = "short";
            cadenceType = CadenceType.SHORT;
        } else {
            throw new PipelineException(
                "The cadence type must be either long or short (type="
                    + cadenceTypeParameters.getCadenceType());
        }

        validateParams(dataGenParameters);
        validateParams(dataGenParameters, packerParameters);
    }

    public DataGenDirManager(DataGenParameters dataGenParameters,
        PackerParameters packerParameters, TadParameters tadParameters) {
        this.dataGenParameters = dataGenParameters;
        this.packerParameters = packerParameters;
        this.tadParameters = tadParameters;

        String tlsName = this.tadParameters.getTargetListSetName();
        TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
        TargetListSet tls = targetSelectionCrud.retrieveTargetListSet(tlsName);
        switch (tls.getType()) {
            case LONG_CADENCE:
                cadenceTypeName = "long";
                cadenceType = CadenceType.LONG;
                break;
            case SHORT_CADENCE:
                cadenceTypeName = "short";
                cadenceType = CadenceType.SHORT;
                break;
            default:
                throw new PipelineException(
                    "The target list set to manage must be either long or short.  type = "
                        + tls.getType());
        }

        validateParams(dataGenParameters);
        validateParams(dataGenParameters, packerParameters);
    }

    public DataGenDirManager(DataGenParameters dataGenParams,
        TransmissionParameters transmissionParams) {
        this.dataGenParameters = dataGenParams;
        this.transmissionParameters = transmissionParams;

        validateParams(dataGenParameters);
        validateParams(dataGenParameters, transmissionParameters);
    }

    private void validateParams(DataGenParameters dataGenParameters) {
        String[] dataSetNameArray = dataGenParameters.getDataSetNames()
            .split(",");
        for (int i = 0; i < dataSetNameArray.length; i++) {
            dataSetNameArray[i] = dataSetNameArray[i].trim();
        }
        dataSetNames = Arrays.asList(dataSetNameArray);
    }

    private void validateParams(DataGenParameters dataGenParameters,
        PackerParameters packerParameters) {
        // Validate that dataSetName is on the dataSetNames list.
        if (!dataSetNames.contains(packerParameters.getDataSetName())) {
            throw new PipelineException(
                "dataSetNames must contain dataSetName.  dataSetNames = "
                    + dataSetNames + ", dataSetName = "
                    + packerParameters.getDataSetName());
        }

        // Validate that dataSetNames has unique names in it.
        Set<String> uniqueNames = new HashSet<String>();
        for (String dataSetName : dataSetNames) {
            if (!uniqueNames.contains(dataSetName)) {
                uniqueNames.add(dataSetName);
            } else {
                throw new PipelineException(
                    "dataSetNames must be unique.  dataSetNames = "
                        + dataSetNames);
            }
        }
    }

    private void validateParams(DataGenParameters dataGenParameters,
        TransmissionParameters transmissionParameters) {
        String[] transmissionNameArray = dataGenParameters.getTransmissionNames()
            .split(",");
        for (int i = 0; i < transmissionNameArray.length; i++) {
            transmissionNameArray[i] = transmissionNameArray[i].trim();
        }
        transmissionNames = Arrays.asList(transmissionNameArray);

        // Validate that transmissionName is on the transmissionNames list.
        if (!transmissionNames.contains(transmissionParameters.getTransmissionName())) {
            throw new PipelineException(
                "transmissionNames must contain transmissionName.  transmissionNames = "
                    + transmissionNames + ", transmissionName = "
                    + transmissionParameters.getTransmissionName());
        }

        // Validate that transmissionNames has unique names in it.
        Set<String> uniqueNames = new HashSet<String>();
        for (String transmissionName : transmissionNames) {
            if (!uniqueNames.contains(transmissionName)) {
                uniqueNames.add(transmissionName);
            } else {
                throw new PipelineException(
                    "transmissionNames must be unique.  transmissionNames = "
                        + transmissionNames);
            }
        }
    }

    public String getDataGenOutputDir() {
        return dataGenParameters.getDataGenOutputPath();
    }

    public String getDataSetDir() {
        return dataGenParameters.getDataGenOutputPath() + "/"
            + packerParameters.getDataSetName();
    }

    public String getTransmissionDir() {
        return dataGenParameters.getDataGenOutputPath() + "/"
            + transmissionParameters.getTransmissionName();
    }

    public String getVcduDir() {
        return getTransmissionDir() + "/vcdu";
    }

    public String getCaduDir() {
        return getTransmissionDir() + "/cadu";
    }

    public String getEtemDir() {
        return getDataSetDir() + "/" + cadenceTypeName;
    }

    public String getPmrfDir(
        PlannedPhotometerConfigParameters photometerConfigParams) {
        int tableId = 0;
        String pmrfSuffix = null;

        switch (cadenceType) {
            case LONG:
                tableId = photometerConfigParams.getLctExternalId();
                pmrfSuffix = TargetPmrfFits.LCM;
                break;
            case SHORT:
                tableId = photometerConfigParams.getSctExternalId();
                pmrfSuffix = TargetPmrfFits.SCM;
                break;
        }

        return getEtemDir() + "/pmrf/" + tableId + pmrfSuffix;
    }

    public String getRpDir() {
        return getEtemDir() + "/rp";
    }

    public String getMergedDir() {
        return getEtemDir() + "/merged";
    }

    public String getFfiFitsDir() {
        return getEtemDir() + "/ffi-fits";
    }

    public String getCadenceFitsDir() {
        return getEtemDir() + "/fits";
    }

    public String getPacketizedDir() {
        return getDataSetDir() + "/packetized";
    }

    public String getUplinkedTablesExportDir() {
        return getDataSetDir() + "/uplinked-tables-export";
    }

    public String getConfigMapExportDir() {
        return getDataSetDir() + "/config-map-export";
    }

    public String getCatalogsExportDir() {
        return getDataSetDir() + "/catalogs-export";
    }

    public String getPrfAttitudeAdjustmentExportDir() {
        return getDataSetDir() + "/prf-attitude-adjustment-export";
    }

    public String getPdqExportDir() {
        return getDataSetDir() + "/pdq-export";
    }

    public String getFfi2LcDir() {
        return getDataSetDir() + "/ffi2Lc";
    }

    public String getCalExportDir(CadenceType cadenceType, int startCadence,
        int endCadence) {
        return getDataSetDir() + "/cal-export/" + cadenceType.getName() + "/"
            + startCadence + "-" + endCadence;
    }

    public String getCalFfiExportDir() {
        return getDataSetDir() + "/cal-ffi-export";
    }

    public String getFluxExportDir() {
        return getDataSetDir() + "/flux-export";
    }

    public String getTargetPixelExportDir() {
        return getDataSetDir() + "/target-pixel-export";
    }

    public String getCdppExportDir() {
        return getDataGenOutputDir() + "/cdpp-export";
    }

    public String getDvExportDir() {
        return getDataGenOutputDir() + "/dv-export";
    }

    public String getDvTimeSeriesExportDir() {
        return getDataGenOutputDir() + "/dv-time-series-export";
    }

    public String getDvReportsExportDir() {
        return getDataGenOutputDir() + "/dv-reports-export";
    }

    public String getCombinedFlatFieldExportDir() {
        return getDataSetDir() + "/combined-flat-field-export";
    }

    public String getTasksRootDir() {
        return getDataSetDir() + "/tasks";
    }

    public String getPreviousPacketizedDir() {
        int indexOfCurrentDataSetName = dataSetNames.indexOf(packerParameters.getDataSetName());

        if (indexOfCurrentDataSetName == 0) {
            return null;
        }
        return dataGenParameters.getDataGenOutputPath() + "/"
            + dataSetNames.get(indexOfCurrentDataSetName - 1) + "/packetized";
    }

    public String[] getCcsdsFilenames() {
        List<String> ccsdsFilenames = new ArrayList<String>();
        for (String dataSetName : dataSetNames) {
            String packetizedDir = dataGenParameters.getDataGenOutputPath()
                + "/" + dataSetName + "/packetized";
            String ccsdsFilename = packetizedDir + "/ccsds/"
                + DataSetPacker.CCSDS_OUTPUT_FILENAME;
            File ccsdsFile = new File(ccsdsFilename);
            if (ccsdsFile.exists()) {
                ccsdsFilenames.add(ccsdsFilename);
            }
        }

        return ccsdsFilenames.toArray(new String[0]);
    }

    public String getPreviousTransmissionDir() {
        int indexOfCurrentTransmissionName = transmissionNames.indexOf(transmissionParameters.getTransmissionName());

        if (indexOfCurrentTransmissionName == 0) {
            return null;
        }
        return dataGenParameters.getDataGenOutputPath() + "/"
            + transmissionNames.get(indexOfCurrentTransmissionName - 1);
    }

}

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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.dr.configmap.ConfigMapReader;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapperFactory;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileListXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.kepler.sds.scCfgIdMap.ScCfgIdMap;
import gov.nasa.kepler.sds.scCfgIdMap.ScCfgIdMapDocument;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

public class ConfigMapExporter {

    private static final String DEFAULT_VERSION = "a";

    private static final int DEFAULT_VALUE = -1;

    public List<File> export(
        PlannedSpacecraftConfigParameters spacecraftConfigParams, String path)
        throws IOException {
        // Generate xml document.
        ScCfgIdMapDocument doc = ScCfgIdMapDocument.Factory.newInstance();

        ScCfgIdMap scCfgIdMap = doc.addNewScCfgIdMap();

        scCfgIdMap.setTCSCCFGID(spacecraftConfigParams.getScConfigId());
        scCfgIdMap.setTimestamp(DateUtils.formatLikeDmc(ModifiedJulianDate.mjdToDate(spacecraftConfigParams.getMjd())));

        scCfgIdMap.setGSFSWBLD(5);
        scCfgIdMap.setGSFSWREL(0);
        scCfgIdMap.setGSFSWUPDATE(0);

        // Todd says: subtract 2 right before exporting rather than subtracting
        // 2 from the default FDMINTPER in PlannedSpacecraftConfigParameters.
        scCfgIdMap.setFDMINTPER(spacecraftConfigParams.getFgsFramesPerIntegration()
            - ConfigMapReader.FDMINTPER_INCREMENT_VALUE);
        scCfgIdMap.setGSprmFGSPER((float) spacecraftConfigParams.getMillisecondsPerFgsFrame());
        scCfgIdMap.setGSprmROPER((float) spacecraftConfigParams.getMillisecondsPerReadout());
        scCfgIdMap.setFDMSCPER(spacecraftConfigParams.getIntegrationsPerShortCadence());
        scCfgIdMap.setFDMLCPER(spacecraftConfigParams.getShortCadencesPerLongCadence());
        scCfgIdMap.setFDMNUMLCPERBL(spacecraftConfigParams.getLongCadencesPerBaseline());
        scCfgIdMap.setFDMLDEFFINUM(spacecraftConfigParams.getIntegrationsPerScienceFfi());

        scCfgIdMap.setFDMSMRROWSTART(spacecraftConfigParams.getSmearStartRow());
        scCfgIdMap.setFDMSMRROWEND(spacecraftConfigParams.getSmearEndRow());
        scCfgIdMap.setFDMSMRCOLSTART(spacecraftConfigParams.getSmearStartCol());
        scCfgIdMap.setFDMSMRCOLEND(spacecraftConfigParams.getSmearEndCol());
        scCfgIdMap.setFDMMSKROWSTART(spacecraftConfigParams.getMaskedStartRow());
        scCfgIdMap.setFDMMSKROWEND(spacecraftConfigParams.getMaskedEndRow());
        scCfgIdMap.setFDMMSKCOLSTART(spacecraftConfigParams.getMaskedStartCol());
        scCfgIdMap.setFDMMSKCOLEND(spacecraftConfigParams.getMaskedEndCol());
        scCfgIdMap.setFDMDRKROWSTART(spacecraftConfigParams.getDarkStartRow());
        scCfgIdMap.setFDMDRKROWEND(spacecraftConfigParams.getDarkEndRow());
        scCfgIdMap.setFDMDRKCOLSTART(spacecraftConfigParams.getDarkStartCol());
        scCfgIdMap.setFDMDRKCOLEND(spacecraftConfigParams.getDarkEndCol());

        scCfgIdMap.setPEDFOC1POS(0);
        scCfgIdMap.setPEDFOC2POS(0);
        scCfgIdMap.setPEDFOC3POS(0);
        scCfgIdMap.setPEDFPAHCSETPT(5500);

        scCfgIdMap.setFDMLCOFFSET(spacecraftConfigParams.getLcRequantFixedOffset());
        scCfgIdMap.setFDMSCOFFSET(spacecraftConfigParams.getScRequantFixedOffset());

        scCfgIdMap.setGSprmRA(DEFAULT_VALUE);
        scCfgIdMap.setGSprmDEC(DEFAULT_VALUE);
        scCfgIdMap.setGSprmSUROLL(DEFAULT_VALUE);
        scCfgIdMap.setGSprmFROLL(DEFAULT_VALUE);
        scCfgIdMap.setGSprmWROLL(DEFAULT_VALUE);
        scCfgIdMap.setGSprmSPROLL(DEFAULT_VALUE);
        scCfgIdMap.setGSprmSEASON(DEFAULT_VALUE);

        // save the xml document:
        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        File configMapFile = new File(path, "kplr"
            + DateUtils.formatLikeDmc(new Date()) + DEFAULT_VERSION
            + DispatcherWrapperFactory.CONFIG_MAP);
        doc.save(configMapFile, xmlOptions);

        List<File> files = new ArrayList<File>();
        files.add(configMapFile);

        // Create notification message.
        DataProductMessageDocument nmDoc = DataProductMessageDocument.Factory.newInstance();
        DataProductMessageXB dataProductMessage = nmDoc.addNewDataProductMessage();

        dataProductMessage.setMessageType("SCNM");
        String scnmFilename = String.format("kplr%s_%s.xml",
            DateUtils.formatLikeDmc(new Date()), "scnm");
        dataProductMessage.setIdentifier(scnmFilename);

        FileListXB fileList = dataProductMessage.addNewFileList();

        for (File file : files) {
            FileXB dataProductFile = fileList.addNewFile();
            dataProductFile.setFilename(file.getName());
        }

        xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!nmDoc.validate(xmlOptions)) {
            throw new PipelineException("XML validation error.  " + errors);
        }

        File scnmFile = new File(path, scnmFilename);
        nmDoc.save(scnmFile, xmlOptions);

        files.add(scnmFile);

        return files;
    }

}

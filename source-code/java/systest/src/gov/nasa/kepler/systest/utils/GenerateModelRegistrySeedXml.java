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

package gov.nasa.kepler.systest.utils;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.SvnUtils;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.pi.modelRegistry.DataModelRegistryDocument;
import gov.nasa.kepler.pi.modelRegistry.ModelMetadataXB;
import gov.nasa.kepler.pi.modelRegistry.ModelRegistryXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.log4j.Logger;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;
import org.tmatesoft.svn.core.SVNException;


/**
 * This class generates a model registry XML file by
 * querying FC and DR tables. The purpose of this XML 
 * file is to seed an existing database that contains
 * no model registry entities (e.g., migrating a 6.1
 * database to 6.2). The emitted XML file does contain
 * values for all fields, so some manual editing is 
 * necessary before it can be imported
 *  
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class GenerateModelRegistrySeedXml {
    private static final Logger log = Logger.getLogger(GenerateModelRegistrySeedXml.class);

    private String svnDataRepoRoot;
    private String filename;
    
    public GenerateModelRegistrySeedXml(String svnDataRepoRoot, String filename) {
        this.svnDataRepoRoot = svnDataRepoRoot;
        this.filename = filename;
    }

    private void go() throws Exception {
        FcCrud fcCrud = new FcCrud();
        Map<HistoryModelName,History> fcList = new HashMap<HistoryModelName,History>();
        
        for (HistoryModelName modelName : HistoryModelName.values()) {
            History history = fcCrud.retrieveHistory(modelName); 
            fcList.put(modelName, history);
        }
        
        Map<DispatcherType, ReceiveLog> mocList = latestMocModels();
        
        export(filename, fcList, mocList);
        
    }

    private Map<DispatcherType,ReceiveLog> latestMocModels(){
        LogCrud logCrud = new LogCrud();
        List<DispatchLog> dispatchLogs = logCrud.retrieveAllDispatchLogs();
        Map<DispatcherType,ReceiveLog> filteredRecvLogs = new HashMap<DispatcherType,ReceiveLog>();

        ArrayList<DispatcherType> validTypes = new ArrayList<DispatcherType>();
        validTypes.add(DispatcherType.LEAP_SECONDS);
        validTypes.add(DispatcherType.PLANETARY_EPHEMERIS);
        validTypes.add(DispatcherType.SCLK);
        validTypes.add(DispatcherType.SPACECRAFT_EPHEMERIS);
        
        for (DispatchLog dispatchLog : dispatchLogs) {
            DispatcherType type = dispatchLog.getDispatcherType();
            
            if(!validTypes.contains(type)){
                continue;
            }
            
            ReceiveLog recvLog = dispatchLog.getReceiveLog();
            ReceiveLog existingRecvLog = filteredRecvLogs.get(type);
            
            if(existingRecvLog == null){
                filteredRecvLogs.put(type, recvLog);
            }else{
                Date newIngestTime = recvLog.getSocIngestTime();
                Date existingIngestTime = existingRecvLog.getSocIngestTime();
                
                if(newIngestTime.compareTo(existingIngestTime) > 0){
                    filteredRecvLogs.put(type, recvLog);
                }
            }
        }        
        return filteredRecvLogs;
    }
    
    /**
     * Export the current contents of the Data Model Registry to an XML file.
     * 
     * @param destinationPath
     * @throws IOException
     * @throws SVNException 
     */
    private void export(String destinationPath, Map<HistoryModelName,History> fcModels, Map<DispatcherType,ReceiveLog> mocModels) throws IOException, SVNException {

        File destinationFile = new File(destinationPath);
        if (destinationFile.exists() && destinationFile.isDirectory()) {
            throw new IllegalArgumentException("destinationPath exists and is a directory: " + destinationFile);
        }

        DataModelRegistryDocument modelRegistryDocument = DataModelRegistryDocument.Factory.newInstance();
        ModelRegistryXB modelRegistryXmlBean = modelRegistryDocument.addNewDataModelRegistry();

        // FC models
        
        log.info("Exporting " + fcModels.size() + " FC models to: " + destinationFile);

        LinkedList<HistoryModelName> fcTypes = new LinkedList<HistoryModelName>(fcModels.keySet());
        Collections.sort(fcTypes);

        for (HistoryModelName fcType : fcTypes) {
            History fcModel = fcModels.get(fcType);

            if(fcModel != null){ // exclude pseudo models, like RADEC2PIX
                log.info("exporting FC model: name=" + fcType + ", model=" + fcModel);
                
                ModelMetadataXB modelXmlBean = modelRegistryXmlBean.addNewModelMetadata();
                double modelMjd = fcModel.getIngestTime();
                Date modelDate = ModifiedJulianDate.mjdToDate(modelMjd);
                populateModel(modelXmlBean, fcType.toString(), extractSvnPath(fcModel.getDescription()), modelDate);
            }
        }

        // MOC models
        
        log.info("Exporting " + mocModels.size() + " MOC models to: " + destinationFile);

        LinkedList<DispatcherType> mocTypes = new LinkedList<DispatcherType>(mocModels.keySet());
        Collections.sort(mocTypes);

        for (DispatcherType dispatcherType : mocTypes) {
            log.info("exporting MOC model: name=" + dispatcherType);

            ReceiveLog mocRecvLog = mocModels.get(dispatcherType);

            ModelMetadataXB modelXmlBean = modelRegistryXmlBean.addNewModelMetadata();
            populateModel(modelXmlBean, dispatcherType.toString(), mocRecvLog.getMessageFileName(), mocRecvLog.getSocIngestTime());
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!modelRegistryDocument.validate(xmlOptions)) {
            throw new PipelineException("Export of ModelRegistry failed: XML validation errors: " + errors);
        }

        modelRegistryDocument.save(destinationFile, xmlOptions);
    }

    private String extractSvnPath(String description) throws SVNException{
        String[] elements = description.split(" ");
        
        for (int i = 0; i < elements.length; i++) {
            if(elements[i].startsWith("flight/so/models")){
                String svnPath = svnDataRepoRoot + "/" + elements[i];
                String revision = SvnUtils.getSvnInfoForDirectory(svnPath);
                return revision;
            }
        }
        log.warn("svn path not found in: " + description);
        return description;
    }
    
    private void populateModel(ModelMetadataXB modelXmlBean, String type, String revision, Date ingestTime){
        modelXmlBean.setType(type);
        modelXmlBean.setRevision(revision);
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(ingestTime);
        modelXmlBean.setImportTime(calendar);
        modelXmlBean.setDescription("Added as seed data during r6.2 migration");
    }
    
    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("USAGE: genmodreg DATA_REPO_ROOT FILE");
            System.exit(-1);
        }

        String svnDataRepoRoot = args[0];
        String filename = args[1];

        GenerateModelRegistrySeedXml cli = new GenerateModelRegistrySeedXml(svnDataRepoRoot, filename);
        cli.go();
    }
}

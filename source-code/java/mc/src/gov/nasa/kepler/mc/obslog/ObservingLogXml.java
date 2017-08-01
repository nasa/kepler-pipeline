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

package gov.nasa.kepler.mc.obslog;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.hibernate.mc.ObservingLog;
import gov.nasa.kepler.mc.observingLog.CadenceTypeStr;
import gov.nasa.kepler.mc.observingLog.ObservationXB;
import gov.nasa.kepler.mc.observingLog.ObservingLogDocument;
import gov.nasa.kepler.mc.observingLog.ObservingLogXB;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class ObservingLogXml {
    private static final Log log = LogFactory.getLog(ObservingLogXml.class);

    public ObservingLogXml() {
    }

    public List<ObservingLog> readFromFile(String sourcePath) throws Exception{
        File sourceFile = new File(sourcePath);
        List<ObservingLog> entries = new LinkedList<ObservingLog>();

        ObservingLogDocument obsLogDocument = ObservingLogDocument.Factory.parse(sourceFile);
        ObservingLogXB obsLogXmlBean = obsLogDocument.getObservingLog();
        
        ObservationXB[] obsList = obsLogXmlBean.getObservationArray();
        
        for (ObservationXB obsXml : obsList) {
            ObservingLog obs = new ObservingLog();
            
            obs.setQuarter(obsXml.getQuarter());
            obs.setMonth(obsXml.getMonth());
            obs.setSeason(obsXml.getSeason());
            
            if(obsXml.getCadenceType() == CadenceTypeStr.LONG){
                obs.setCadenceType(Cadence.CADENCE_LONG);
            }else if(obsXml.getCadenceType() == CadenceTypeStr.SHORT){
                obs.setCadenceType(Cadence.CADENCE_SHORT);
            }else{
                throw new PipelineException("Unexpected cadenceType: " + obsXml.getCadenceType());
            }
            
            obs.setCadenceStart(obsXml.getCadenceStart());
            obs.setCadenceEnd(obsXml.getCadenceEnd());
            obs.setMjdStart(obsXml.getMjdStart());
            obs.setMjdEnd(obsXml.getMjdEnd());
            obs.setTargetTableId(obsXml.getTargetTableId());
            
            log.debug("Loaded Observation: " + obs);
            
            entries.add(obs);
        }
        return entries;
    }

    public void writeToFile(List<ObservingLog> entries, String destinationPath) throws IOException{
        File destinationFile = new File(destinationPath);
        if (destinationFile.exists() && destinationFile.isDirectory()) {
            throw new IllegalArgumentException("destinationPath exists and is a directory: " + destinationFile);
        }

        log.info("Exporting " + entries.size() + " observing logs to: " + destinationFile);

        ObservingLogDocument obsLogDocument = ObservingLogDocument.Factory.newInstance();
        ObservingLogXB obsLogXmlBean = obsLogDocument.addNewObservingLog();

        for (ObservingLog obs : entries) {
            ObservationXB obsXml = obsLogXmlBean.addNewObservation();

            obsXml.setQuarter(obs.getQuarter());
            obsXml.setMonth(obs.getMonth());
            obsXml.setSeason(obs.getSeason());
            
            if(obs.getCadenceType() == Cadence.CADENCE_LONG){
                obsXml.setCadenceType(CadenceTypeStr.LONG);
            }else if(obs.getCadenceType() == Cadence.CADENCE_SHORT){
                obsXml.setCadenceType(CadenceTypeStr.SHORT);
            }else{
                throw new PipelineException("Unexpected cadenceType: " + obs.getCadenceType());
            }
            
            obsXml.setCadenceStart(obs.getCadenceStart());
            obsXml.setCadenceEnd(obs.getCadenceEnd());
            obsXml.setMjdStart(obs.getMjdStart());
            obsXml.setMjdEnd(obs.getMjdEnd());
            obsXml.setTargetTableId(obs.getTargetTableId());
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!obsLogDocument.validate(xmlOptions)) {
            throw new PipelineException("Export ObservingLog failed: XML validation errors: " + errors);
        }

        obsLogDocument.save(destinationFile, xmlOptions);
    }
    
    public static void main(String[] args) {
    }
}

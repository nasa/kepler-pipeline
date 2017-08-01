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

package gov.nasa.kepler.dr.dataanomaly;

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.dr.dataAnomaly.CadenceTypeXB;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyListDocument;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyListXB;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyTypeXB;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyXB;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.KeplerHibernateConfiguration;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.hibernate.dr.DataAnomalyModel;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.pi.ModelOperationsFactory;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class exports {@link DataAnomaly} pojos to a data anomaly xml file.
 * 
 * @author Miles Cote
 * @author Todd Klaus
 * 
 */
public class DataAnomalyExporter {

    public void export(List<DataAnomaly> dataAnomalies, File file,
        boolean includeRevision) throws IOException {
        export(dataAnomalies, file, -1, includeRevision);
    }

    public void export(List<DataAnomaly> dataAnomalies, File file,
        long pipelineInstanceId, boolean includeRevision) throws IOException {
        DataAnomalyListDocument doc = DataAnomalyListDocument.Factory.newInstance();
        DataAnomalyListXB dataAnomalyListXB = doc.addNewDataAnomalyList();

        if (pipelineInstanceId == -1) {
            dataAnomalyListXB.setVersion("latest");
        } else {
            dataAnomalyListXB.setVersion("pipeline instance ID: "
                + pipelineInstanceId);
        }

        Calendar c = Calendar.getInstance();
        c.setTime(KeplerSocVersion.getBuildDate());
        dataAnomalyListXB.setExportTime(c);
        Configuration config = ConfigurationServiceFactory.getInstance();
        dataAnomalyListXB.setDatabaseUrl(config.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_URL_PROP));
        dataAnomalyListXB.setDatabaseUser(config.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_USERNAME_PROP));

        for (DataAnomaly dataAnomaly : dataAnomalies) {
            DataAnomalyXB dataAnomalyXB = dataAnomalyListXB.addNewDataAnomaly();
            dataAnomalyXB.setType(getDataAnomalyTypeXB(dataAnomaly.getDataAnomalyType()));
            dataAnomalyXB.setCadenceType(getCadenceTypeXB(CadenceType.valueOf(dataAnomaly.getCadenceType())));
            dataAnomalyXB.setStartCadence(dataAnomaly.getStartCadence());
            dataAnomalyXB.setEndCadence(dataAnomaly.getEndCadence());
            if (includeRevision) {
                dataAnomalyXB.setRevision(dataAnomaly.getRevision());
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new IllegalArgumentException("XML validation error.\n  "
                + errors);
        }

        doc.save(file, xmlOptions);
    }

    public static DataAnomalyTypeXB.Enum getDataAnomalyTypeXB(
        DataAnomalyType type) {
        return DataAnomalyTypeXB.Enum.forString(type.toString());
    }

    public static CadenceTypeXB.Enum getCadenceTypeXB(CadenceType type) {
        return CadenceTypeXB.Enum.forString(type.toString());
    }

    public static void main(String[] args) throws IOException {
        if (args.length != 1) {
            System.err.println("USAGE: da-export FILENAME");
            System.exit(-1);
        }

        ModelOperations<DataAnomalyModel> modelOperations = ModelOperationsFactory.getDataAnomalyInstance(new ModelMetadataRetrieverLatest());
        List<DataAnomaly> anomalies = modelOperations.retrieveModel()
            .getDataAnomalies();
        File f = new File(args[0]);

        DataAnomalyExporter exporter = new DataAnomalyExporter();
        exporter.export(anomalies, f, true);
    }

}

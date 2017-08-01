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
import gov.nasa.kepler.dr.dataAnomaly.CadenceTypeXB;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyListDocument;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyListXB;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyTypeXB;
import gov.nasa.kepler.dr.dataAnomaly.DataAnomalyXB;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlException;
import org.apache.xmlbeans.XmlOptions;

/**
 * This class imports a data anomaly xml file into {@link DataAnomaly} pojos.
 * 
 * @author Miles Cote
 * 
 */
public class DataAnomalyImporter {

    public List<DataAnomaly> importFile(File file) throws XmlException,
        IOException {
        DataAnomalyListDocument doc = DataAnomalyListDocument.Factory.parse(file);

        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new IllegalArgumentException("XML validation error.\n  "
                + errors);
        }

        DataAnomalyListXB dataAnomalyListXb = doc.getDataAnomalyList();
        DataAnomalyXB[] dataAnomalyList = dataAnomalyListXb.getDataAnomalyArray();
        List<DataAnomaly> returnValue = new ArrayList<DataAnomaly>();
        for (DataAnomalyXB dataAnomalyXB : dataAnomalyList) {
            DataAnomalyType dataAnomalyType = getDataAnomalyType(dataAnomalyXB.getType());
            CadenceType cadenceType = getCadenceType(dataAnomalyXB.getCadenceType());
            int startCadence = dataAnomalyXB.getStartCadence();
            int endCadence = dataAnomalyXB.getEndCadence();

            /*
             * Note that the revision from the XML file (if present) is ignored
             * by the importer. The imported anomalies will have their revision
             * field set by DataAnomalyModelCrud based on the current contents
             * of the database
             */

            returnValue.add(new DataAnomaly(dataAnomalyType,
                cadenceType.intValue(), startCadence, endCadence));
        }

        return returnValue;
    }

    public static DataAnomalyType getDataAnomalyType(DataAnomalyTypeXB.Enum type) {
        return DataAnomalyType.valueOf(type.toString());
    }

    public static CadenceType getCadenceType(CadenceTypeXB.Enum type) {
        return CadenceType.valueOf(type.toString());
    }

}

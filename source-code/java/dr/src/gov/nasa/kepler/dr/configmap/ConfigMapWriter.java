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

package gov.nasa.kepler.dr.configmap;

import gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic;
import gov.nasa.kepler.dr.dispatch.Writer;
import gov.nasa.kepler.hibernate.dr.ConfigMap;

import java.io.FileWriter;
import java.util.Map.Entry;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.output.XMLOutputter;

/**
 * Writes config maps.
 * 
 * @author Miles Cote
 * 
 */
public class ConfigMapWriter implements Writer<ConfigMap> {

    private final FileWriter fileWriter;

    public ConfigMapWriter(FileWriter fileWriter) {
        this.fileWriter = fileWriter;
    }

    @Override
    public void write(ConfigMap configMap) {
        try {
            Element root = new Element("sc-cfg-id-map");
            root.addContent("\n");

            for (Entry<String, String> entry : configMap.getMap()
                .entrySet()) {
                root.addContent("    ");

                Element element = new Element("element");
                element.setName(entry.getKey());
                element.setText(getValue(entry));
                root.addContent(element);

                root.addContent("\n");
            }

            XMLOutputter xmlOutputter = new XMLOutputter();
            xmlOutputter.output(new Document(root), fileWriter);
            fileWriter.close();
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to write.", e);
        }
    }

    private String getValue(Entry<String, String> entry) {
        String value = entry.getValue();

        if (entry.getKey()
            .equals(ConfigMapMnemonic.fgsFramesPerIntegration.mnemonic())) {
            value = String.valueOf(Integer.valueOf(value)
                - ConfigMapReader.FDMINTPER_INCREMENT_VALUE);
        }

        return value;
    }

}

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

import static com.google.common.collect.Maps.newLinkedHashMap;
import gov.nasa.kepler.common.ConfigMap.ConfigMapMnemonic;
import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.dr.dispatch.Reader;
import gov.nasa.kepler.hibernate.dr.ConfigMap;

import java.io.FileReader;
import java.util.List;
import java.util.Map;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;

/**
 * Reads config maps.
 * 
 * @author tklaus
 * @author Miles Cote
 * 
 */
public class ConfigMapReader implements Reader<ConfigMap> {

    public static final int FDMINTPER_INCREMENT_VALUE = 2;

    private final FileReader fileReader;

    public ConfigMapReader(FileReader fileReader) {
        this.fileReader = fileReader;
    }

    @Override
    public ConfigMap read() {
        try {
            SAXBuilder saxBuilder = new SAXBuilder();
            Document doc = saxBuilder.build(fileReader);
            fileReader.close();

            @SuppressWarnings("unchecked")
            List<Element> children = doc.getRootElement()
                .getChildren();

            Map<String, String> map = newLinkedHashMap();
            for (Element element : children) {
                String name = element.getName();
                String value = getValue(name, element.getText());

                map.put(name, value);
            }

            String scConfigIdString = getValue(map,
                ConfigMapMnemonic.scConfigId.mnemonic());
            int scConfigId = Integer.parseInt(scConfigIdString);

            String kplrTimestampString = getValue(map,
                ConfigMapMnemonic.mjd.mnemonic());
            double mjd = ModifiedJulianDate.dateToMjd(DateUtils.parseLikeDmc(kplrTimestampString));

            return new ConfigMap(scConfigId, mjd, map);
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to read.", e);
        }
    }

    private String getValue(String name, String text) {
        String value = text;

        if (name.equals(ConfigMapMnemonic.fgsFramesPerIntegration.mnemonic())) {
            value = String.valueOf(Integer.valueOf(value)
                + ConfigMapReader.FDMINTPER_INCREMENT_VALUE);
        }

        return value;
    }

    private String getValue(Map<String, String> map, String key) {
        String value = map.get(key);
        if (value == null) {
            throw new IllegalArgumentException("The key must exist in the map."
                + "\n  key: " + key);
        }

        return value;
    }

}

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

package gov.nasa.kepler.common;

import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

/**
 * This is the Persistable version of the ConfigMap that is passed to the matlab
 * pipeline modules.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * 
 */
public class ConfigMap implements Persistable {

    public static enum ConfigMapMnemonic {
        scConfigId("TCSCCFGID"),
        mjd("timestamp"),

        /** This value has been corrected by DR. */
        fgsFramesPerIntegration("FDMINTPER"),
        millisecondsPerFgsFrame("GSprm_FGSPER"),
        millisecondsPerReadout("GSprm_ROPER"),

        integrationsPerShortCadence("FDMSCPER"),
        shortCadencesPerLongCadence("FDMLCPER"),
        longCadencesPerBaseline("FDMNUMLCPERBL"),
        integrationsPerScienceFfi("FDMLDEFFINUM"),

        smearStartRow("FDMSMRROWSTART"),
        smearEndRow("FDMSMRROWEND"),
        smearStartCol("FDMSMRCOLSTART"),
        smearEndCol("FDMSMRCOLEND"),
        maskedStartRow("FDMMSKROWSTART"),
        maskedEndRow("FDMMSKROWEND"),
        maskedStartCol("FDMMSKCOLSTART"),
        maskedEndCol("FDMMSKCOLEND"),
        darkStartRow("FDMDRKROWSTART"),
        darkEndRow("FDMDRKROWEND"),
        darkStartCol("FDMDRKCOLSTART"),
        darkEndCol("FDMDRKCOLEND"),

        lcRequantFixedOffset("FDMLCOFFSET"),
        scRequantFixedOffset("FDMSCOFFSET"),
        
        focalPlaneTemperatureSetPointDn("PEDFPAHCSETPT");

        private String mnemonic;

        private ConfigMapMnemonic(String mnemonic) {
            this.mnemonic = mnemonic;
        }

        public String mnemonic() {
            return mnemonic;
        }
    }

    /**
     * % 'TCSCCFGID' % 'Timestamp'
     */
    @ProxyIgnore
    public static final String TIME_ENTRY_NAME = "Timestamp";
    @ProxyIgnore
    public static final String ID_ENTRY_NAME = "TCSCCFGID";

    /** spacecraft config id.   A monotonically increasing number that is a
     * unique id.
     */
    private int id; 
    /** The time this map went into effect. */
    private double time;

    /** A (key,value) pair for every config item. */
    private List<ConfigMapEntry> entries = new ArrayList<ConfigMapEntry>();

    @ProxyIgnore
    private Integer fgsFramesPerIntegration;
    @ProxyIgnore
    private Double millisecondsPerFgsFrame;
    @ProxyIgnore
    private Double millisecondsPerReadout;
    @ProxyIgnore
    private Integer integrationsPerShortCadence;
    
    @ProxyIgnore
    private Integer shortCadencesPerLongCadence;
    
    public double getSecondsPerShortCadence() {
        if (fgsFramesPerIntegration == null) {
            ConfigMapEntry entry = getConfigMapEntry(ConfigMapMnemonic.fgsFramesPerIntegration);
            fgsFramesPerIntegration = Integer.valueOf(entry.getValue());
        }
        if (millisecondsPerFgsFrame == null) {
            ConfigMapEntry entry = getConfigMapEntry(ConfigMapMnemonic.millisecondsPerFgsFrame);
            millisecondsPerFgsFrame = Double.valueOf(entry.getValue());
        }
        if (millisecondsPerReadout == null) {
            ConfigMapEntry entry = getConfigMapEntry(ConfigMapMnemonic.millisecondsPerReadout);
            millisecondsPerReadout = Double.valueOf(entry.getValue());
        }
        if (integrationsPerShortCadence == null) {
            ConfigMapEntry entry = getConfigMapEntry(ConfigMapMnemonic.integrationsPerShortCadence);
            integrationsPerShortCadence = Integer.valueOf(entry.getValue());
        }
        
        return ConfigMapDerivedValues.getSecondsPerShortCadence(
            fgsFramesPerIntegration, millisecondsPerFgsFrame,
            millisecondsPerReadout, integrationsPerShortCadence);
    }

    public int getShortCadencesPerLongCadence() {
        if (shortCadencesPerLongCadence == null) {
            ConfigMapEntry entry = getConfigMapEntry(ConfigMapMnemonic.shortCadencesPerLongCadence);
            shortCadencesPerLongCadence = Integer.valueOf(entry.getValue());
        }
        
        return shortCadencesPerLongCadence;
    }
    
    private ConfigMapEntry getConfigMapEntry(ConfigMapMnemonic mnemonic) {
        for (ConfigMapEntry entry : entries) {
            if (mnemonic.mnemonic().equals(entry.getMnemonic())) {
                return entry;
            }
        }
        
        return null;
    }

    public ConfigMap() {
    }

    public ConfigMap(int id, double mjd) {
        this.id = id;
        this.time = mjd;
    }

    public ConfigMap(int id, double mjd, List<ConfigMapEntry> entries) {
        this(id, mjd);
        this.entries.addAll(entries);
    }

    public ConfigMap(int id, double mjd, Map<String, String> entries) {
        this(id, mjd);

        for (Map.Entry<String, String> e : entries.entrySet()) {
            String key = e.getKey();
            // Remove these redundant entries because they cause confusion
            // for Hema's config map code.
            if (key.equals(TIME_ENTRY_NAME) || key.equals(ID_ENTRY_NAME)) {
                continue;
            }
            this.entries.add(new ConfigMapEntry(e.getKey(), e.getValue()));
        }
    }

    public ConfigMap(PlannedSpacecraftConfigParameters parameters) {
        this.id = parameters.getScConfigId();
        this.time = parameters.getMjd();

        List<ConfigMapEntry> entriesList = new ArrayList<ConfigMapEntry>();

        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.fgsFramesPerIntegration.mnemonic(),
            String.valueOf(parameters.getFgsFramesPerIntegration())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.millisecondsPerFgsFrame.mnemonic(),
            String.valueOf(parameters.getMillisecondsPerFgsFrame())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.millisecondsPerReadout.mnemonic(),
            String.valueOf(parameters.getMillisecondsPerReadout())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.integrationsPerShortCadence.mnemonic(),
            String.valueOf(parameters.getIntegrationsPerShortCadence())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.shortCadencesPerLongCadence.mnemonic(),
            String.valueOf(parameters.getShortCadencesPerLongCadence())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.longCadencesPerBaseline.mnemonic(),
            String.valueOf(parameters.getLongCadencesPerBaseline())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.integrationsPerScienceFfi.mnemonic(),
            String.valueOf(parameters.getIntegrationsPerScienceFfi())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.smearStartRow.mnemonic(),
            String.valueOf(parameters.getSmearStartRow())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.smearEndRow.mnemonic(),
            String.valueOf(parameters.getSmearEndRow())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.smearStartCol.mnemonic(),
            String.valueOf(parameters.getSmearStartCol())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.smearEndCol.mnemonic(),
            String.valueOf(parameters.getSmearEndCol())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.maskedStartRow.mnemonic(),
            String.valueOf(parameters.getMaskedStartRow())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.maskedEndRow.mnemonic(),
            String.valueOf(parameters.getMaskedEndRow())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.maskedStartCol.mnemonic(),
            String.valueOf(parameters.getMaskedStartCol())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.maskedEndCol.mnemonic(),
            String.valueOf(parameters.getMaskedEndCol())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.darkStartRow.mnemonic(),
            String.valueOf(parameters.getDarkStartRow())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.darkEndRow.mnemonic(),
            String.valueOf(parameters.getDarkEndRow())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.darkStartCol.mnemonic(),
            String.valueOf(parameters.getDarkStartCol())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.darkEndCol.mnemonic(),
            String.valueOf(parameters.getDarkEndCol())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.lcRequantFixedOffset.mnemonic(),
            String.valueOf(parameters.getLcRequantFixedOffset())));
        entriesList.add(new ConfigMapEntry(
            ConfigMapMnemonic.scRequantFixedOffset.mnemonic(),
            String.valueOf(parameters.getScRequantFixedOffset())));

        this.entries = entriesList;
    }

    public List<ConfigMapEntry> getEntries() {
        return Collections.unmodifiableList(entries);
    }

    @Override
    public String toString() {
        StringBuilder bldr = new StringBuilder();
        for (ConfigMapEntry entry : entries) {
            bldr.append("  ").append(entry.getMnemonic()).append(" = ")
            .append(entry.getValue()).append('\n');
        }

        return bldr.toString();
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = super.hashCode();
        result = PRIME * result + ((entries == null) ? 0 : entries.hashCode());
        result = PRIME * result + id;
        long temp;
        temp = Double.doubleToLongBits(time);
        result = PRIME * result + (int) (temp ^ (temp >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (getClass() != obj.getClass())
            return false;
        final ConfigMap other = (ConfigMap) obj;
        if (entries == null) {
            if (other.entries != null)
                return false;
        } else if (!entries.equals(other.entries))
            return false;
        if (id != other.id)
            return false;
        if (Double.doubleToLongBits(time) != Double.doubleToLongBits(other.time))
            return false;
        return true;
    }

    public int getId() {
        return id;
    }

    public double getTime() {
        return time;
    }

    public void put(String name, String value) {
        entries.add(new ConfigMapEntry(name, value));
    }

    public void add(ConfigMapEntry entry) {
        entries.add(entry);
    }

    public boolean isEmpty() {
        return entries.isEmpty();
    }

    public int size() {
        return entries.size();
    }

    public void clear() {
        entries.clear();
    }

    public String get(String name) throws Exception {
        for (ConfigMapEntry entry : entries) {
            if (entry.getMnemonic()
                .equals(name)) {
                return entry.getValue();
            }
        }
        throw new Exception("no entry for mnemonic " + name
            + " in ConfigMap for scConfigId=" + id);
    }

    public int getInt(ConfigMapMnemonic mnemonic) throws Exception {
        return Integer.parseInt(get(mnemonic.mnemonic()));
    }

    public int getInt(String name) throws Exception {
        return Integer.parseInt(get(name));
    }

    public double getDouble(ConfigMapMnemonic mnemonic) throws Exception {
        return Double.parseDouble(get(mnemonic.mnemonic()));
    }

    public double getDouble(String name) throws Exception {
        return Double.parseDouble(get(name));
    }
    
    /**
     * Like get(String name) except this not throw a checked exception.
     */
    public String getNotChecked(String name) {
        for (ConfigMapEntry entry : entries) {
            if (entry.getMnemonic()
                .equals(name)) {
                return entry.getValue();
            }
        }
        throw new IllegalArgumentException("no entry for mnemonic " + name
            + " in ConfigMap for scConfigId=" + id);
    }
    
    public int getIntNotChecked(ConfigMapMnemonic mnemonic) {
        return Integer.parseInt(getNotChecked(mnemonic.mnemonic()));
    }

    public double getDoubleNotChecked(ConfigMapMnemonic mnemonic) {
        return Double.parseDouble(getNotChecked(mnemonic.mnemonic()));
    }
    
    public static String configMapsShouldHaveUniqueValue(Collection<ConfigMap> configMaps, ConfigMapMnemonic mnemonic) {
        return configMapsShouldHaveUniqueValue(configMaps, mnemonic.mnemonic());
    }
    
    /**
     * 
     * @param configMaps
     * @param mnemonic
     * @return A non-null value.
     */
    public static String configMapsShouldHaveUniqueValue(Collection<ConfigMap> configMaps, String mnemonic) {
        String value = null;
        for (ConfigMap configMap : configMaps) {
            String currentValue;
            try {
                currentValue = configMap.get(mnemonic);
            } catch (Exception e) {
                //I'm not sure why get() needs to throw Exception.
                throw new IllegalStateException(e);
            }
            if (value == null) {
                value = currentValue;
            } else if (!value.equals(currentValue)) {
                throw new IllegalStateException("config maps do not match for mnemonic \"" + mnemonic + "\".");
            }
        }
        
        if (value == null) {
            throw new IllegalStateException("Missing config map value for mnemonic \"" + mnemonic + "\".");
        }
        return value;
    }

}

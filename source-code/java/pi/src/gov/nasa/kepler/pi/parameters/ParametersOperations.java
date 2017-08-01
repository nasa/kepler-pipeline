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

package gov.nasa.kepler.pi.parameters;

import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Utility functions for managing the parameter library.
 * 
 * @author Forrest Girouard
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class ParametersOperations {
    private static final Log log = LogFactory.getLog(ParametersOperations.class);

    private final PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
    private final PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();
    private final TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
    private final ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
    private final PipelineOperations pipelineOperations = new PipelineOperations();

    /**
     * Export the current parameter library to the specified directory. The
     * exported files consist of one file per {@link ParameterSet} (in
     * .properties format) and one metadata file.
     * 
     * If destinationDir exists, it must be a directory.
     * 
     * @param destinationPath
     * @throws IOException
     */
    public List<ParameterSetDescriptor> exportParameterLibrary(
        String destinationPath, List<String> excludeList, boolean dryRun)
        throws IOException {
        ParameterSetCrud parameterCrud = new ParameterSetCrud();
        List<ParameterSet> parameters = parameterCrud.retrieveLatestVersions();

        return exportParameterSets(destinationPath, excludeList, dryRun,
            parameters);
    }

    private List<ParameterSetDescriptor> exportParameterSets(
        String destinationPath, List<String> excludeList, boolean dryRun,
        List<ParameterSet> parameters) throws IOException {
        List<ParameterSetDescriptor> entries = new LinkedList<ParameterSetDescriptor>();

        for (ParameterSet paramSet : parameters) {
            String name = paramSet.getName()
                .getName();
            if (excludeList != null && excludeList.contains(name)) {
                // skip
                log.info("Skipping: " + name
                    + " because it's on the exclude list");
                continue;
            }

            BeanWrapper<Parameters> bean = paramSet.getParameters();
            String className = "";
            try {
                className = bean.getClazz()
                    .getName();
            } catch (PipelineException e) {
                // skip
                log.info("Skipping: " + name
                    + " because the class no longer exists :" + e.getMessage());
                continue;
            }

            ParameterSetDescriptor parameterSetDescriptor = new ParameterSetDescriptor(
                name, className);
            parameterSetDescriptor.setLibraryParamSet(paramSet);
            parameterSetDescriptor.setState(ParameterSetDescriptor.State.EXPORT);
            entries.add(parameterSetDescriptor);
        }

        if (!dryRun) {
            log.info("Writing parameter library export XML file");
            ParameterLibraryXml xmlFile = new ParameterLibraryXml();
            xmlFile.writeToFile(entries, destinationPath);
        }

        return entries;
    }

    /**
     * Imports the contents of the specified file or directory into the
     * parameter library. Directories are recursed in-order. Parameter sets in
     * the library whose name matches an entry in the exclude list will not be
     * imported. If the {@code dryRun} flag is {@code true}, the library will
     * not be modified, but the {@code ParameterSetDescriptor} will be populated
     * and the state will indicate the operation that would have taken effect if
     * {@code dryRun} had been set to {@code false}.
     * 
     * @param sourceFile the file or directory to import
     * @param excludeList contains a list of parameter set names which should
     * not be imported
     * @param dryRun if {@code true}, {@link ParameterSetDescriptor} will be
     * populated, but the library will not be changed
     * @return list of {@link ParameterSetDescriptor}s
     * @throws IOException if there were problems reading the parameter files
     */
    public List<ParameterSetDescriptor> importParameterLibrary(File sourceFile,
        List<String> excludeList, boolean dryRun) throws Exception {

        List<ParameterSetDescriptor> results = null;

        if (sourceFile.isDirectory()) {
            results = new ArrayList<ParameterSetDescriptor>();

            // Skip subversion directories.
            if (sourceFile.getName()
                .equals(".svn")) {
                return results;
            }

            // Load all of the .xml files in the directory in lexicographic
            // order. Recurse directories in-order.
            File[] files = sourceFile.listFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.endsWith(".xml")
                        || new File(dir, name).isDirectory();
                }
            });
            Arrays.sort(files);
            for (File file : files) {
                if (file.isDirectory()) {
                    results.addAll(importParameterLibrary(file, excludeList,
                        dryRun));
                } else {
                    results.addAll(importParameterLibrary(
                        file.getAbsolutePath(), excludeList, dryRun));
                }
            }
        } else {
            results = importParameterLibrary(sourceFile.getAbsolutePath(),
                excludeList, dryRun);
        }

        return results;
    }

    /**
     * Import the contents of the specified directory into the parameter
     * library. Parameter sets in the library whose name matches an entry in the
     * exclude list will not be imported. If the dryRun flag is true, the
     * library will not be modified, but the ParameterImportResults will be
     * populated and the state will indicate the operation that would have taken
     * effect if dryRun was set to true.
     * 
     * @param sourcePath
     * @param excludeList Will not be imported
     * @param dryRun If true, ParameterImportResults will be populated, but
     * library will not be changed.
     * @return
     * @throws IOException
     */
    public List<ParameterSetDescriptor> importParameterLibrary(
        String sourcePath, List<String> excludeList, boolean dryRun)
        throws Exception {
        ParameterLibraryXml paramLibXml = new ParameterLibraryXml();

        Reader inputReader = null;
        List<ParameterSetDescriptor> entries = null;
        try {
            if (sourcePath.equals("-")) {
                inputReader = new InputStreamReader(System.in);
            } else {
                inputReader = new FileReader(sourcePath);
            }
            entries = paramLibXml.readFromReader(inputReader);
        } finally {
            FileUtil.close(inputReader);
        }

        log.info("Importing " + entries.size() + " parameter sets from: "
            + sourcePath + ", dryRun = " + dryRun);

        if (paramLibXml.isOverrideOnly()) {
            for (ParameterSetDescriptor desc : entries) {
                ParameterSet currentParamSet = parameterSetCrud.retrieveLatestVersionForName(desc.getName());
                if (currentParamSet == null) {
                    throw new PipelineException("OverrideOnly is true, but "
                        + desc.getName()
                        + " does not exist in the parameter library");
                }
            }
        }

        for (ParameterSetDescriptor desc : entries) {
            String name = desc.getName();

            if (excludeList != null && excludeList.contains(name)) {
                // skip
                log.info("Skipping: " + name
                    + " because it's on the exclude list");
                desc.setState(ParameterSetDescriptor.State.IGNORE);
                continue;
            }

            if (desc.getState() == ParameterSetDescriptor.State.CLASS_MISSING) {
                // skip
                log.info("Skipping: " + name + " because the class ("
                    + desc.getClassName() + ") was not found on the classpath");
                continue;
            }

            BeanWrapper<Parameters> importedParamsBean = desc.getImportedParamsBean();
            checkPrimitiveFormats(importedParamsBean);
            trimWhitespace(importedParamsBean);

            Parameters parametersInstance = importedParamsBean.getInstance();
            Map<String, String> parametersMap = importedParamsBean.getProps();

            /*
             * Reinitialize the bean with a newly-created instance from the
             * initial bean. This serves to launder the Map<String,String>
             * params created from the XML file through the associated Java
             * Parameters class, thereby eliminating false differences between
             * this instance and the existing instance in the comparison below.
             * 
             * For example, if the XML file contains numbers in double precision
             * for a field that is defined as float in the Java class, the
             * params Maps won't match even if the values are the same to single
             * precision if we don't do this.
             */
            importedParamsBean = new BeanWrapper<Parameters>(parametersInstance);

            desc.setFileProps(formatProps(parametersMap));

            ParameterSet currentParamSet = parameterSetCrud.retrieveLatestVersionForName(name);

            if (currentParamSet != null) {
                BeanWrapper<Parameters> currentParamsBean = currentParamSet.getParameters();

                desc.setLibraryProps(formatProps(currentParamsBean.getProps()));

                if (pipelineOperations.compareParameters(currentParamsBean,
                    importedParamsBean)) {
                    // same
                    desc.setState(ParameterSetDescriptor.State.SAME);
                    log.info("name: "
                        + name
                        + ", contents match parameter library, no update needed");
                } else {
                    // different
                    desc.setState(ParameterSetDescriptor.State.UPDATE);
                    log.info("name: "
                        + name
                        + ", contents do not match parameter library, update needed");
                    if (!dryRun) {
                        pipelineOperations.updateParameterSet(currentParamSet,
                            parametersInstance, false);
                    }
                }
            } else {
                // paramSet is null
                desc.setState(ParameterSetDescriptor.State.CREATE);
                log.info("name: " + name
                    + ", not in parameter library, create needed");
                if (!dryRun) {
                    ParameterSet newParamSet = new ParameterSet(name);
                    newParamSet.setDescription("Created by importParameterLibrary @ "
                        + new Date());
                    newParamSet.setParameters(importedParamsBean);
                    parameterSetCrud.create(newParamSet);
                }
            }
        }

        // find any param sets in library but not in import
        LinkedList<String> importNames = new LinkedList<String>();
        for (ParameterSetDescriptor importDesc : entries) {
            importNames.add(importDesc.getName());
        }

        List<ParameterSet> allLibraryEntries = parameterSetCrud.retrieveLatestVersions();
        for (ParameterSet libraryParamSet : allLibraryEntries) {
            String name = libraryParamSet.getName()
                .getName();

            if (!importNames.contains(name)) {
                BeanWrapper<Parameters> libraryParameters = libraryParamSet.getParameters();
                String className = "";
                try {
                    className = libraryParameters.getClazz()
                        .getName();
                } catch (PipelineException e) {
                    continue;
                }
                ParameterSetDescriptor newDesc = new ParameterSetDescriptor(
                    name, className);
                newDesc.setState(ParameterSetDescriptor.State.LIBRARY_ONLY);
                newDesc.setLibraryProps(formatProps(libraryParameters.getProps()));
                entries.add(newDesc);
            }
        }

        return entries;
    }

    private void checkPrimitiveFormats(
        BeanWrapper<Parameters> importedParamsBean) throws Exception {
        Parameters instance = importedParamsBean.getInstance();
        Map<String, String> allProps = importedParamsBean.getProps();

        for (Entry<String, String> entry : allProps.entrySet()) {
            try {
                Field field = instance.getClass()
                    .getDeclaredField(entry.getKey());
                Class<?> type = field.getType();
                String value = entry.getValue();
                if (type.equals(byte.class)) {
                    Byte.valueOf(value);
                } else if (type.equals(short.class)) {
                    Short.valueOf(value);
                } else if (type.equals(int.class)) {
                    Integer.valueOf(value);
                } else if (type.equals(long.class)) {
                    Long.valueOf(value);
                } else if (type.equals(float.class)) {
                    Float.valueOf(value);
                } else if (type.equals(double.class)) {
                    Double.valueOf(value);
                }
            } catch (NoSuchFieldException ignore) {
                // ignore fields that no longer exist in the class
            }
        }
    }

    private void trimWhitespace(BeanWrapper<Parameters> importedParamsBean)
        throws Exception {
        Map<String, String> allProps = importedParamsBean.getProps();

        Map<String, String> updatedProps = newHashMap();
        for (Entry<String, String> entry : allProps.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();

            if (value.contains(" ")) {
                if (value.contains(",")) {
                    String trimmedString = "";
                    for (String s : value.split(",")) {
                        trimmedString = trimmedString + s.trim() + ",";
                    }
                    value = trimmedString.substring(0,
                        trimmedString.length() - 1);
                } else {
                    value = value.trim();
                }
            }

            updatedProps.put(key, value);
        }

        importedParamsBean.setProps(updatedProps);
    }

    private String formatProps(Map<String, String> props) {
        String nl = System.getProperty("line.separator");
        StringBuilder report = new StringBuilder();

        for (String key : props.keySet()) {
            String value = props.get(key);

            report.append("  " + key + " = " + value + nl);
        }

        return report.toString();
    }

    /**
     * Exports parameters from a pipeline instance ID and a module name (e.g.
     * pdc) to an xml file.
     */
    public void exportPipelineInstanceParameters(long pipelineInstanceId,
        String moduleName, File xmlFile) {
        try {
            List<ParameterSet> parameterSets = new ArrayList<ParameterSet>();

            PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstanceId);
            if (pipelineInstance == null) {
                throw new IllegalArgumentException(
                    "pipelineInstance cannot be null."
                        + "\n  pipelineInstanceId: " + pipelineInstanceId);
            }

            parameterSets.addAll(pipelineInstance.getPipelineParameterSets()
                .values());

            PipelineInstanceNode node = null;
            for (PipelineInstanceNode pin : pipelineInstanceNodeCrud.retrieveAll(pipelineInstance)) {
                if (pin.getPipelineDefinitionNode()
                    .getModuleName()
                    .getName()
                    .equals(moduleName)) {
                    node = pin;
                }
            }

            if (node == null) {
                throw new IllegalArgumentException("node cannot be null."
                    + "\n  moduleName: " + moduleName);
            }

            parameterSets.addAll(node.getModuleParameterSets()
                .values());

            exportParameterSets(xmlFile.getAbsolutePath(),
                new ArrayList<String>(), false, parameterSets);
        } catch (IOException e) {
            throw new IllegalArgumentException("Unable to export.", e);
        }
    }

    /**
     * Imports a parameters from an xml file into a trigger name and module name
     * (e.g. pdc).
     */
    public void importTriggerParameters(File xmlFile, String triggerName,
        String moduleName) {
        try {
            if (!xmlFile.exists()) {
                throw new IllegalArgumentException(
                    "xmlFile cannot be missing.\n  xmlFile: " + xmlFile);
            }

            TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(triggerName);
            if (triggerDefinition == null) {
                throw new IllegalArgumentException(
                    "triggerDefinition cannot be null." + "\n  triggerName: "
                        + triggerName);
            }

            ParameterLibraryXml paramLibXml = new ParameterLibraryXml();
            List<ParameterSetDescriptor> entries = paramLibXml.readFromReader(new FileReader(
                xmlFile.getAbsolutePath()));

            Set<String> classNamesFromFile = new HashSet<String>();

            for (ParameterSetDescriptor desc : entries) {
                try {
                    Class.forName(desc.getClassName());
                } catch (ClassNotFoundException e) {
                    throw new IllegalArgumentException(
                        "class names from the xml file cannot be missing from the classpath."
                            + "\n  classNameFromFile: " + desc.getClassName());
                }

                if (classNamesFromFile.contains(desc.getClassName())) {
                    throw new IllegalArgumentException(
                        "The xml file cannot contain more than one instance of a class."
                            + "\n  duplicatedClassName: " + desc.getClassName());
                }
                classNamesFromFile.add(desc.getClassName());

                BeanWrapper<Parameters> importedParamsBean = desc.getImportedParamsBean();
                checkPrimitiveFormats(importedParamsBean);
                trimWhitespace(importedParamsBean);
                Parameters parametersInstance = importedParamsBean.getInstance();

                boolean foundDescInTrigger = updateParameterSet(desc,
                    parametersInstance,
                    triggerDefinition.getPipelineParameterSetNames());

                boolean foundModuleName = false;

                for (TriggerDefinitionNode node : triggerDefinition.getNodes()) {
                    if (node.getNodeModuleName()
                        .getName()
                        .equals(moduleName)) {
                        foundModuleName = true;
                        boolean foundDescInModule = updateParameterSet(desc,
                            parametersInstance,
                            node.getModuleParameterSetNames());
                        foundDescInTrigger = foundDescInTrigger
                            || foundDescInModule;
                    }
                }

                if (!foundModuleName) {
                    throw new IllegalArgumentException(
                        "moduleName cannot be missing from trigger."
                            + "\n  moduleName: " + moduleName
                            + "\n  triggerName: " + triggerName);
                }

                if (!foundDescInTrigger) {
                    throw new IllegalArgumentException(
                        "Parameter set class from file cannot be missing from trigger."
                            + "\n  parameterSetClassName: "
                            + desc.getClassName());
                }
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to import.", e);
        }
    }

    private boolean updateParameterSet(ParameterSetDescriptor desc,
        Parameters parametersInstance,
        Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames) {
        boolean foundDescInTrigger = false;
        for (ClassWrapper<Parameters> classWrapper : moduleParameterSetNames.keySet()) {
            if (classWrapper.getClassName()
                .equals(desc.getClassName())) {
                foundDescInTrigger = true;

                ParameterSetName parameterSetName = moduleParameterSetNames.get(classWrapper);
                ParameterSet currentParamSet = parameterSetCrud.retrieveLatestVersionForName(parameterSetName);

                pipelineOperations.updateParameterSet(currentParamSet,
                    parametersInstance, false);
            }
        }

        return foundDescInTrigger;
    }
}

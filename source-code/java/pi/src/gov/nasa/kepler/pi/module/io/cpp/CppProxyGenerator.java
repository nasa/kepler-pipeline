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

package gov.nasa.kepler.pi.module.io.cpp;

import gov.nasa.spiffy.common.persistable.ClassWalker;
import gov.nasa.spiffy.common.persistable.WalkerListener;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileWriter;
import java.lang.reflect.Field;
import java.util.LinkedList;
import java.util.List;
import java.util.Stack;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class utilizes ClassWalker to walk a hierarchy of java classes and
 * generate the equivelent C++ code, along with serialization code that
 * loads/saves the contents in the BinaryPersistable format.
 * 
 * @author tklaus
 * 
 */
public class CppProxyGenerator implements WalkerListener {
    private static final Log log = LogFactory.getLog(CppProxyGenerator.class);

    public static final String MODULE_LIST_PROP = "gen-cpp.modules";
    public static final String MODULE_PREFIX_PROP = "gen-cpp.module.";
    public static final String MODULE_INCDIR_PROP = ".incDir";
    public static final String MODULE_SRCDIR_PROP = ".srcDir";
    public static final String MODULE_CONTROLLER_INCDIR_PROP = ".controllerIncDir";
    public static final String MODULE_CONTROLLER_SRCDIR_PROP = ".controllerSrcDir";
    public static final String MODULE_CLASSES_PROP = ".classes";

    private String className = null;
    private List<Class<?>> rootClasses = new LinkedList<Class<?>>();
    private String incDir = null;
    private String srcDir = null;
    private Stack<CppTranslationUnit> cppUnits = new Stack<CppTranslationUnit>();
    private CppTranslationUnit currentUnit = null;

    /**
     * @param rootClazz
     * @throws ClassNotFoundException
     */
    public CppProxyGenerator(String name, String incDir, String srcDir, String... classNames) throws Exception {
        this.className = name;
        this.incDir = incDir;
        this.srcDir = srcDir;

        log.debug("CppProxyGenerator: name = " + name);
        log.debug("CppProxyGenerator: incDir = " + incDir);
        log.debug("CppProxyGenerator: srcDir = " + srcDir);

        FileUtils.forceMkdir(new File(incDir));
        FileUtils.forceMkdir(new File(srcDir));

        for (String className : classNames) {
            Class<?> clazz = Class.forName(className);
            rootClasses.add(clazz);
            log.debug("CppProxyGenerator: adding class = " + className);
        }
    }

    /**
     * Generates the code
     * 
     * @throws Exception
     */
    public void generate() throws Exception {
        for (Class<?> rootClazz : rootClasses) {
            log.info("CppProxyGenerator: Root class: " + rootClazz);
            ClassWalker walker = new ClassWalker(rootClazz);
            walker.addListener(this);
            walker.parse();
        }
    }

    /**
     * Implements WalkerListener.classStart
     */
    @Override
    public void classStart(Class<?> clazz) {
        if (currentUnit != null) {
            cppUnits.push(currentUnit);
        }
        currentUnit = new CppTranslationUnit(clazz.getSimpleName());
    }

    /**
     * Implements WalkerListener.classEnd
     */
    @Override
    public void classEnd(Class<?> clazz) throws Exception {

        FileWriter headerFile = new FileWriter(incDir + "/" + currentUnit.getClassName() + ".h");
        FileWriter codeFile = new FileWriter(srcDir + "/" + currentUnit.getClassName() + ".cpp");

        headerFile.write(currentUnit.header());
        codeFile.write(currentUnit.code());

        headerFile.close();
        codeFile.close();

        if (!cppUnits.empty()) {
            currentUnit = cppUnits.pop();
        } else {
            currentUnit = null;
        }
    }

    /**
     * Implements WalkerListener.classArrayField
     */
    @Override
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception {
        currentUnit.classArrayField(field, elementClass, dimensions);
    }

    /**
     * Implements WalkerListener.classField
     */
    @Override
    public void classField(Field field) throws Exception {
        currentUnit.classField(field);
    }

    /**
     * Implements WalkerListener.primitiveArrayField
     */
    @Override
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field, boolean preservePrecision) throws Exception {
        currentUnit.primitiveArrayField(name, classSimpleName, dimensions, field, preservePrecision);
    }

    /**
     * Implements WalkerListener.primitiveField
     */
    @Override
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision) throws Exception {
        currentUnit.primitiveField(name, classSimpleName, field, preservePrecision);
    }

    /**
     * Implements WalkerListener.unknownType
     */
    @Override
    public void unknownType(Field field) throws Exception {
        String name = field.getName();
        String canonicalClassName = field.getType().getCanonicalName();
        throw new UnsupportedOperationException("Supported types include primitives, String, Map, Set, List, and classes that implement Persistable.  Unknown type: " + canonicalClassName + ", name = " + name);
    }

    /**
     * Utility function used by main()
     * 
     * @param key
     * @return
     * @throws PipelineException
     */
    private static String getPropertyChecked(String key) {
        String value = System.getProperty(key);
        if (value == null || value.length() == 0) {
            throw new PipelineException("Missing/empty property " + key);
        }
        return value;
    }

    /**
     * command-line entry point for this class (used by the ant gen-cpp target)
     * 
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {

//        DOMConfigurator.configure(System.getProperty("log4j.configuration"));

        String moduleList = getPropertyChecked(MODULE_LIST_PROP);

        String[] modules = moduleList.split(",");
        for (int i = 0; i < modules.length; i++) {
            String incDir = getPropertyChecked(MODULE_PREFIX_PROP + modules[i] + MODULE_INCDIR_PROP);
            String srcDir = getPropertyChecked(MODULE_PREFIX_PROP + modules[i] + MODULE_SRCDIR_PROP);
            String classesList = getPropertyChecked(MODULE_PREFIX_PROP + modules[i] + MODULE_CLASSES_PROP);
            String[] classes = classesList.split(",");

            CppProxyGenerator proxyGenerator = new CppProxyGenerator(modules[i], incDir, srcDir, classes);
            proxyGenerator.generate();

            String controllerIncDir = getPropertyChecked(MODULE_PREFIX_PROP + modules[i] + MODULE_CONTROLLER_INCDIR_PROP);
            String controllerSrcDir = getPropertyChecked(MODULE_PREFIX_PROP + modules[i] + MODULE_CONTROLLER_SRCDIR_PROP);

            CppController controller = new CppController(modules[i], controllerIncDir, controllerSrcDir);
            controller.generate();
        }
    }

    /**
     * @return the incDir
     */
    public String getIncDir() {
        return incDir;
    }

    /**
     * @return the name
     */
    public String getName() {
        return className;
    }

    /**
     * @return the rootClasses
     */
    public List<Class<?>> getRootClasses() {
        return rootClasses;
    }

    /**
     * @return the srcDir
     */
    public String getSrcDir() {
        return srcDir;
    }
}

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

package gov.nasa.kepler.pi.module.io.matlab;

import gov.nasa.spiffy.common.persistable.ClassWalker;
import gov.nasa.spiffy.common.persistable.WalkerListener;

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
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class MatlabProxyGenerator implements WalkerListener {
    private static final Log log = LogFactory.getLog(MatlabProxyGenerator.class);

    private String moduleName = null;
    private List<Class<?>> rootClasses = new LinkedList<Class<?>>();
    private String mfilesGenDir = null;
    private String mfilesControllerDir = null;
    
    private Stack<MatlabReadFunction> readFunctionUnits = new Stack<MatlabReadFunction>();
    private Stack<MatlabWriteFunction> writeFunctionUnits = new Stack<MatlabWriteFunction>();
    
    private MatlabReadFunction currentReadFunction = null;
    private MatlabWriteFunction currentWriteFunction = null;

    private boolean topLevel = false;

    /**
     * @param rootClazz
     * @throws ClassNotFoundException
     */
    public MatlabProxyGenerator(String name, String mfilesGenDir, String mfilesControllerDir, String... classNames) throws Exception {
        this.moduleName = name;
        this.mfilesGenDir = mfilesGenDir;
        this.mfilesControllerDir = mfilesControllerDir;

        log.debug("MatlabProxyGenerator: name = " + this.moduleName);
        log.debug("MatlabProxyGenerator: mfilesGenDir = " + this.mfilesGenDir);
        log.debug("MatlabProxyGenerator: mfilesControllerDir = " + this.mfilesControllerDir);

        FileUtils.forceMkdir(new File(mfilesGenDir));

        for (String className : classNames) {
            Class<?> clazz = Class.forName(className);
            rootClasses.add(clazz);
            log.debug("MatlabProxyGenerator: adding class = " + className);
        }
    }

    /**
     * Generates the code
     * 
     * @throws Exception
     */
    public void generate() throws Exception {
        for (Class<?> rootClazz : rootClasses) {
            topLevel  = true;
            log.info("MatlabProxyGenerator: Root class: " + rootClazz);
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
        
        log.debug("MatlabProxyGenerator: generating code for " + clazz);

        if (currentReadFunction != null) {
            readFunctionUnits.push(currentReadFunction);
        }
        if (currentWriteFunction != null) {
            writeFunctionUnits.push(currentWriteFunction);
        }

        currentReadFunction = new MatlabReadFunction(clazz.getCanonicalName(), clazz.getSimpleName(), topLevel);
        currentWriteFunction = new MatlabWriteFunction(clazz.getCanonicalName(), clazz.getSimpleName(), topLevel);
        
        topLevel = false;
    }

    /**
     * Implements WalkerListener.classEnd
     */
    @Override
    public void classEnd(Class<?> clazz) throws Exception {

        FileWriter mFileLoad = new FileWriter(mfilesGenDir + "/" + currentReadFunction.getFunctionName() + ".m");
        FileWriter mFileSave = new FileWriter(mfilesGenDir + "/" + currentWriteFunction.getFunctionName() + ".m");

        mFileLoad.write(currentReadFunction.genFunctionContents());
        mFileSave.write(currentWriteFunction.genFunctionContents());

        mFileLoad.close();
        mFileSave.close();

        if (!readFunctionUnits.empty()) {
            currentReadFunction = readFunctionUnits.pop();
        } else {
            currentReadFunction = null;
        }

        if (!writeFunctionUnits.empty()) {
            currentWriteFunction = writeFunctionUnits.pop();
        } else {
            currentWriteFunction = null;
        }
    }

    /**
     * Ignore fields with $ in them such as those static
     * fields added by javac when assert is used.
     * 
     * @param f
     * @return
     */
    private boolean fieldFilter(Field f){
        boolean bad = f.getName().contains("$");
        return !bad;
    }
    
    /**
     * Implements WalkerListener.primitiveField
     */
    @Override
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision) throws Exception {
        if(fieldFilter(field)){
            currentReadFunction.addField(name, classSimpleName, true, preservePrecision);
            currentWriteFunction.addField(name, classSimpleName, true, preservePrecision);
        }
    }

    /**
     * Implements WalkerListener.classField
     */
    @Override
    public void classField(Field field) throws Exception {
        String fieldName = field.getName();
        String fieldClassSimpleName = field.getType().getSimpleName();
        if(fieldFilter(field)){
            currentReadFunction.addField(fieldName, fieldClassSimpleName, false, false);
            currentWriteFunction.addField(fieldName, fieldClassSimpleName, false, false);
        }
    }

    /**
     * Implements WalkerListener.unknownType
     */
    @Override
    public void unknownType(Field field) throws Exception {
        Class<?> fieldClass = field.getType();
        String fieldName = field.getName();
        throw new UnsupportedOperationException("Supported types include primitives, String, Map, Set, List, and classes that implement Persistable.  Unknown type: " + fieldClass + ", name = " + fieldName);
    }

    /**
     * Implements WalkerListener.primitiveArrayField
     */
    @Override
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field, boolean preservePrecision) throws Exception {
        if(fieldFilter(field)){
            currentReadFunction.addListField(name, classSimpleName, true, dimensions, preservePrecision);
            currentWriteFunction.addListField(name, classSimpleName, true, dimensions, preservePrecision);
        }
    }

    /**
     * Implements WalkerListener.classArrayField
     */
    @Override
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception {
        String fieldName = field.getName();
        String elementClassSimpleName = elementClass.getSimpleName(); 
        if(fieldFilter(field)){
            currentReadFunction.addListField(fieldName, elementClassSimpleName, false, dimensions, false);
            currentWriteFunction.addListField(fieldName, elementClassSimpleName, false, dimensions, false);
        }
    }
}

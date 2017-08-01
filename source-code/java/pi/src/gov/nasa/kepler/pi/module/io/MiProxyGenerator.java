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

package gov.nasa.kepler.pi.module.io;

import gov.nasa.kepler.pi.module.io.cpp.CppController;
import gov.nasa.kepler.pi.module.io.cpp.CppProxyGenerator;
import gov.nasa.kepler.pi.module.io.matlab.MatlabInit;
import gov.nasa.kepler.pi.module.io.matlab.MatlabMain;
import gov.nasa.kepler.pi.module.io.matlab.MatlabProxyGenerator;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.beanutils.converters.StringArrayConverter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class is a front-end for the {@link CppProxyGenerator} and {@link MatlabProxyGenerator}.
 * It is invoked by the build to generate the code into the matlab tree.
 * 
 * TODO: Remove CppProxyGenerator once all of the scientific programmers are switched over
 * to using the generated MATLAB code
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("deprecation")
public class MiProxyGenerator {
    private static final Log log = LogFactory.getLog(MiProxyGenerator.class);

    public static final String MODULE_LIST_PROP = "gen-proxy.modules";
    public static final String MODULE_PREFIX_PROP = "gen-proxy.module.";
    public static final String MODULE_CLASSES_PROP = ".classes";

    /** CppProxyGenerator properties */
    public static final String MODULE_INCDIR_PROP = ".incDir";
    public static final String MODULE_SRCDIR_PROP = ".srcDir";
    public static final String MODULE_CONTROLLER_INCDIR_PROP = ".controllerIncDir";
    public static final String MODULE_CONTROLLER_SRCDIR_PROP = ".controllerSrcDir";

    /** MatlabProxyGenerator properties */
    public static final String MODULE_MATLAB_ONLY_PROP = "gen-proxy.matlabOnly";
    public static final String MODULE_MFILES_GEN_DIR_PROP = ".mfilesGenDir";
    public static final String MODULE_MFILES_CONTROLLER_INCDIR_PROP = ".mfilesDir";

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

    private static void generate() throws Exception{
        StringArrayConverter converter = new StringArrayConverter();

        String moduleList = getPropertyChecked(MODULE_LIST_PROP);
        String matlabOnly = System.getProperty(MODULE_MATLAB_ONLY_PROP);
        
        String[] modules = (String[]) converter.convert(String.class, moduleList);
        for (int i = 0; i < modules.length; i++) {
            String classesList = getPropertyChecked(MODULE_PREFIX_PROP + modules[i] + MODULE_CLASSES_PROP);
            String[] classes = (String[]) converter.convert(String.class, classesList);

            MiProxyGenerator.generateMatlab(modules[i], classes);
            
            if(matlabOnly == null){
                log.info("C++ code generator currently disabled");
                //MiProxyGenerator.generateCpp(modules[i], classes);
            }
        }
    }
    
    private static void generateMatlab(String module, String[] classes) throws Exception{
        log.info("Generating MATLAB proxy functions");
        
        String mfilesDir = getPropertyChecked(MODULE_PREFIX_PROP + module
            + MODULE_MFILES_CONTROLLER_INCDIR_PROP);
        String mfilesGenDir = getPropertyChecked(MODULE_PREFIX_PROP + module + MODULE_MFILES_GEN_DIR_PROP);

        MatlabProxyGenerator matlabProxyGenerator = new MatlabProxyGenerator(module, mfilesGenDir, mfilesDir,
            classes);
        matlabProxyGenerator.generate();

        if(classes.length != 2){
            log.info("Expected 2 classes, but found: " + classes.length + ", NOT generating MATLAB main function.");
        }else{
            String inputsClassName = classes[0].substring(classes[0].lastIndexOf('.')+1);
            String outputsClassName = classes[1].substring(classes[1].lastIndexOf('.')+1);
            MatlabInit matlabInit = new MatlabInit(module, mfilesGenDir);
            matlabInit.generate();
            MatlabMain matlabMain = new MatlabMain(module, inputsClassName, outputsClassName, mfilesGenDir);
            matlabMain.generate();
        }
    }
    
    /**
     * TODO: Will remove once all dependencies on the C++ code are removed from the MATLAB code.
     * 
     * @param module
     * @param classes
     * @throws Exception
     */
    @SuppressWarnings("unused")
    private static void generateCpp(String module, String[] classes) throws Exception{
        log.info("Generating C++ proxy classes");
        
        String incDir = getPropertyChecked(MODULE_PREFIX_PROP + module + MODULE_INCDIR_PROP);
        String srcDir = getPropertyChecked(MODULE_PREFIX_PROP + module + MODULE_SRCDIR_PROP);

        CppProxyGenerator cppProxyGenerator = new CppProxyGenerator(module, incDir, srcDir, classes);
        cppProxyGenerator.generate();

        String controllerIncDir = getPropertyChecked(MODULE_PREFIX_PROP + module + MODULE_CONTROLLER_INCDIR_PROP);
        String controllerSrcDir = getPropertyChecked(MODULE_PREFIX_PROP + module + MODULE_CONTROLLER_SRCDIR_PROP);

        CppController controller = new CppController(module, controllerIncDir, controllerSrcDir);
        controller.generate();
    }
    
    /**
     * command-line entry point for this class (used by the ant gen-proxy target)
     * 
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        MiProxyGenerator.generate();
    }
}

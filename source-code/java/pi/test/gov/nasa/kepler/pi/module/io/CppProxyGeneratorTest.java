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
import gov.nasa.kepler.services.process.ExternalProcess;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Properties;

import junit.framework.TestCase;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.xml.DOMConfigurator;

public class CppProxyGeneratorTest extends TestCase {

    /**
     * Clear any existing props
     */
    @Override
    public void setUp(){
        Properties props = System.getProperties();
        HashSet<Object> removeSet = new HashSet<Object>(); 
        for (Object key : props.keySet()) {
            if(((String)key).startsWith("gen-cpp")){
                removeSet.add(key);
            }
        }
        for (Object key : removeSet) {
            props.remove(key);
        }
    }

    /**
     * This test generates code for TestInputs and TestOutputs into a clean
     * directory (all files should be generated) Also, it uses the
     * CppProxyGenerator.main() (command-line interface)
     * 
     * @throws Exception
     */
    public void testNewOnCommandLine() throws Exception {

        String outDir = "generated2";
        File genDir = new File("testdata/CppProxyGenerator/" + outDir);

        FileUtils.deleteDirectory(genDir);
        FileUtils.forceMkdir(genDir);

        System.setProperty(CppProxyGenerator.MODULE_LIST_PROP, "Test");
        System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_INCDIR_PROP, genDir
            .getAbsolutePath());
        System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_SRCDIR_PROP, genDir
            .getAbsolutePath());
        System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_CONTROLLER_INCDIR_PROP, genDir
            .getAbsolutePath());
        System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_CONTROLLER_SRCDIR_PROP, genDir
            .getAbsolutePath());
        System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_CLASSES_PROP,
            "gov.nasa.kepler.pi.module.io.TestInputs,gov.nasa.kepler.pi.module.io.TestOutputs");

        CppProxyGenerator.main(new String[] {});

        File dir = new File("testdata/CppProxyGenerator");
        File exe = new File("/usr/bin/make");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("CSRCDIR=" + outDir);
        command.add("--warn-undefined-variables");
        command.add("clean");
        command.add("all");

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 30000);

        assertEquals("make failed for generated code,", 0, rc);
    }

    public void testBadCommandLineArgs() throws Exception {

        String outDir = "generated2";
        File genDir = new File("testdata/CppProxyGenerator/" + outDir);

        FileUtils.deleteDirectory(genDir);
        FileUtils.forceMkdir(genDir);

        try {
            CppProxyGenerator.main(new String[] {}); // missing args, should
                                                        // throw an exception!
        } catch (Exception e) {
            assertEquals("wrong exception", "Missing/empty property gen-cpp.modules", e
                .getMessage());
            return;
        }

        fail("CppProxyGenerator.main() did not throw exception for missing args");
    }

    public void testUnknownTypeMain() throws Exception {

        String outDir = "generated2";
        File genDir = new File("testdata/CppProxyGenerator/" + outDir);

        FileUtils.deleteDirectory(genDir);
        FileUtils.forceMkdir(genDir);

        try {
            System.setProperty(CppProxyGenerator.MODULE_LIST_PROP, "Test");
            System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_INCDIR_PROP, genDir
                .getAbsolutePath());
            System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_SRCDIR_PROP, genDir
                .getAbsolutePath());
            System.setProperty(CppProxyGenerator.MODULE_PREFIX_PROP + "Test" + CppProxyGenerator.MODULE_CLASSES_PROP,
                "gov.nasa.kepler.pi.module.io.BadClass");

            CppProxyGenerator.main(new String[] {});
        } catch (Exception e) {
            assertEquals("wrong exception", "Supported types include primitives, String, Map, Set, List, and classes that implement Persistable.  Unknown type: java.lang.Thread, name = t", e.getMessage());
            return;
        }

        fail("CppProxyGenerator.main() did not throw exception for unknown type");
    }

    public void testUnknownTypeDirect() throws Exception {

        String outDir = "generated2";
        File genDir = new File("testdata/CppProxyGenerator/" + outDir);

        FileUtils.deleteDirectory(genDir);
        FileUtils.forceMkdir(genDir);

        try {
            CppProxyGenerator proxyGen = new CppProxyGenerator("Test", genDir.getAbsolutePath(), genDir
                .getAbsolutePath(), "gov.nasa.kepler.pi.module.io.BadClass");
            proxyGen.generate();
        } catch (Exception e) {
            assertEquals("wrong exception", "Supported types include primitives, String, Map, Set, List, and classes that implement Persistable.  Unknown type: java.lang.Thread, name = t", e.getMessage());
            return;
        }

        fail("CppProxyGenerator.main() did not throw exception for unknown type");
    }

    /**
     * 
     * @throws Exception
     */
    public void testWithExisting() throws Exception {

        String outDir = "generated";
        File genDir = new File("testdata/CppProxyGenerator/" + outDir);

        FileUtils.forceMkdir(genDir);

        CppProxyGenerator proxyGen = new CppProxyGenerator("Test", genDir.getAbsolutePath(), genDir.getAbsolutePath(),
            "gov.nasa.kepler.pi.module.io.TestInputs", "gov.nasa.kepler.pi.module.io.TestOutputs");
        proxyGen.generate();

        CppController controllerGen = new CppController("Test", genDir.getAbsolutePath(), genDir.getAbsolutePath());
        controllerGen.generate();

        File dir = new File("testdata/CppProxyGenerator");
        File exe = new File("/usr/bin/make");

        LinkedList<String> command = new LinkedList<String>();
        command.add(exe.getCanonicalPath());
        command.add("CSRCDIR=" + outDir);
        command.add("--warn-undefined-variables");
        command.add("clean");
        command.add("all");

        ExternalProcess p = new ExternalProcess(command);
        p.directory(dir.getCanonicalFile());
        p.setLogStdOut(true);
        p.setLogStdErr(true);

        int rc = p.run(true, 30000);

        assertEquals("make failed for generated code,", 0, rc);
    }

    public static void main(String[] args) {
        DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);
        junit.textui.TestRunner.run(CppProxyGeneratorTest.class);
    }
}

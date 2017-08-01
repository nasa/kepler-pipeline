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

package gov.nasa.kepler.pi.module;

import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Reader;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashMap;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang.text.StrSubstitutor;
import org.apache.log4j.xml.DOMConfigurator;

public class GenModuleProject {

    private String templateDir = null;

    private String destDir = null;

    private String projectName = null;

    private String[] moduleNames = null;

    private StrSubstitutor sub;

    HashMap<String, String> map = new HashMap<String, String>();

    public GenModuleProject(String templateDir, String destDir,
        String projectName, String[] moduleNames) {
        this.templateDir = templateDir;
        this.destDir = destDir;
        this.projectName = projectName;
        this.moduleNames = moduleNames;

        map = new HashMap<String, String>();

        map.put("project.name", projectName);

        sub = new StrSubstitutor(map);
    }

    public void gen() throws IOException {
        genConfig();
        genXml();
        genSrc();
        genTest();
        genTopLevelFiles();
    }

    private void genConfig() throws IOException {
        File destFile = new File(destDir + "/config");

        FileUtils.deleteDirectory(destFile);
        FileUtils.copyDirectory(new File(templateDir + "/config"), destFile,
            false);
    }

    private void genXml() throws IOException {
        File destDirFile = new File(destDir + "/xml");

        FileUtils.deleteDirectory(destDirFile);
        destDirFile.mkdir();

        File srcFile = new File(templateDir + "/xml/parameter-set-1.0.xml.in");
        for (int i = 0; i < moduleNames.length; i++) {
            String moduleNameLower = moduleNames[i].toLowerCase();
            map.put("module.lower.name", moduleNameLower);

            File destFile = new File(destDir + "/xml/" + moduleNameLower
                + "-parameter-set-1.0.xml");
            copyAndSubstituteProps(new FileReader(srcFile), new FileWriter(
                destFile));
        }
    }

    private void genSrc() throws IOException {
        FileUtils.deleteDirectory(new File(destDir + "/src/gov"));

        File srcInputsFile = new File(templateDir + "/Inputs.java.in");
        File srcOutputsFile = new File(templateDir + "/Outputs.java.in");
        File srcPipelineFile = new File(templateDir + "/StandardMatlabPipelineModule.java.in");

        if (moduleNames.length == 0) {
            // just one module, use project name
            String projectNameCap = projectName.substring(0, 1).toUpperCase()
                + projectName.substring(1);

            String modulePackagePath = destDir + "/src/gov/nasa/kepler/"
                + projectName;
            File destPackageDir = new File(modulePackagePath);
            destPackageDir.mkdirs();

            map.put("module.cap.name", projectNameCap);
            map.put("module.lower.name", projectName);
            map.put("package.name", projectName);

            File destInputsFile = new File(modulePackagePath + "/"
                + projectNameCap + "Inputs.java");
            File destOutputsFile = new File(modulePackagePath + "/"
                + projectNameCap + "Outputs.java");
            File destPipelineFile = new File(modulePackagePath + "/"
                + projectNameCap + "StandardMatlabPipelineModule.java");

            copyAndSubstituteProps(new FileReader(srcInputsFile),
                new FileWriter(destInputsFile));
            copyAndSubstituteProps(new FileReader(srcOutputsFile),
                new FileWriter(destOutputsFile));
            copyAndSubstituteProps(new FileReader(srcPipelineFile),
                new FileWriter(destPipelineFile));
        } else {
            for (int i = 0; i < moduleNames.length; i++) {
                String moduleName = moduleNames[i];
                String moduleNameLower = moduleNames[i].toLowerCase();

                String modulePackagePath = destDir + "/src/gov/nasa/kepler/"
                    + projectName + "/" + moduleNameLower;
                File destPackageDir = new File(modulePackagePath);
                destPackageDir.mkdirs();

                map.put("module.cap.name", moduleName);
                map.put("module.lower.name", moduleNameLower);
                map.put("package.name", projectName + "." + moduleNameLower);

                File destInputsFile = new File(modulePackagePath + "/"
                    + moduleName + "Inputs.java");
                File destOutputsFile = new File(modulePackagePath + "/"
                    + moduleName + "Outputs.java");
                File destPipelineFile = new File(modulePackagePath + "/"
                    + moduleName + "StandardMatlabPipelineModule.java");

                copyAndSubstituteProps(new FileReader(srcInputsFile),
                    new FileWriter(destInputsFile));
                copyAndSubstituteProps(new FileReader(srcOutputsFile),
                    new FileWriter(destOutputsFile));
                copyAndSubstituteProps(new FileReader(srcPipelineFile),
                    new FileWriter(destPipelineFile));
            }
        }
    }

    private void genTest() throws IOException {
        FileUtils.deleteDirectory(new File(destDir + "/test/gov"));
        StringBuffer autoTests = new StringBuffer();
        StringBuffer autoTestImports = new StringBuffer();
        File srcFile = new File(templateDir + "/PipelineModuleTest.java.in");

        if (moduleNames.length == 0) {
            // just one module, use project name
            String projectNameCap = projectName.substring(0, 1).toUpperCase()
                + projectName.substring(1);

            String modulePackagePath = destDir + "/test/gov/nasa/kepler/"
                + projectName;
            File destPackageDir = new File(modulePackagePath);
            destPackageDir.mkdirs();

            map.put("module.cap.name", projectNameCap);
            map.put("module.lower.name", projectName);
            map.put("package.name", projectName);

            File destFile = new File(modulePackagePath + "/" + projectNameCap
                + "PipelineModuleTest.java");

            copyAndSubstituteProps(new FileReader(srcFile), new FileWriter(
                destFile));

            autoTests.append("        suite.addTest(" + projectNameCap
                + "PipelineModuleTest.suite());");
        } else {
            for (int i = 0; i < moduleNames.length; i++) {
                String moduleName = moduleNames[i];
                String moduleNameLower = moduleNames[i].toLowerCase();

                String modulePackagePath = destDir + "/test/gov/nasa/kepler/"
                    + projectName + "/" + moduleNameLower;
                File destPackageDir = new File(modulePackagePath);
                destPackageDir.mkdirs();

                map.put("module.cap.name", moduleName);
                map.put("module.lower.name", moduleNameLower);
                map.put("package.name", projectName + "." + moduleNameLower);

                File destFile = new File(modulePackagePath + "/" + moduleName
                    + "PipelineModuleTest.java");

                copyAndSubstituteProps(new FileReader(srcFile), new FileWriter(
                    destFile));

                String moduleTestName = moduleName + "PipelineModuleTest";
                autoTests.append("        suite.addTest(" + moduleTestName
                    + ".suite());\n");
                autoTestImports.append("import gov.nasa.kepler." + projectName
                    + "." + moduleNameLower + "." + moduleTestName + ";\n");
            }
        }

        map.put("module.auto.tests", autoTests.toString());
        map.put("project.imports", autoTestImports.toString());
        copyAndSubstituteProps(new FileReader(templateDir
            + "/AutoTestSuite.java.in"), new FileWriter(destDir
            + "/test/gov/nasa/kepler/" + projectName + "/AutoTestSuite.java"));
    }

    public void genTopLevelFiles() throws IOException {
        FileUtils.copyFile(new File(templateDir + "/classpath.in"), new File(
            destDir + "/.classpath"));
        copyAndSubstituteProps(new FileReader(templateDir + "/project.in"),
            new FileWriter(destDir + "/.project"));

        String projectNameCap = projectName.substring(0, 1).toUpperCase()
            + projectName.substring(1);

        StringWriter buffer = new StringWriter();

        if (moduleNames.length == 0) {
            map.put("module.cap.name", projectNameCap);
            map.put("package.name", projectName);
            map.put("matlab.dir", projectName);

            copyAndSubstituteProps(new FileReader(templateDir
                + "/build.xml.module"), buffer);
            buffer.write("\n");
        } else {
            for (int i = 0; i < moduleNames.length; i++) {
                String moduleName = moduleNames[i];
                String moduleNameLower = moduleNames[i].toLowerCase();

                map.put("module.cap.name", moduleName);
                map.put("package.name", projectName + "." + moduleNameLower);
                map.put("matlab.dir", projectName + "/" + moduleNameLower);

                copyAndSubstituteProps(new FileReader(templateDir
                    + "/build.xml.module"), buffer);
                buffer.write("\n");
            }
        }

        String moduleList = projectNameCap;
        if (moduleNames.length > 0) {
            StringBuffer buf = new StringBuffer();
            for (int i = 0; i < moduleNames.length; i++) {
                buf.append(moduleNames[i]);
                if (i + 1 != moduleNames.length) {
                    buf.append(",");
                }
            }
            moduleList = buf.toString();
        }

        map.put("module.list", moduleList);
        map.put("module.gencpp.props", buffer.toString());

        copyAndSubstituteProps(new FileReader(templateDir + "/build.xml.in"),
            new FileWriter(destDir + "/build.xml"));
    }

    private void copyAndSubstituteProps(Reader src, Writer dest)
        throws IOException {

        // log.info("srcFile = " + srcFile );
        // log.info("destFile = " + destFile );

        BufferedReader br = new BufferedReader(src);
        PrintWriter pw = new PrintWriter(dest);

        String oneLine = br.readLine();
        while (oneLine != null) {
            String resolvedString = sub.replace(oneLine);
            pw.println(resolvedString);

            oneLine = br.readLine();
        }
        br.close();
        pw.close();
    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        DOMConfigurator.configure(Filenames.ETC + Filenames.LOG4J_CONFIG);

        GenModuleProject g = null;

        g = new GenModuleProject("mi-template", "../pa", "pa", new String[] {
            "Bpp", "Tpp", "Diareg", "DiaPhot", "Ens" });
        g.gen();

        g = new GenModuleProject("mi-template", "../ppa", "ppa",
            new String[] {});
        g.gen();

        g = new GenModuleProject("mi-template", "../pdc", "pdc",
            new String[] {});
        g.gen();

        g = new GenModuleProject("mi-template", "../tps", "tps",
            new String[] {});
        g.gen();

        g = new GenModuleProject("mi-template", "../rls", "rls",
            new String[] {});
        g.gen();

        g = new GenModuleProject("mi-template", "../dv", "dv",
            new String[] {"TpsValidation","TpsBootstrap","RlsValidation"});
        g.gen();

        g = new GenModuleProject("mi-template", "../cal", "cal",
            new String[] {});
        g.gen();

        System.out.println("done");
    }

}

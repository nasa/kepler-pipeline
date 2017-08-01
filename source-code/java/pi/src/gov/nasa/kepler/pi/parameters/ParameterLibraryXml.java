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

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.KeplerHibernateConfiguration;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * @author Forrest Girouard
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class ParameterLibraryXml {
    private static final Log log = LogFactory.getLog(ParameterLibraryXml.class);

    private boolean overrideOnly = false;

    public ParameterLibraryXml() {
    }

    public List<ParameterSetDescriptor> readFromFile(String sourcePath)
        throws Exception {

        return readFromReader(new FileReader(sourcePath));
    }

    @SuppressWarnings("unchecked")
    public List<ParameterSetDescriptor> readFromReader(Reader source)
        throws Exception {
        List<ParameterSetDescriptor> entries = new LinkedList<ParameterSetDescriptor>();

        ParameterLibraryDocument paramLibraryDocument = ParameterLibraryDocument.Factory.parse(source);
        ParameterLibraryXB paramLibraryXmlBean = paramLibraryDocument.getParameterLibrary();

        if (paramLibraryXmlBean.isSetOverrideOnly()
            && paramLibraryXmlBean.getOverrideOnly() == true) {
            overrideOnly = true;
        }

        ParameterSetXB[] paramSets = paramLibraryXmlBean.getParameterSetArray();

        for (ParameterSetXB parameterSetXml : paramSets) {
            ParameterSetDescriptor descriptor = new ParameterSetDescriptor(
                parameterSetXml.getName(), parameterSetXml.getClassname());

            ParameterXB[] paramXmlList = parameterSetXml.getParameterArray();
            Map<String, String> params = new HashMap<String, String>();

            for (ParameterXB parameterXB : paramXmlList) {
                params.put(parameterXB.getName(), parameterXB.getValue());
            }

            try {
                Class<? extends Parameters> beanClass = (Class<? extends Parameters>) Class.forName(parameterSetXml.getClassname());
                BeanWrapper<Parameters> paramsBean = new BeanWrapper<Parameters>(
                    beanClass);
                paramsBean.setProps(params);

                descriptor.setImportedParamsBean(paramsBean);
            } catch (ClassNotFoundException e) {
                descriptor.setState(ParameterSetDescriptor.State.CLASS_MISSING);
            }
            entries.add(descriptor);
        }

        return entries;
    }

    public void writeToFile(List<ParameterSetDescriptor> entries,
        String destinationPath) throws IOException {
        Writer destinationWriter = null;
        if (destinationPath.equals("-")) {
            destinationWriter = new OutputStreamWriter(System.out);
        } else {
            File destinationFile = new File(destinationPath);
            if (destinationFile.exists() && destinationFile.isDirectory()) {
                throw new IllegalArgumentException(
                    "destinationPath exists and is a directory: "
                        + destinationFile);
            }
            destinationWriter = new FileWriter(destinationPath);
        }

        try {
            writeToWriter(entries, destinationWriter);
        } finally {
            FileUtil.close(destinationWriter);
        }
    }

    public void writeToWriter(List<ParameterSetDescriptor> entries,
        Writer destinationWriter) throws IOException {

        log.info("Exporting " + entries.size() + " parameter sets to: "
            + destinationWriter);

        ParameterLibraryDocument paramLibraryDocument = ParameterLibraryDocument.Factory.newInstance();
        ParameterLibraryXB paramLibraryXmlBean = paramLibraryDocument.addNewParameterLibrary();

        paramLibraryXmlBean.setRelease(KeplerSocVersion.getRelease());
        paramLibraryXmlBean.setSvnUrl(KeplerSocVersion.getUrl());
        paramLibraryXmlBean.setSvnRevision(KeplerSocVersion.getRevision());
        Calendar c = Calendar.getInstance();
        c.setTime(KeplerSocVersion.getBuildDate());
        paramLibraryXmlBean.setBuildDate(c);
        Configuration config = ConfigurationServiceFactory.getInstance();
        paramLibraryXmlBean.setDatabaseUrl(config.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_URL_PROP));
        paramLibraryXmlBean.setDatabaseUser(config.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_USERNAME_PROP));

        for (ParameterSetDescriptor parameterSetDescriptor : entries) {
            ParameterSet paramSet = parameterSetDescriptor.getLibraryParamSet();
            ParameterSetXB paramSetXmlBean = paramLibraryXmlBean.addNewParameterSet();
            paramSetXmlBean.setName(parameterSetDescriptor.getName());
            paramSetXmlBean.setVersion(paramSet.getVersion());
            paramSetXmlBean.setLocked(paramSet.isLocked());
            paramSetXmlBean.setClassname(paramSet.getParameters()
                .getClazz()
                .getName());

            // write props
            Map<String, String> params = paramSet.getParameters()
                .getProps();
            for (String paramName : params.keySet()) {
                String paramValue = params.get(paramName);

                ParameterXB paramXmlBean = paramSetXmlBean.addNewParameter();
                paramXmlBean.setName(paramName);
                paramXmlBean.setValue(paramValue);
            }
        }

        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!paramLibraryDocument.validate(xmlOptions)) {
            throw new PipelineException(
                "Export Parameter Library failed: XML validation errors: "
                    + errors);
        }

        paramLibraryDocument.save(destinationWriter, xmlOptions);
    }

    /**
     * @return the overrideOnly
     */
    public boolean isOverrideOnly() {
        return overrideOnly;
    }

    /**
     * @param overrideOnly the overrideOnly to set
     */
    public void setOverrideOnly(boolean overrideOnly) {
        this.overrideOnly = overrideOnly;
    }
}

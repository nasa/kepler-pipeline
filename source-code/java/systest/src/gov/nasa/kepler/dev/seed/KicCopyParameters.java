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

package gov.nasa.kepler.dev.seed;

import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Properties;

/**
 * Parameters used by {@link KicCopyPipelineModule} to specify
 * the source database to copy KIC entries from.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class KicCopyParameters implements Parameters {

    private String srcUrl = "";
    private String srcUser = "";
    private String srcPassword = "";
    private String srcDialect = "";
    private String srcDriverClass = "";

    public KicCopyParameters() {
    }

    public Properties createProperties() {
        Properties props = new Properties();
        props.setProperty("hibernate.connection.driver_class", srcDriverClass);
        props.setProperty("hibernate.connection.url", srcUrl);
        props.setProperty("hibernate.connection.username", srcUser);
        props.setProperty("hibernate.connection.password", srcPassword);
        props.setProperty("hibernate.dialect", srcDialect);
        props.setProperty("hibernate.jdbc.batch_size", "0");
        props.setProperty("hibernate.show_sql", "false");
        
        return props;
    }

    /**
     * @return the srcUrl
     */
    public String getSrcUrl() {
        return srcUrl;
    }

    /**
     * @param srcUrl the srcUrl to set
     */
    public void setSrcUrl(String srcUrl) {
        this.srcUrl = srcUrl;
    }

    /**
     * @return the srcUser
     */
    public String getSrcUser() {
        return srcUser;
    }

    /**
     * @param srcUser the srcUser to set
     */
    public void setSrcUser(String srcUser) {
        this.srcUser = srcUser;
    }

    /**
     * @return the srcPassword
     */
    public String getSrcPassword() {
        return srcPassword;
    }

    /**
     * @param srcPassword the srcPassword to set
     */
    public void setSrcPassword(String srcPassword) {
        this.srcPassword = srcPassword;
    }

    /**
     * @return the srcDialect
     */
    public String getSrcDialect() {
        return srcDialect;
    }

    /**
     * @param srcDialect the srcDialect to set
     */
    public void setSrcDialect(String srcDialect) {
        this.srcDialect = srcDialect;
    }

    /**
     * @return the srcDriverClass
     */
    public String getSrcDriverClass() {
        return srcDriverClass;
    }

    /**
     * @param srcDriverClass the srcDriverClass to set
     */
    public void setSrcDriverClass(String srcDriverClass) {
        this.srcDriverClass = srcDriverClass;
    }
}

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

package gov.nasa.kepler.hibernate.dbservice;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * The result of parsing the Derby URL.  This is needed because the Derby
 * DataSource objects will not parse their own URLs.
 * 
 * @author Sean McCauliff
 *
 */
public class DerbyUrl {

    public final static int DERBY_DEFAULT_PORT = 1523;
    
    final String databaseName;
    /** e.g. ";create=true" */
    final String attributes;
    final String hostName;
    final int portNumber;
    
    
    public DerbyUrl(String databaseName, String attributes, String hostName,
                   int portNumber) {
        this.databaseName = databaseName;
        this.attributes = attributes;
        this.hostName = hostName;
        this.portNumber = portNumber;
    }
    
    
    public static DerbyUrl parseDerbyUrl(String url) {
        Pattern p = Pattern.compile("jdbc:derby:([^;]+)(;.+)?");
        Matcher m = p.matcher(url);
        if (!m.matches()) {
            throw new IllegalArgumentException("Invalid derby url \" " + url
                + "\".");
        }
        
        String databaseName = null;
        String hostName = null;
        String attributes = "";
        int portNumber = DERBY_DEFAULT_PORT;
        
        if (m.group(1).startsWith("//")) {
            //parse network url
            Pattern netPattern = Pattern.compile("//([^:/]+)(:\\d+)?/(.+)");
            Matcher netMatcher = netPattern.matcher(m.group(1));
            if (!netMatcher.matches()) {
                throw new IllegalArgumentException("Bad network specification " +
                        "for derby url \"" + m.group(1) + "\".");
            }
         
            hostName = netMatcher.group(1);
            if (netMatcher.group(2) != null) {
                portNumber = Integer.parseInt(netMatcher.group(2).substring(1));
            }
            databaseName = netMatcher.group(3);
           
            
        } else {
            databaseName = m.group(1);
        }
        
        if (m.groupCount() > 1) {
            attributes = (m.group(2) == null) ? "" :  m.group(2).substring(1);
        }
        
        return new DerbyUrl(databaseName, attributes, hostName, portNumber);
    }


    /**
     * @return the attributes
     */
    public String getAttributes() {
        return attributes;
    }


    /**
     * @return the databaseName
     */
    public String getDatabaseName() {
        return databaseName;
    }


    /**
     * @return the hostName
     */
    public String getHostName() {
        return hostName;
    }


    /**
     * @return the portNumber
     */
    public int getPortNumber() {
        return portNumber;
    }
}

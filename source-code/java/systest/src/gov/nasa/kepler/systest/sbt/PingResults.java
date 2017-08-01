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

package gov.nasa.kepler.systest.sbt;

import java.io.PrintWriter;
import java.io.StringWriter;

/**
 * Hold results from {@link PingDataStores}
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PingResults{
    private boolean requireDatabase = false;
    private boolean requireFilestore = false;
    private String fsUrl = "<fs URL not configured>";
    private boolean fsAvailable = false;
    private String fsError = "";
    private String dbUrl = "<db URL not configured>";
    private boolean dbAvailable = false;
    private String dbError = "";

    public PingResults() {
    }

    public PingResults(boolean requireDatabase, boolean requireFilestore) {
        this.requireDatabase = requireDatabase;
        this.requireFilestore = requireFilestore;
    }

    public String getFsUrl() {
        return fsUrl;
    }

    public void setFsUrl(String fsUrl) {
        this.fsUrl = fsUrl;
    }

    public boolean isFsAvailable() {
        return fsAvailable;
    }
    
    public void setFsAvailable(boolean fsAvailable) {
        this.fsAvailable = fsAvailable;
    }

    public String getFsError() {
        return fsError;
    }

    public void setFsError(String fsError) {
        this.fsError = fsError;
    }

    public String getDbUrl() {
        return dbUrl;
    }

    public void setDbUrl(String dbUrl) {
        this.dbUrl = dbUrl;
    }

    public boolean isDbAvailable() {
        return dbAvailable;
    }

    public void setDbAvailable(boolean dbAvailable) {
        this.dbAvailable = dbAvailable;
    }

    public String getDbError() {
        return dbError;
    }

    public void setDbError(String dbError) {
        this.dbError = dbError;
    }
    
    public boolean isRequireDatabase() {
        return requireDatabase;
    }

    public void setRequireDatabase(boolean requireDatabase) {
        this.requireDatabase = requireDatabase;
    }

    public boolean isRequireFilestore() {
        return requireFilestore;
    }

    public void setRequireFilestore(boolean requireFilestore) {
        this.requireFilestore = requireFilestore;
    }

    public boolean validate(){
        boolean valid = true;
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        
        if(requireFilestore){
            if(fsAvailable){
                pw.println("Filestore at (" + fsUrl + ") is ALIVE");
            }else{
                pw.println("Filestore at (" + fsUrl + ") is NOT RESPONDING (" + fsError + ")");
                valid = false;
            }
        }

        if(requireDatabase){
            if(dbAvailable){
                pw.println("Database at (" + dbUrl + ") is ALIVE");
            }else{
                pw.println("Database at (" + dbUrl + ") is NOT RESPONDING (" + dbError + ")");
                valid = false;
            }
        }
        
        if(!valid){
            System.out.println("Required datastore(s) are off-line:");
        }

        System.out.print(sw.toString());
        
        return valid;
    }
}
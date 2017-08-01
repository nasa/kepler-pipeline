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

package gov.nasa.kepler.hibernate;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.debug.DebugMetadata;
import gov.nasa.kepler.hibernate.debug.DebugMetadataCrud;

/**
 * This tests the range of values for an double Oracle type (which becomes FLOAT
 * which in turn is represented as a NUMBER).
 * 
 * @author Forrest Girouard
 * 
 */
public class OracleDoubleLimit {

    DatabaseService databaseService = DatabaseServiceFactory.getInstance();
    double base = 0.0;
    int exponent = 0;

    public OracleDoubleLimit(double base, int exponent) {
        this.base = base;
        this.exponent = exponent;
    }

    public DatabaseService getDatabaseService() {
        return databaseService;
    }

    public void setDatabaseService(DatabaseService databaseService) {
        this.databaseService = databaseService;
    }

    public double getBase() {
        return base;
    }

    public void setBase(double base) {
        this.base = base;
    }

    public int getExponent() {
        return exponent;
    }

    public void setExponent(int exponent) {
        this.exponent = exponent;
    }

    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("Usage: java OracleDoubleLimit <base> <exponent> <count>");
            System.exit(1);
        }
        double base = Double.valueOf(args[0]);
        int exponent = Integer.valueOf(args[1]);
        int count = Integer.valueOf(args[2]);
        OracleDoubleLimit oracleDouble = new OracleDoubleLimit(base, exponent);
        DebugMetadataCrud debugMetadataCrud = new DebugMetadataCrud(
            oracleDouble.getDatabaseService());
        for (int i = 0; i < count; i++, oracleDouble.incrementExponent()) {
            try {
                System.out.println(String.format(
                    "base=%e; exponent=%d; value=%e; Math.getExponent(%e)=%d",
                    oracleDouble.getBase(), oracleDouble.getExponent(),
                    oracleDouble.value(), oracleDouble.value(),
                    Math.getExponent(oracleDouble.value())));
                oracleDouble.getDatabaseService()
                    .beginTransaction();
                DebugMetadata debugMetadata = new DebugMetadata(
                    oracleDouble.getClass()
                        .getSimpleName(), null);
                // debugMetadata.setDoubleField(oracleDouble.value());
                debugMetadataCrud.create(debugMetadata);
                oracleDouble.getDatabaseService()
                    .commitTransaction();
            } catch (Throwable t) {
                System.err.println(t.getMessage());
            } finally {
                oracleDouble.getDatabaseService()
                    .rollbackTransactionIfActive();
            }
        }
    }

    private void incrementExponent() {
        exponent++;
    }

    private double value() {
        return Math.pow(base, exponent);
    }
}

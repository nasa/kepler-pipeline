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

import javax.persistence.Column;
import javax.persistence.Table;

import org.hibernate.AssertionFailure;
import org.hibernate.cfg.NamingStrategy;

/**
 * This class implements {@link org.hibernate.cfg.NamingStrategy}
 * for the database naming conventions defined for the Kepler SOC project.
 * Essentially, this consists of converting the Java camel-case names
 * to an all-caps with underscores format.
 * 
 * This code is based on {@link org.hibernate.cfg.ImprovedNamingStrategy},
 * the main difference being that names that are explicitly defined in the
 * code annotations (like {@link Table}, {@link Column}, etc.) are not
 * modified.
 * 
 *  
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class KeplerNamingStrategy implements NamingStrategy {
    
    /**
     * A convenient singleton instance
     */
    public static final NamingStrategy INSTANCE = new KeplerNamingStrategy();

    public static String unqualify(String className) {
        int lastIndex = className.lastIndexOf('.');
        if (lastIndex != -1) {
            return className.substring(lastIndex+1);
        }
        
        return className;
    }

    public boolean isNotEmpty(String columnName) {
        if (columnName != null) {
            return !columnName.isEmpty();
        }

        return false;
    }
    
    /**
     * Return the unqualified class name, mixed case converted to
     * underscores
     */
    public String classToTableName(String className) {
        return addUnderscores( unqualify(className) );
    }
    
    /**
     * Return the full property path with underscore seperators, mixed
     * case converted to underscores
     */
    public String propertyToColumnName(String propertyName) {
        return addUnderscores( unqualify(propertyName) );
    }
    
    /**
     * This method is called for names explicitly defined
     * in the annotations.  Leave the name alone!
     */
    public String tableName(String tableName) {
        return tableName;
    }
    
    /**
     * This method is called for names explicitly defined
     * in the annotations.  Leave the name alone!
     */
    public String columnName(String columnName) {
        return columnName;
    }

    public String collectionTableName(
            String ownerEntity, String ownerEntityTable, String associatedEntity, String associatedEntityTable,
            String propertyName
    ) {
        return tableName( ownerEntityTable + '_' + propertyToColumnName(propertyName) );
    }

    /**
     * Return the argument
     */
    public String joinKeyColumnName(String joinedColumn, String joinedTable) {
        return addUnderscores(joinedTable) + "_" + addUnderscores( joinedColumn );
    }

    /**
     * Return the property name or propertyTableName
     */
    public String foreignKeyColumnName(
            String propertyName, String propertyEntityName, String propertyTableName, String referencedColumnName
    ) {
        String header = propertyName != null ? unqualify( propertyName ) : propertyTableName;
        if (header == null)
            throw new AssertionFailure("NamingStrategy not properly filled");
        return addUnderscores( propertyTableName ) + "_" + addUnderscores(referencedColumnName);
    }

    /**
     * Return the column name or the unqualified property name
     */
    public String logicalColumnName(String columnName, String propertyName) {
        return isNotEmpty( columnName ) ? columnName : unqualify( propertyName );
    }

    /**
     * Returns either the table name if explicit or
     * if there is an associated table, the concatenation of owner entity table and associated table
     * otherwise the concatenation of owner entity table and the unqualified property name
     */
    public String logicalCollectionTableName(String tableName,
                                             String ownerEntityTable, String associatedEntityTable, String propertyName
    ) {
        if ( tableName != null ) {
            return tableName;
        }
        else {
            //use of a stringbuffer to workaround a JDK bug
            return new StringBuffer(ownerEntityTable).append("_")
                    .append(
                        associatedEntityTable != null ?
                        associatedEntityTable :
                        unqualify( propertyName )
                    ).toString();
        }
    }
    
    /**
     * Return the column name if explicit or the concatenation of the property name and the referenced column
     */
    public String logicalCollectionColumnName(String columnName, String propertyName, String referencedColumn) {
        return isNotEmpty( columnName ) ?
                columnName :
                unqualify( propertyName ) + "_" + referencedColumn;
    }

    /**
     * Convert camel-case to caps & underscores
     * 
     * @param name
     * @return
     */
    protected static String addUnderscores(String name) {
        StringBuffer buf = new StringBuffer( name.replace('.', '_') );
        for (int i=1; i<buf.length()-1; i++) {
            if (
                Character.isLowerCase( buf.charAt(i-1) ) &&
                Character.isUpperCase( buf.charAt(i) ) &&
                Character.isLowerCase( buf.charAt(i+1) )
            ) {
                buf.insert(i++, '_');
            }
        }
        return buf.toString().toUpperCase();
    }
}

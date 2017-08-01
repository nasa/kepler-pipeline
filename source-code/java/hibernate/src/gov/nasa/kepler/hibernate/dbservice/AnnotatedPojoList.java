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

import gov.nasa.kepler.common.ClasspathScanner;
import gov.nasa.kepler.common.ClasspathScannerListener;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;

import javassist.bytecode.AnnotationsAttribute;
import javassist.bytecode.ClassFile;

import javax.persistence.Embeddable;
import javax.persistence.Entity;
import javax.persistence.MappedSuperclass;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Scan the classpath for all classes annotated
 * with {@link Entity} or {@link Embeddable}
 * so they can programatically be added to the
 * Hibernate {@link AnnotatedConfiguration}.
 * 
 * Dives into Jar files and supports jar filename
 * and package name filters
 *  
 * Uses Javassist to read the bytecode to avoid
 * forcing the classloader to load every class on the
 * classpath.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class AnnotatedPojoList implements ClasspathScannerListener{
    private static final Log log = LogFactory.getLog(AnnotatedPojoList.class);

    private Set<String> jarFilters = new HashSet<String>();
    private Set<String> packageFilters = new HashSet<String>();
    private Set<String> classPathToScan = new HashSet<String>();

    private Set<Class<?>> detectedClasses = new HashSet<Class<?>>();
    
    public AnnotatedPojoList() {
    }

    /**
     * For each element in the classpath, scan the contents (either a recursive
     * directory search or a JAR scan) for annotated classes.
     * 
     * @return
     * @throws IOException
     * @throws ClassNotFoundException
     */
    public Set<Class<?>> scanForClasses() throws Exception{
        log.debug("AnnotatedPojoList: Scanning class path for annotated classes");

        ClasspathScanner classpathScanner = new ClasspathScanner();
        classpathScanner.addListener(this);
        classpathScanner.setJarFilters(jarFilters);
        classpathScanner.setPackageFilters(packageFilters);
        classpathScanner.setClassPathToScan(classPathToScan);
        
        classpathScanner.scanForClasses();
        
        return detectedClasses;
    }
    
    /**
     * @throws Exception 
     * 
     */
    public void processClass(ClassFile classFile) throws Exception {
        if(isClassAnnotated(classFile)){
            //log.debug("Found annotated class: " + className);
            Class<?> clazz = Class.forName(classFile.getName());
            detectedClasses.add(clazz);
        }
    }


    /**
     * Use the Javassist library to check the .class file for JPA annotations
     * 
     * @param classFile
     * @return
     */
    private boolean isClassAnnotated(ClassFile classFile){
        
        // TODO: do we care about global metadata?
//        if ( cf.getName().endsWith( ".package-info" ) ) {
//            int idx = cf.getName().indexOf( ".package-info" );
//            String pkgName = cf.getName().substring( 0, idx );
//            log.info( "found package: " + pkgName );
//            packages.add( pkgName );
//            continue;
//        }

        AnnotationsAttribute visible = (AnnotationsAttribute) classFile.getAttribute( AnnotationsAttribute.visibleTag );
        if ( visible != null ) {
            boolean isEntity = visible.getAnnotation( Entity.class.getName() ) != null;
            if ( isEntity ) {
                log.debug( "found @Entity: " + classFile.getName() );
                return true;
            }
            boolean isEmbeddable = visible.getAnnotation( Embeddable.class.getName() ) != null;
            if ( isEmbeddable ) {
                log.debug( "found @Embeddable: " + classFile.getName() );
                return true;
            }
            boolean isEmbeddableSuperclass = visible.getAnnotation( MappedSuperclass.class.getName() ) != null;
            if ( isEmbeddableSuperclass ) {
                log.debug( "found @MappedSuperclass: " + classFile.getName() );
                return true;
            }
        }
        return false;
    }
    
    /**
     * @return the jarFilters
     */
    public Set<String> getJarFilters() {
        return jarFilters;
    }

    /**
     * @param jarFilters the jarFilters to set
     */
    public void setJarFilters(Set<String> jarFilters) {
        this.jarFilters = jarFilters;
    }

    /**
     * @return the packageFilters
     */
    public Set<String> getPackageFilters() {
        return packageFilters;
    }

    /**
     * @param packageFilters the packageFilters to set
     */
    public void setPackageFilters(Set<String> packageFilters) {
        this.packageFilters = packageFilters;
    }

    public Set<String> getClassPathToScan() {
        return classPathToScan;
    }

    public void setClassPathToScan(Set<String> classPathToScan) {
        this.classPathToScan = classPathToScan;
    }
}

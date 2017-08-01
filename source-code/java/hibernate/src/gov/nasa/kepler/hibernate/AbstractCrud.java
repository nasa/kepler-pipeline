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
import gov.nasa.spiffy.common.collect.ListChunkIterator;

import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Criteria;
import org.hibernate.Query;
import org.hibernate.Session;

import com.google.common.collect.Lists;

/**
 * The parent class for all CRUD classes.
 * 
 * @author Bill Wohler
 */
public abstract class AbstractCrud {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(AbstractCrud.class);

    /**
     * This is the maximum number of dynamically-created expressions sent to the
     * database. This limit is 1000 in Oracle. A setting of 950 leaves plenty of
     * room for other expressions in the query.
     * 
     * @see ListChunkIterator
     */
    public static final int MAX_EXPRESSIONS = 950;

    private DatabaseService databaseService;
    private boolean readOnly;

    /**
     * Creates a {@link AbstractCrud} whose read-only property is set to
     * {@code false}.
     */
    protected AbstractCrud() {
    }

    /**
     * Creates a {@link AbstractCrud} with the given read-only property. CRUD
     * classes can instantiate themselves with this parameter set to
     * {@code true} to avoid dirty checking and therefore save on CPU usage.
     * <p>
     * Use {@link #createQuery(String)} to take advantage of this property.
     */
    protected AbstractCrud(boolean readOnly) {
        this.readOnly = readOnly;
    }

    /**
     * Creates a {@link AbstractCrud} with the given database service whose
     * read-only property is set to {@code false}.
     */
    protected AbstractCrud(DatabaseService databaseService) {
        this.databaseService = databaseService;
    }

    /**
     * Creates a {@link AbstractCrud} with the given database service and
     * read-only property. CRUD classes can instantiate themselves this
     * parameter set to {@code true} to avoid dirty checking and therefore save
     * on CPU usage.
     * <p>
     * Use {@link #createQuery(String)} to take advantage of this property.
     */
    protected AbstractCrud(DatabaseService databaseService, boolean readOnly) {
        this(databaseService);
        this.readOnly = readOnly;
    }

    /**
     * Returns the database service used by this CRUD object.
     */
    protected final DatabaseService getDatabaseService() {
        if (databaseService == null) {
            databaseService = DatabaseServiceFactory.getInstance();
        }

        return databaseService;
    }

    /**
     * Convenience method that returns the current persistence session. Do not
     * cache this locally as it can vary between threads.
     * 
     * @return the persistence session.
     */
    protected final Session getSession() {
        return getDatabaseService().getSession();
    }

    /**
     * Creates a new instance of {@link Query} for the given HQL query string
     * using this object's local properties.
     * <p>
     * Note that the read-only property only extends to the queried objects.
     * Objects that are lazily loaded later must be explicitly marked read-only.
     * 
     * @param queryString the HQL query string
     * @return a {@link Query} object
     */
    protected Query createQuery(String queryString) {
        Query query = getSession().createQuery(queryString);
        query.setReadOnly(readOnly);

        return query;
    }

    /**
     * Creates a new {@link Criteria} instance, for the given entity class, or a
     * superclass of an entity class using this object's local properties.
     * <p>
     * Note that the read-only property does not apply to this method. However,
     * use of this method will allow the CRUD class to take advantage of future
     * properties.
     * 
     * @param persistentClass the persistent class
     * @return a {@link Criteria} object
     */
    protected Criteria createCriteria(Class<?> persistentClass) {
        Criteria query = getSession().createCriteria(persistentClass);

        return query;
    }

    protected <E> List<E> list(Query query) {
        @SuppressWarnings("unchecked")
        List<E> list = query.list();

        return list;
    }

    protected <E> List<E> list(Criteria criteria) {
        @SuppressWarnings("unchecked")
        List<E> list = criteria.list();

        return list;
    }

    protected <T> T uniqueResult(Query query) {
        @SuppressWarnings("unchecked")
        T t = (T) query.uniqueResult();

        return t;
    }

    protected <T> T uniqueResult(Criteria criteria) {
        @SuppressWarnings("unchecked")
        T t = (T) criteria.uniqueResult();

        return t;
    }
    
    /**
     * Produce a query for the next chunk.  Used by aggregateResults() to 
     * collect all the results needed when a single query would have too many
     * expressions.  This usually happens when you need to query Oracle and the
     * query is constrained by a long list of kepler ids.
     * 
     *
     * @param <T> The type used in the expression used to build the query.
     * @param <R> The result type of the query.
     */
    public interface QueryFactory<T,R> {
        Query produceQuery(List<T> nextChunk);
    }
    
    /**
     * Use this to produce a complete list of results when queries must be
     * broken into many distinct queries in order to satisify database query
     * lanugage limitations.
     * 
     * @param source The complete list of elements to query.
     * @param queryFactory creates a new query or sets query parameters for the
     * next chunk of expressions to evaluate.
     * @return list of type R, the result type.
     */
    protected <T,R> List<R> aggregateResults(Collection<T> source, 
        QueryFactory<T, R> queryFactory) {
    
        if (source.isEmpty()) {
            return Collections.emptyList();
        }
        List<R> results = Lists.newArrayListWithCapacity(MAX_EXPRESSIONS * 2);
        ListChunkIterator<T> it = 
            new ListChunkIterator<T>(source.iterator(), MAX_EXPRESSIONS);
        for (List<T> chunk : it) {
            Query q = queryFactory.produceQuery(chunk);
            @SuppressWarnings("unchecked")
            List<R> resultChunk  = q.list();
            results.addAll(resultChunk);
        }
        return results;
    }


}

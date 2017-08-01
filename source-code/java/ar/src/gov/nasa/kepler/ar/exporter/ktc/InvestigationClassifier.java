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

package gov.nasa.kepler.ar.exporter.ktc;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Given a list of category names and labels for a target emit a single
 * investigation name.
 * 
 * @author Sean McCauliff
 *
 */
class InvestigationClassifier {

    private static final Pattern goPattern = Pattern.compile("(GO\\d{4,6})(_SC\\d?|_LC)?");
    
    /**
     * 1) If an observation is associated with one investigation base (either GO
     * or category label derived) then this will return that string.
     * 2) If a target is associated with a primary investigation ID base then
     * create the investigation name by concatenating the bases.
     * 3) Concatenation of names will use the '_' separator.  Base names will be
     * sorted lexicographically.  Except that GO labels will be last.
     * 4) If a base is a secondary base and there are primary bases then lose
     * the secondary bases.
     * 5) If an investigation is associated only with secondary bases.  Select
     * only the highest priority secondary base.
     * 
     * @param categoryNames
     * @param labels
     * @return  "" if an investigation name can not be assigned else it returns
     * the investigation name.
     */
    public String assign(List<String> categoryNames, List<String> labels) {
        Set<InvestigationBase> investigationBases = new HashSet<InvestigationBase>();
        for (String catName : categoryNames) {
            SoTargetCategory soCat = SoTargetCategory.fromName(catName);
            if (soCat != null && soCat.investigationBase() != InvestigationBase.GO) {
                investigationBases.add(soCat.investigationBase());
            }

        }
        
        SortedSet<String> goLabels = new TreeSet<String>();
        for (String label : labels) {
            Matcher m = goPattern.matcher(label);
            if (m.matches()) {
                goLabels.add(m.group(1));
            }
        }
        
        //Can't assign a base.
        if (goLabels.size() == 0 && investigationBases.size() == 0) {
            return "";
        }
        

        //Case 4 If an observation is associated with any of the certain
        //secondary bases then ignore the secondary bases
        boolean hasGoBase = !goLabels.isEmpty();
        if (hasGoBase || hasPrimaryBase(investigationBases)) {
            removeSecondaryBases(investigationBases);
        }
        
        //Case 5
        if (!hasGoBase && !hasPrimaryBase(investigationBases)) {
            List<InvestigationBase> secondaryInvestigationBases = new ArrayList<InvestigationBase>();
            secondaryInvestigationBases.addAll(investigationBases);
            Collections.sort(secondaryInvestigationBases, new Comparator<InvestigationBase>() {
                @Override
                public int compare(InvestigationBase o1, InvestigationBase o2) {
                    return o1.secondaryPriority() - o2.secondaryPriority();
                }
                
            });
            
            return secondaryInvestigationBases.get(0).name();
            
        }
        
        //Case 1 a target is assigned to only one investigation base.
        if (investigationBases.size() == 1 && goLabels.size() == 0) {
            return investigationBases.iterator().next().name();
        }
        if (investigationBases.size() == 0 && goLabels.size() == 1) {
            return goLabels.iterator().next();
        }
        
        //Concatenate investigation bases and labels
        List<String> investigationNames = new ArrayList<String>();
        for (InvestigationBase ibase : investigationBases) {
            investigationNames.add(ibase.name());
        }
        
        Collections.sort(investigationNames);
        
        StringBuilder bldr = new StringBuilder();
        for (String iname : investigationNames) {
            bldr.append(iname).append('_');
        }
        for (String goName : goLabels) {
            bldr.append(goName).append('_');
        }
        
        bldr.setLength(bldr.length() - 1);
        
        return bldr.toString();
    }
    
    private static boolean hasPrimaryBase(Set<InvestigationBase> investigationBases) {
        for (InvestigationBase ibase : investigationBases) {
            if (!ibase.isSecondary()) {
                return true;
            }
        }
        return false;
    }
    
    private static void removeSecondaryBases(Set<InvestigationBase> investigationBases) {
        Iterator<InvestigationBase> it = investigationBases.iterator();
        while (it.hasNext()) {
            InvestigationBase ibase = it.next();
            if (ibase.isSecondary()) {
                it.remove();
            }
        }
    }
    
}

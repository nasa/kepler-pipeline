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

package gov.nasa.kepler.fs.query;

import static gov.nasa.kepler.fs.query.FsQueryLexer.*;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.query.FsQueryParser.fsQuery_return;

import java.io.IOException;
import java.io.StringReader;
import java.util.Arrays;
import java.util.Comparator;

import org.antlr.runtime.*;
import org.antlr.runtime.tree.CommonTree;
import org.antlr.runtime.tree.DOTTreeGenerator;
import org.antlr.stringtemplate.StringTemplate;

/**
 * Given a FsQuery parse it and then evaluate the query on the FsIds using the
 * AST generated from parsing the FsQuery.
 * 
 * @author Sean McCauliff
 * 
 */
public class QueryEvaluator {

    public enum DataType {
        TimeSeries, MjdTimeSeries, Blob;
        
        public static DataType fromString(String s) {
            s = s.toLowerCase();
            for (DataType type : values()) {
                String lcase = type.name().toLowerCase();
                if (s.equals(lcase)) {
                    return type;
                } else if (s.equals(lcase.substring(0,1))) {
                    return type;
                }
            }
            throw new IllegalArgumentException("\"" + s + 
                "\" is not a data type.");
        }
    }
    
    
    private static final String[] CADENCE_ALIASES =
        new String[] {"lc", "sc", "longcadence",  "shortcadence", 
        "long_cadence", "short_cadence", "long", "short" };
    
    static {
        Arrays.sort(CADENCE_ALIASES, new StringLengthComparator());
    }
    
    private final CommonTree queryRoot;
    private final DataType dataType;
    
    private MatchState matchState;

    public QueryEvaluator(String queryString) throws RecognitionException {
        FsQueryLexer lexer = null;
        try {
            lexer = new FsQueryLexer(new ANTLRReaderStream(new StringReader(
                queryString)));
        } catch (IOException e) {
            // realistically this is never going to happen.
            throw new IllegalStateException("Weird parse error.", e);
        }

        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        FsQueryParser parser = new FsQueryParser(tokenStream);
        fsQuery_return parsedQuery = parser.fsQuery();
        queryRoot = (CommonTree) parsedQuery.getTree();
        dataType = findDataType(queryRoot, -1);
        processAst(queryRoot, -1);
    }

    private static DataType findDataType(CommonTree tree, int indexInParent) {
        switch (tree.getType()) {
            case AND:
            case OR:
            case PATH:
                for (int i=0; i < tree.getChildCount(); i++) {
                    DataType found = findDataType((CommonTree)tree.getChild(i), i);
                    if (found != null) {
                        return found;
                    }
                }
                break;
            case DATA_TYPE:
                StringBuilder bldr = new StringBuilder();
                for (int i=0; i < tree.getChildCount(); i++) {
                    bldr.append(tree.getChild(i).getText());
                }
                DataType dataType = DataType.fromString(bldr.toString());
                tree.getParent().deleteChild(indexInParent);
                return dataType;
        }
        
        return null;
    }
    
    /**
     * Process the tree into a simpler form. Combine all single character tokens
     * into a string. Parse the numbers in the integer constraints. Actually I
     * believe ANTLR can do these things or at least make them easier, but I'm
     * not that deep into knowledge of ANTLR.
     */
    private void processAst(final CommonTree tree, final int indexInParent) {
        switch (tree.getType()) {
            case PATHMATCH:
            case NAMEMATCH:
                StringBuilder bldr = new StringBuilder();
                for (int i = 0; i < tree.getChildCount(); i++) {
                    CommonTree child = (CommonTree) tree.getChild(i);
                    bldr.append(child.getToken()
                        .getText());
                }

                for (int i = tree.getChildCount() - 1; i >= 0; i--) {
                    tree.deleteChild(i);
                }
                Token strToken = new CommonToken(STR_TOKEN);
                strToken.setText(bldr.toString());
                tree.addChild(new CommonTree(strToken));
                break;
            case I_INTERVAL: {
                final CommonTree parent = (CommonTree) tree.getParent();
                IntegerConstraint iConstraint = new IntegerConstraint(tree);
                parent.setChild(indexInParent, iConstraint);
            }
                break;
            case D_INTERVAL: {
                final CommonTree parent = (CommonTree) tree.getParent();
                DoubleConstraint dConstraint = new DoubleConstraint(tree);
                parent.setChild(indexInParent, dConstraint);
            }
                break;
            case AND:
            case OR:
            case PATH:
                mergeMatchNodes(tree);
                for (int i = 0; i < tree.getChildCount(); i++) {
                    processAst((CommonTree) tree.getChild(i), i);
                }
                break;
            // Don't care about the rest.
        }
        
    }
    
    private static void mergeMatchNodes(CommonTree parent) {
        for (int i=0; i < parent.getChildCount() - 1; i++) {
            CommonTree child = (CommonTree) parent.getChild(i);
            switch (child.getType()) {
                case PATHMATCH:
                case NAMEMATCH:
                    mergeChildren(parent, i);
                    break;
            }
        }
    }
    
    private static void mergeChildren(final CommonTree parent, final int mergeToIndex) {
        CommonTree mergeTo = (CommonTree) parent.getChild(mergeToIndex);
        StringBuilder bldr = new StringBuilder(mergeTo.getChild(0).getText());
        int deleteFromIndex=mergeToIndex;
        for (int i=mergeToIndex+1; i < parent.getChildCount(); i++) {
            CommonTree sibling = (CommonTree) parent.getChild(i);
            if (isMergable(mergeTo, sibling)) {
                bldr.append(sibling.getChild(0).getText());
                deleteFromIndex++;
            } else {
                break;
            }
        }
        
        ((CommonTree)mergeTo.getChild(0)).getToken().setText(bldr.toString());
        
        for (int i=deleteFromIndex; i > mergeToIndex; i--) {
            parent.deleteChild(i);
        }
    }

    private static boolean isMergable(CommonTree mergeTo, CommonTree sibling) {
        return sibling.getType() == mergeTo.getType() || 
            sibling.getType() == IntegerToken || 
            sibling.getType() == DoubleToken;
    }
    

    public DataType dataType() {
        return dataType;
    }
    
    public boolean pathMatched() {
        return matchState.pathMatched;
    }

    public boolean pathPrefixMatched() {
        return matchState.pathPrefixMatched;
    }

    public boolean completeMatch() {
        return matchState.completeMatch;
    }

    public boolean match(FsId fsId) {

        matchState = new MatchState(fsId.toString());
        matchState.completeMatch = eval(queryRoot, matchState);

        if (matchState.idIndex < matchState.id.length()) {
            matchState.completeMatch = false;
            if (matchState.id.indexOf('/', matchState.idIndex) != -1) {
                matchState.pathMatched = false;
                matchState.pathPrefixMatched = false;
            } else {
                matchState.pathPrefixMatched = true;
            }
        } else {
            matchState.pathPrefixMatched = true;
        }
        return matchState.completeMatch;
    }

    /**
     * 
     * @param tree
     * @param idIndex
     * @param id
     * @return true if a rule is satisfied.
     */
    private static boolean eval(CommonTree tree, MatchState state) {
        final Token token = tree.getToken();

        switch (token.getType()) {
            case PATHMATCH:
            case NAMEMATCH:

                final CommonTree child = (CommonTree) tree.getChild(0);
                final String matchString = child.getToken()
                    .getText();

                final int charsRemaining = 
                    state.id.length() - state.idIndex;
                if (charsRemaining < matchString.length()) {
                    if (token.getType() == PATHMATCH
                        && state.id.indexOf("/", state.idIndex) != -1) {
                        state.pathPrefixMatched = false;
                    }
                    return false;
                }
                final boolean ok = state.id.regionMatches(state.idIndex, matchString, 0,
                    matchString.length());
                if (ok) {
                    state.idIndex += matchString.length();
                    return true; // This is a terminal node
                } else {
                    return false;
                }
            case PATH:
                if (eval((CommonTree) tree.getChild(0), state)) {
                    state.pathMatched = true;
                    return true;
                } else {
                    return false;
                }
            case PathSep:
                if (state.idIndex >= state.id.length()) {
                    state.pathPrefixMatched = false;
                    return false;
                }
                if (state.id.charAt(state.idIndex) == '/') {
                    state.pathPrefixMatched = true;
                    state.idIndex++;
                    return true;
                }
                return false;
            case AND:
                for (int i = 0; i < tree.getChildCount(); i++) {
                    if (!eval((CommonTree) tree.getChild(i), state)) {
                        return false;
                    }
                }
                return true;
            case OR:
                MatchState mostGreedy = null;
                for (int i = 0; i < tree.getChildCount(); i++) {
                    MatchState backtrackState = new MatchState(state);
                    if (eval((CommonTree) tree.getChild(i), backtrackState)) {
                        if (mostGreedy == null) {
                            mostGreedy = backtrackState;
                        } else if (mostGreedy.idIndex < backtrackState.idIndex) {
                            mostGreedy = backtrackState;
                        }
                    }
                }
                if (mostGreedy == null) {
                    return false;
                }
                state.merge(mostGreedy);
                return true;
            case I_INTERVAL:
                IntegerConstraint iConstraint = (IntegerConstraint) tree;
                try {
                    int value = extractInteger(state);
                    if (value >= iConstraint.start && value <= iConstraint.end) {
                        return true;
                    }
                    return false;
                } catch (NumberFormatException nfe) {
                    return false;
                }
            case D_INTERVAL:
                DoubleConstraint dConstraint = (DoubleConstraint) tree;
                try {
                    double value = extractDouble(state);
                    if (value >= dConstraint.start && value <= dConstraint.end) {
                        return true;
                    }
                    return false;
                } catch (NumberFormatException nfe) {
                    return false;
                }
            case SPECIAL:
                return eval((CommonTree)tree.getChild(0), state);
            case AnyDigits:
                try {
                    extractDouble(state);
                } catch (NumberFormatException nfe) {
                    return false;
                }
                return true;
            case AnyCadence:
                for (String alias : CADENCE_ALIASES) {
                    if (state.id.regionMatches(true, state.idIndex, alias, 0, alias.length())) {
                        state.idIndex += alias.length();
                        return true;
                    }
                }
                return false;
            case Any:
                CommonTree nextTree = nextTree(tree);
                if (nextTree == null) {
                    //consume all
                    state.pathMatched = true;
                    state.pathPrefixMatched = true;
                    state.idIndex = state.id.length();
                    return true;
                }
                
                while (state.idIndex < state.id.length()) {
                    MatchState backtrackState = new MatchState(state);
                    if (eval(nextTree, backtrackState)) {
                    	//Not merging the backtrack state here because
                    	//it needs to be completely evaluated by a higher level
                    	//TODO:  move Any operator up higher in the tree in
                    	//preprocessing.
                        return true;
                    }
                    state.idIndex++;
                }
                return true;

        } // end switch

        throw new IllegalStateException("Failed to find case for token\""
            + token + "\".");
    }
    
    /**
     * Given the current tree find the part of the tree that would be
     * evaluated next.
     * @param tree
     * @return
     */
    private static CommonTree nextTree(CommonTree tree) {
        CommonTree parent = (CommonTree)tree.getParent();
        if (parent == null) {
        	//at root
        	return null;
        }
        
        int siblingIndex = tree.getChildIndex() + 1;
        if (siblingIndex <parent.getChildCount()) {
            return (CommonTree) parent.getChild(siblingIndex);
        }
        return nextTree(parent);
    }

    private static int extractInteger(MatchState state) throws NumberFormatException {
        StringBuilder bldr = new StringBuilder();
        for (; state.idIndex < state.id.length() && Character.isDigit(state.id.charAt(state.idIndex)); state.idIndex++) {
            bldr.append(state.id.charAt(state.idIndex));
        }
        return Integer.parseInt(bldr.toString());
    }

    private static double extractDouble(MatchState state) throws NumberFormatException {
        StringBuilder bldr = new StringBuilder();
        while (true) {
            if (state.idIndex >= state.id.length()) {
                break;
            }
            char c = state.id.charAt(state.idIndex);
            if (!Character.isDigit(c) && c != '.') {
                break;
            }
            bldr.append(c);
            state.idIndex++;
        }

        return Double.parseDouble(bldr.toString());
    }

    /**
     * Dumps the query structure to a graph viz formatted string.
     * 
     * @return
     */
    public String toDot() {
        DOTTreeGenerator gen = new DOTTreeGenerator();
        StringTemplate st = gen.toDOT(queryRoot);
        return st.toString();
    }

    private static final class IntegerConstraint extends CommonTree {
        final int start;
        final int end;

        IntegerConstraint(CommonTree intervalTree) {
            super(new CommonToken(I_INTERVAL));
            start = Integer.parseInt(intervalTree.getChild(0)
                .getText());
            end = Integer.parseInt(intervalTree.getChild(1)
                .getText());

            if (end < start) {
                throw new IllegalArgumentException("Interval constraint start "
                    + start + " comes after end " + end + ".");
            }
        }

        @Override
        public String toString() {
            return "start=" + start + " end=" + end;
        }

        @Override
        public String getText() {
            return toString();
        }
    }

    private static final class DoubleConstraint extends CommonTree {
        final double start;
        final double end;

        DoubleConstraint(CommonTree intervalTree) {
            super(new CommonToken(D_INTERVAL));

            start = Double.parseDouble(intervalTree.getChild(0)
                .getText());
            end = Double.parseDouble(intervalTree.getChild(1)
                .getText());

            if (end < start) {
                throw new IllegalArgumentException("Interval constraint start "
                    + start + " comes after end " + end + ".");
            }

        }
    }
    
    
    private static final class MatchState {
        
        private boolean pathMatched = false;
        private boolean pathPrefixMatched = false;
        private boolean completeMatch = false;
        private int idIndex = 0;
        private final String id;
        
        MatchState(MatchState matchState) {
            this.pathMatched = matchState.pathMatched;
            this.pathPrefixMatched = matchState.pathPrefixMatched;
            this.completeMatch = matchState.completeMatch;
            this.idIndex = matchState.idIndex;
            this.id = matchState.id;
        }

        MatchState(String id) {
            this.id = id;
        }

        void merge(MatchState src) {
            this.pathMatched = src.pathMatched;
            this.pathPrefixMatched = src.pathPrefixMatched;
            this.completeMatch = src.completeMatch;
            this.idIndex = src.idIndex;
        }
    }

    /**
     * Order strings according to decreasing length.
     *
     */
    private static final class StringLengthComparator implements Comparator<String>{

        @Override
        public int compare(String s1, String s2) {
            return s2.length() - s1.length();
        }
        
    }
}

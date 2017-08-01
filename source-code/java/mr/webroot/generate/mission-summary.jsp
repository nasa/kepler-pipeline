<%--
  Copyright 2017 United States Government as represented by the
  Administrator of the National Aeronautics and Space Administration.
  All Rights Reserved.
  
  This file is available under the terms of the NASA Open Source Agreement
  (NOSA). You should have received a copy of this agreement with the
  Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
  
  No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
  WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
  INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
  WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
  INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
  FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
  TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
  CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
  OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
  OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
  FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
  REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
  AND DISTRIBUTES IT "AS IS."

  Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
  AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
  SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
  THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
  EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
  PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
  SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
  STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
  PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
  REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
  TERMINATION OF THIS AGREEMENT.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<% if (request.getParameter("submit") != null) { // If submitted %>

<h3>Generating Mission Summary Report</h3>

Your report is being generated.  When complete, it will be stored in the
report tree at the following URL:

<br>

&nbsp;&nbsp;
<a href="/reportal.html?path=/report/contact/proto/20090801040000">
  http://${header["host"]}${pageContext.request.contextPath}/report/quarterly/mission-summary/${param.quarter}/</a>

<% } else { // Not submitted %>

<h3>Generate Mission Summary Report</h3>

<form>

<fieldset>
  <legend>Report Parameters</legend>

  <table>
  <tr>
    <td style="text-align: left;"><span style="font-style: bold;">
      Quarter:</span>
    </td>
  </tr>
  <tr>
    <td>
      <select name="quarter" size="6" title="Select quarter"
              onChange="validateQuarter();">
        <option selected value="q408">Q4 2008</option>
        <option value="q1-2009">Q1 2009</option>
        <option value="q2-2009">Q2 2009</option>
        <option value="q3-2009">Q3 2009</option>
        <option value="q4-2009">Q4 2009</option>
        <option value="q1-2010">Q1 2010</option>
        <option value="q2-2010">Q2 2010</option>
        <option value="q3-2010">Q3 2010</option>
        <option value="q4-2010">Q4 2010</option>
        <option value="q1-2011">Q1 2011</option>
        <option value="q2-2011">Q2 2011</option>
        <option value="q3-2011">Q3 2011</option>
        <option value="q4-2011">Q4 2011</option>
        <option value="q1-2012">Q1 2012</option>
        <option value="q2-2012">Q2 2012</option>
        <option value="q3-2012">Q3 2012</option>
      </select>
      <br>
      <br>
    </td>
  </tr>
  <tr>
    <td style="text-align: left;"><span style="font-style: bold;">
      Report availability notification email address:
    </td>
  </tr>
  <tr>
    <td>
      <input type="text" name="email" size="50">
    </td>
  </tr>
  </table>

</fieldset>

<br>
<input type="submit" name="submit" value="Generate Report">

</form>

<% } // End if submitted %>

%
% Copyright 2017 United States Government as represented by the
% Administrator of the National Aeronautics and Space Administration.
% All Rights Reserved.
% 
% This file is available under the terms of the NASA Open Source Agreement
% (NOSA). You should have received a copy of this agreement with the
% Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
% 
% No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
% WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
% INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
% WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
% INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
% FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
% TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
% CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
% OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
% OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
% FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
% REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
% AND DISTRIBUTES IT "AS IS."
%
% Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
% AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
% SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
% THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
% EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
% PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
% SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
% STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
% PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
% REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
% TERMINATION OF THIS AGREEMENT.
%
<TeXmacs|1.0.6.9>

<style|generic>

<\body>
  small planet approximation. \ 

  We define the non-linear limb-darkening model

  <\equation*>
    I<left|(>r<right|)>=1-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1-<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>><right|)>
  </equation*>

  We define, for <math|c<rsub|0>=1-c<rsub|1>-c<rsub|2>-c<rsub|3>-c<rsub|4>>,
  which is the specific intensity at the center of the stellar disk.

  <\eqnarray*>
    <tformat|<table|<row|<cell|\<b-Omega\>>|<cell|=>|<cell|<big|sum><rsub|n=0><rsup|4><frac|c<rsub|n>|n+4>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|4>*<left|(>1-c<rsub|1>-c<rsub|2>-c<rsub|3>-c<rsub|4><right|)>+<frac|c<rsub|1>|5>+<frac|c<rsub|2>|6>+<frac|c<rsub|3>|7>+<frac|c<rsub|4>|8>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|4>-<frac|c<rsub|1>|20>-<frac|c<rsub|2>|12>-<frac|3*c<rsub|3>|28>-<frac|c<rsub|4>|8>>>>>
  </eqnarray*>

  so

  <\equation*>
    4\<b-Omega\>=1-<frac|c<rsub|1>|5>-<frac|c<rsub|2>|3>-<frac|3*c<rsub|3>|7>-<frac|c<rsub|4>|2>
  </equation*>

  <section|Full Transit>

  We define the integral

  <\eqnarray*>
    <tformat|<table|<row|<cell|I<rsup|*\<ast\>><left|(>z<right|)>>|<cell|=>|<cell|<frac|1|4*z*p><big|int><rsub|z-p><rsup|z+p>2*r*I<left|(>r<right|)>d*r>>|<row|<cell|>|<cell|=>|<cell|<frac|1|4*z*p><big|int><rsub|z-p><rsup|z+p>2*r**<left|(>1-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1-<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>><right|)><right|)>d*r>>|<row|<cell|>|<cell|=>|<cell|<frac|1|4*z*p><left|(>4*p*z-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<big|int><rsub|z-p><rsup|z+p>2*r*<left|(>1-<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>><right|)>*d*r<right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|4*z*p><left|(>4*p*z-4*p*z<big|sum><rsub|n=1><rsup|4>c<rsub|n>*-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<big|int><rsub|z-p><rsup|z+p>2*r*<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>>*d*r<right|)>>>>>
  </eqnarray*>

  now

  <\eqnarray*>
    <tformat|<table|<row|<cell|<big|int><rsub|z-p><rsup|z+p>2*r*<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>>*d*r>|<cell|=>|<cell|<big|int><rsub|z-p><rsup|1>2r*<left|(>1-r<rsup|2><right|)><rsup|<frac|n|4>>d*r>>>>
  </eqnarray*>

  set <math|x=1-r<rsup|2>> so <math|d*x=-2*r*d*r> and <math|r=z+p> goes to
  <math|x=1-(z+p)<rsup|2>> and <math|r=z-p> goes to <math|x=1-(z-p)<rsup|2>>
  so we get

  <\eqnarray*>
    <tformat|<table|<row|<cell|<big|int><rsub|z-p><rsup|x+p>2r*<left|(>1-r<rsup|2><right|)><rsup|<frac|n|4>>d*r>|<cell|=>|<cell|-<big|int><rsub|1-(z-p)<rsup|2>><rsup|1-(z+p)<rsup|2>>x<rsup|<frac|n|4>>d*x>>|<row|<cell|>|<cell|=>|<cell|-<frac|4|n+4><left|(><left|(>1-(z+p)<rsup|2><right|)><rsup|<frac|n+4|4>>-(1-(z-p)<rsup|2>)<rsup|<rsup|<frac|n+4|4>>><right|)>>>|<row|<cell|>|<cell|=>|<cell|-<frac|4|n+4><left|(><left|(>1-(z+p)<rsup|2><right|)><rsup|<frac|n+4|4>>-(1-(z-p)<rsup|2>)<rsup|<frac|n+4|4>><right|)>>>|<row|<cell|>|<cell|=>|<cell|-<frac|4|n+4><left|(>\<sigma\><rsub|2><rsup|n+4>-\<sigma\><rsub|1><rsup|n+4><right|)>.>>>>
  </eqnarray*>

  where <math|><with|mode|math|\<sigma\><rsub|1>=<left|(>1-<left|(>z-p<right|)><rsup|2><right|)><rsup|<frac|1|4>>>
  and <with|mode|math|\<sigma\><rsub|2>=<left|(>1-<left|(>z+p<right|)><rsup|2><right|)><rsup|<frac|1|4>>>.
  \ Therefore

  <\eqnarray*>
    <tformat|<table|<row|<cell|I<rsup|*\<ast\>><left|(>z<right|)>>|<cell|=>|<cell|<frac|1|4*z*p><left|(>4*p*z-4*p*z<big|sum><rsub|n=1><rsup|4>c<rsub|n>*+<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<frac|4|n+4><left|(>\<sigma\><rsub|2><rsup|n+4>-\<sigma\><rsub|1><rsup|n+4><right|)><right|)>>>|<row|<cell|>|<cell|=>|<cell|1-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*+<frac|1|*z*p<left|(>n+4<right|)>><big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>\<sigma\><rsub|2><rsup|n+4>-\<sigma\><rsub|1><rsup|n+4><right|)>>>|<row|<cell|>|<cell|=>|<cell|1-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1+<frac|1|*z*p<left|(>n+4<right|)>>*<left|(>\<sigma\><rsub|2><rsup|n+4>-\<sigma\><rsub|1><rsup|n+4><right|)><right|)>>>>>
  </eqnarray*>

  In the small planet approximation, when <math|z\<less\>1-p> or when the
  planet is in the interior of the star but not at the center (<math|z=0>)
  then the limb-darkened flux is

  <\eqnarray*>
    <tformat|<table|<row|<cell|F>|<cell|=>|<cell|1-<frac|p<rsup|2>*I<rsup|*\<ast\>><left|(>z<right|)>|4*\<b-Omega\>>>>|<row|<cell|>|<cell|=>|<cell|1-<frac|p<rsup|2>*|4*\<b-Omega\>>*<left|[>1-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1+<frac|1|*z*p<left|(>n+4<right|)>>*<left|(>\<sigma\><rsub|2><rsup|n+4>-\<sigma\><rsub|1><rsup|n+4><right|)><right|)><right|]>.>>>>
  </eqnarray*>

  <section|Ingress and Egress>

  When the planet only partially blocks the star, that is
  <math|1-p\<less\>z\<less\>1+p> then we use the integral, for <math|a> being
  the semi-major axis,

  <\eqnarray*>
    <tformat|<table|<row|<cell|I<rsup|*\<ast\>><left|(>z<right|)>>|<cell|=>|<cell|<frac|1|1-<left|(>z-p<right|)><rsup|2>><big|int><rsub|z-p><rsup|1>2*r*I<left|(>r<right|)>d*r>>|<row|<cell|>|<cell|=>|<cell|<frac|1|1-<left|(>z-p<right|)><rsup|2>><left|(><big|int><rsub|z-p><rsup|1>2*r*d*r-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<big|int><rsub|z-p><rsup|1>2*r*<left|(>1-<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>><right|)>*d*r<right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|1-<left|(>z-p<right|)><rsup|2>><left|(><with|mode|text|<with|mode|math|1-<left|(>z-p<right|)><rsup|2>>>-2*<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<big|int><rsub|z-p><rsup|1>r**d*r+<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<big|int><rsub|z-p><rsup|1>2*r*<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>>*d*r<right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|1-<left|(>z-p<right|)><rsup|2>><left|(><with|mode|text|<with|mode|math|1-<left|(>z-p<right|)><rsup|2>>>-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1-<left|(>z-p<right|)><rsup|2><right|)>+<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<big|int><rsub|z-p><rsup|1>2*r*<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>>*d*r<right|)>>>>>
  </eqnarray*>

  \;

  Let's do the integral

  <\eqnarray*>
    <tformat|<table|<row|<cell|<big|int><rsub|z-p><rsup|1>2*r*<left|(><sqrt|1-r<rsup|2>><right|)><rsup|<frac|n|2>>d*r>|<cell|=>|<cell|<big|int><rsub|z-p><rsup|1>2r*<left|(>1-r<rsup|2><right|)><rsup|<frac|n|4>>d*r>>>>
  </eqnarray*>

  set <math|x=1-r<rsup|2>> so <math|d*x=-2*r*d*r> and <math|r=1> goes to
  <math|x=0> and <math|r=z-p> goes to <math|x=1-(z-p)<rsup|2>> so we get

  <\eqnarray*>
    <tformat|<table|<row|<cell|<big|int><rsub|z-p><rsup|1>2r*<left|(>1-r<rsup|2><right|)><rsup|<frac|n|4>>d*r>|<cell|=>|<cell|-<big|int><rsub|1-(z-p)<rsup|2>><rsup|0>x<rsup|<frac|n|4>>d*x>>|<row|<cell|>|<cell|=>|<cell|-<frac|4|n+4><left|(>0-(1-(z-p)<rsup|2>)<rsup|<frac|n+4|4>><right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|4|n+4>(1-(z-p)<rsup|2>)<rsup|<frac|n+4|4>>>>>>
  </eqnarray*>

  so

  <\eqnarray*>
    <tformat|<table|<row|<cell|I<rsup|*\<ast\>><left|(>z<right|)>>|<cell|=>|<cell|<frac|1|1-<left|(>z-p<right|)><rsup|2>><left|(><left|(>1-<left|(>z-p<right|)><rsup|2><right|)>*<left|(><with|mode|text|<with|mode|math|1>>-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<right|)>+<big|sum><rsub|n=1><rsup|4>c<rsub|n><frac|4|n+4>(1-(z-p)<rsup|2>)<rsup|<frac|n+4|4>>*<right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|1-<left|(>z-p<right|)><rsup|2>><left|(>1-<left|(>z-p<right|)><rsup|2><right|)><left|(><with|mode|text|<with|mode|math|1>>-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*+<big|sum><rsub|n=1><rsup|4>c<rsub|n><frac|4|n+4>(1-(z-p)<rsup|2>)<rsup|<frac|n|4>>*<right|)>>>|<row|<cell|>|<cell|=>|<cell|<with|mode|text|<with|mode|math|1>>-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1-<frac|4|n+4>(1-(z-p)<rsup|2>)<rsup|<frac|n|4>>*<right|)>>>|<row|<cell|>|<cell|=>|<cell|<with|mode|text|<with|mode|math|1>>-<big|sum><rsub|n=1><rsup|4>c<rsub|n>*<left|(>1-<frac|4|n+4>\<sigma\><rsub|1><rsup|n><right|)>.>>>>
  </eqnarray*>

  Then the flux of the star while the planet in ingressing and egressing is

  <\eqnarray*>
    <tformat|<table|<row|<cell|F>|<cell|=>|<cell|1-<frac|I<rsup|*\<ast\>><left|(>z<right|)>|4\<b-Omega\>><left|[>p<rsup|2>*cos<rsup|-1><left|(><frac|z-1|p><right|)>-<left|(>z-1<right|)>*<sqrt|p<rsup|2>-<left|(>z-1<right|)><rsup|2>><left|]>.>>>>
  </eqnarray*>
</body>

<\references>
  <\collection>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|2|?>>
  </collection>
</references>

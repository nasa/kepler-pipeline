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
  <section|Creation of a Transiting Planetary Orbit>

  We take the orbital ellipse to be defined in the plane of its orbit in a
  coordinate system <with|mode|math|(r,\<theta\>)> in which pericenter occurs
  at <with|mode|math|(r<rsub|0>,\<theta\><rsub|0>=0)>. \ We assume that the
  following data are provided:

  <\itemize>
    <item>Properties of the primary star including mass
    <with|mode|math|M<rsub|<with|mode|text|primary>>> and radius
    <with|mode|math|R<rsub|<with|mode|text|primary>>>.

    <item>Secondary (planet) radius <with|mode|math|R<rsub|<with|mode|text|secondary>>>.

    <item>Eccentricity <with|mode|math|e>.

    <item>Orbital period <with|mode|math|P>.

    <item>Line-of-sight angle <with|mode|math|\<theta\><rsub|<with|mode|text|LOS>>>
    projected onto the orbital plane.

    <item>Minimum transit impact parameter <with|mode|math|d> in units of
    <with|mode|math|R<rsub|<with|mode|text|primary>>>, which determines the
    depth of the transit.

    <item>The start of the first exposure of the mission, the exposure and
    readout times in seconds.
  </itemize>

  <subsection|Characterizing the Orbital Parameters>

  At any point in time at which we know the angle <with|mode|math|\<theta\>>,
  we can find the radius <with|mode|math|r> from the equation for an ellipse
  in polar coordinates

  <\equation>
    <label|ellipse>r=r<rsub|0>*<frac|1+e|1+e*cos\<theta\>>.
  </equation>

  The semi-major axis <with|mode|math|a> is given by\ 

  <\eqnarray*>
    <tformat|<table|<row|<cell|a>|<cell|=>|<cell|<frac|1|2>*<left|(>r<rsub|0>+r<rsub|\<pi\>><right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|1|2>*<left|(>r<rsub|0>+r<rsub|0>*<frac|1+e|1-e><right|)>>>|<row|<cell|>|<cell|=>|<cell|<frac|r<rsub|0>|1-e>>>>>
  </eqnarray*>

  so if we are given input data <with|mode|math|a> and <with|mode|math|e>
  then <with|mode|math|r<rsub|0>=a(1-e)>. \ So the equation for our ellipse
  can also be written

  <\equation*>
    r=a*<frac|1-e<rsup|2>|1+e*cos\<theta\>>.
  </equation*>

  From <with|mode|math|M>, \ <with|mode|math|e> and
  <with|mode|math|r<rsub|0>> we can determine the conserved angular momentum
  <with|mode|math|j> as\ 

  <\equation>
    <label|angmom>j=<sqrt|r<rsub|0>*G*M*(1+e)>=<sqrt|a*G*M*(1-e<rsup|2>)>.
  </equation>

  Then <with|mode|math|\<theta\>> obeys <with|mode|math|<wide|\<theta\>|\<dot\>>\<equiv\>><with|mode|math|<frac|d*\<theta\>|dt>=<frac|j|r<rsup|2><rsub|>>>
  is a constant, so in partucular at\ 

  <\equation*>
    <wide|\<theta\>|\<dot\>>(r<rsub|0>,\<theta\><rsub|0>)=<frac|j|r<rsup|2><rsub|0>>=<sqrt|<frac|G*M*(1+e)|r<rsup|3><rsub|0>>>
  </equation*>

  gives the maximum angular velocity. \ 

  The time period of the orbit is given by\ 

  <\eqnarray*>
    <tformat|<table|<row|<cell|P>|<cell|=>|<cell|<frac|2*\<pi\>*a<rsup|2>|j>*<sqrt|1-e<rsup|2>>>>|<row|<cell|>|<cell|=>|<cell|<frac|2*\<pi\>*a<rsup|2>|<sqrt|a*G*M*(1-e<rsup|2>)>>*<sqrt|1-e<rsup|2>>>>|<row|<cell|>|<cell|=>|<cell|2*\<pi\><sqrt|<frac|*a<rsup|3>|G*M>>.>>>>
  </eqnarray*>

  Therefore

  <\equation*>
    a=*<left|(><left|(><frac|P|2*\<pi\>><right|)><rsup|2>G*M<right|)><rsup|<frac|1|3>>.
  </equation*>

  In order to compute the actual orbit we convert to Cartesian coordinates
  <with|mode|math|(x,y)=(r*cos\<theta\>, r*sin\<theta\>) \ > with
  <with|mode|math|<with|mode|math|(x<rsub|0>,y<rsub|0>)>=(r<rsub|0>,0)>.
  \ Then <with|mode|math|<with|mode|text|<with|mode|math|(<wide|x|\<dot\>>,<wide|y|\<dot\>>)=(<wide|r|\<dot\>>*cos\<theta\>-r**<wide|\<theta\>|\<dot\>>*sin\<theta\>,
  <wide|r|\<dot\>>*sin\<theta\>+r**<wide|\<theta\>|\<dot\>>*cos\<theta\>)>>>.
  \ Now\ 

  <\equation*>
    <wide|r|\<dot\>>=r<rsub|0>*<frac|e*<left|(>e+1<right|)>*sin
    <left|(>\<theta\><right|)>|<left|(>e*cos
    <left|(>\<theta\><right|)>+1<right|)><rsup|2>>*<wide|\<theta\>|\<dot\>>
  </equation*>

  so at <with|mode|math|(r<rsub|0>,\<theta\><rsub|0>=0)>,
  <with|mode|math|<wide|r|\<dot\>>*=0> and

  <\equation*>
    <with|mode|text|<with|mode|math|<with|mode|text|<with|mode|math|(<wide|x|\<dot\>>,<wide|y|\<dot\>>)<mid|\|><rsub|(x<rsub|0>,y<rsub|0>)>=(0,r<rsub|0>**<wide|\<theta\>|\<dot\>>*(r<rsub|0>,\<theta\><rsub|0>))=<left|(>0,<sqrt|<frac|G*M*(1+e)|r<rsup|><rsub|0>>><right|)>
    >>>>.
  </equation*>

  This result gives the correct value for circular orbits where
  <with|mode|math|e=0>. \ We use these values
  <with|mode|math|(x<rsub|0>,y<rsub|0>)=(r<rsub|0>,0)> and
  <with|mode|math|><with|mode|math|<with|mode|text|<with|mode|math|<with|mode|text|<with|mode|math|(<wide|x|\<dot\>>,<wide|y|\<dot\>>)<mid|\|><rsub|(x<rsub|0>,y<rsub|0>)>=<left|(>0,<sqrt|<frac|G*M*(1+e)|r<rsup|><rsub|0>>><right|)>
  >>>>>as inputs to the routine <kbd|compute_kepler_orbit> to compute the
  planet's orbit. \ The resulting orbit is given as arrays
  <with|mode|math|(x<rsub|i>,y<rsub|i>)> given at times
  <with|mode|math|t<rsub|i>. \ >

  Once we have the orbit <with|mode|math|><with|mode|math|(x<rsub|i>,y<rsub|i>)>
  we want to rotate these points so that from the direction defined by the
  line-of-sight angle <with|mode|math|<with|mode|text|<with|mode|math|\<theta\><rsub|<with|mode|text|LOS>>><with|mode|math|>
  a transit occurs with the specified minimum impact parameter. The transit
  occurs at <with|mode|math|(r<rsub|T>,\<theta\><rsub|T>)=<left|(>r<rsub|0>*<frac|1+e|1+e*cos\<theta\><rsub|<with|mode|text|LOS>>>,\<theta\><rsub|<with|mode|text|LOS>><right|)>
  > which is given in Cartesian coordinates by >>

  <\equation*>
    (x<rsub|T>,y<rsub|T>)=<left|(>r<rsub|T>*cos\<theta\><rsub|T>,r<rsub|T>*sin\<theta\><rsub|T>).
  </equation*>

  <subsection|Computing the Orbit Near Transit Events>

  Given the line-of-sight angle <math|\<theta\><rsub|<with|mode|text|LOS>>>
  we compute the central time of the transit event by computing the time at
  which the planet has <math|\<theta\>=\<theta\><rsub|LOS>>. \ This is given
  by (Bate <with|font-shape|italic|et. al.<with|font-shape|right| eq. 4.2.9
  with <math|t<rsub|0>=0>)>>

  <\equation*>
    t<rsub|\<theta\>>=<sqrt|<frac|a<rsup|3>|G*M>><left|[>2*k*\<pi\>+<left|(>E(\<theta\>)-e*sin(E(\<theta\>)<right|)>-<left|(>E(0)-e*sin(E(0)<right|)><right|]>
  </equation*>

  where <math|k> is the number of times the planet passses through pericenter
  when going from <math|0> to <math|\<theta\>> (we will typically have
  <math|k=0), and >

  <\equation*>
    E(\<theta\>)=acos<left|(><frac|e+cos\<theta\>|1+e*cos\<theta\>><right|)>.
  </equation*>

  Since in our case <math|E(0)=0> and by construction <math|k=0>, the
  time-of-flight formula reduces to\ 

  <\equation*>
    t<rsub|\<theta\>>=<sqrt|<frac|a<rsup|3>|G*M>><left|[>E(\<theta\>)-e*sin(E(\<theta\>)<right|]>
  </equation*>

  Care must be taken when evaluating <math|E(\<theta\>) in MATLAB since there
  the domain of the acos function> is <math|[-1,1]>, where the range is
  <math|[-\<pi\>,\<pi\>]>. \ When <math|\<theta\>\<gtr\>\<pi\>> we use
  <math|2*\<pi\>-acos.>

  We want to determine a time interval that contains the entire transit event
  and starts with an exposure start time and ends with an exposure end time.
  We estimate the transit duration from from the radii of the primary and
  secondary and the orbital velocity of the secondary. \ We estimate the
  orbital velocity as the magnitude of the velocity vector
  <math|<wide|v|\<vect\>>=(v<rsub|x>,v<rsub|y>)> returned from the routine
  <kbd|compute_kepler_orbit> for <math|t<rsub|\<theta\>>> projected onto the
  normal plane of the LOS vector. \ Let <math|<wide|w|\<vect\>><rsub|LOS>=(cos(\<theta\><rsub|LOS>),sin(\<theta\><rsub|LOS>))>
  be the unit vector along the LOS vector. \ Then our desired velocity
  projection is given by\ 

  <\equation*>
    <wide|v|\<vect\>><rsub|plane of \ sky>=<wide|v|\<vect\>>-<left|(><wide|v|\<vect\>>\<cdot\><wide|w|\<vect\>><rsub|LOS><right|)><wide|w|\<vect\>><rsub|LOS>.
  </equation*>

  \ The maximum transit time duration, which occurs for a central transit, is
  given by

  <\equation*>
    \<Delta\>t<rsub|transit>=2*<frac|<left|(>R<rsub|primary>+R<rsub|secondary><right|)>|<mid|\|\|><wide|v|\<vect\>><rsub|plane
    of \ sky><right|\|\|>>,
  </equation*>

  where the factor of 2 accounts for the diameter of the primary plus one
  secondary radii each for ingress and egress. \ Our transit event is
  therefore contained in the time interval
  <math|[<math|t<rsub|\<theta\><rsub|LOS>>-\<Delta\>t<rsub|transit>>,t<rsub|\<theta\><rsub|LOS>>+\<Delta\>t<rsub|transit>]>.
  \ We pick an exposure start time prior to
  <math|t<rsub|\<theta\><rsub|LOS>>-\<Delta\>t<rsub|transit>> and an exposure
  end time after <math|t<rsub|\<theta\><rsub|LOS>>+\<Delta\>t<rsub|transit>>,
  and create arrays os exposure start and end times between. \ These times
  are used to compute instantaneous samples of the transit light curves at
  those times. \ 

  <subsection|Creating a Transiting Orbit>

  We want to rotate the orbit points by the approprate angle
  <with|mode|math|\<phi\>> about the axis in the orbital plane through the
  primary's position. \ 

  The angle <with|mode|math|\<phi\>> is determined by the requirement that at
  the middle of the transit the <with|mode|math|z>-component of the orbit is
  determined by <with|mode|math|d>, the required minimal impact parameter.
  \ At <with|mode|math|(r<rsub|LOS>,\<theta\><rsub|LOS>)><with|mode|math| >
  we have\ 

  <\equation*>
    z<rsub|T>=r<rsub|T>*sin\<phi\><rsub|>\<Rightarrow\>\<phi\>=sin<rsup|-1><left|(><frac|z<rsub|LOS>|r<rsub|LOS>><right|)>.
  </equation*>

  For small <with|mode|math|\<phi\>> we can approximate

  <\equation*>
    z<rsub|LOS>\<approx\>r<rsub|LOS>*\<phi\><rsub|>\<Rightarrow\>\<phi\>\<approx\><frac|z<rsub|LOS>|r<rsub|TLOS>>.
  </equation*>

  A transit can occur for <with|mode|math|\<pm\>\<phi\>>, but the resulting
  time series is the same in either case, so we always take
  <with|mode|math|\<phi\>> positive. \ We neglect the degree of freedom
  represented by rotation about LOS vector since that does not effect the
  transit signature.

  We rotate the points of the orbit by treating the points as vectors
  <with|mode|math|<wide|x|\<vect\>>=(x,y,z)<rsup|T> >in three-dimensional
  Cartesian coordinates. \ We then perform the rotation of the orbit in three
  steps:

  <\enumerate-numeric>
    <item>Rotate the points about the <with|mode|math|z>-axis by the angle
    <with|mode|math|-\<theta\><rsub|<with|mode|text|LOS>>>

    <\equation*>
      <matrix|<tformat|<table|<row|<cell|x<rprime|'>>>|<row|<cell|y<rprime|'>>>|<row|<cell|z<rprime|'>>>>>>=<matrix|<tformat|<table|<row|<cell|cos<left|(>-\<theta\><rsub|<with|mode|text|LOS>><right|)>>|<cell|-sin<left|(>-\<theta\><rsub|<with|mode|text|LOS>><right|)>>|<cell|0>>|<row|<cell|sin<left|(>-\<theta\><rsub|<with|mode|text|LOS>><right|)>>|<cell|cos<left|(>-\<theta\><rsub|<with|mode|text|LOS>><right|)>>|<cell|0>>|<row|<cell|0>|<cell|0>|<cell|1>>>>>*<matrix|<tformat|<table|<row|<cell|x>>|<row|<cell|y>>|<row|<cell|z>>>>>=<matrix|<tformat|<table|<row|<cell|cos\<theta\><rsub|<with|mode|text|LOS>>>|<cell|sin\<theta\><rsub|<with|mode|text|LOS>>>|<cell|0>>|<row|<cell|-sin\<theta\><rsub|<with|mode|text|LOS>>>|<cell|cos\<theta\><rsub|<with|mode|text|LOS>>>|<cell|0>>|<row|<cell|0>|<cell|0>|<cell|1>>>>>*<matrix|<tformat|<table|<row|<cell|x>>|<row|<cell|y>>|<row|<cell|z>>>>>
    </equation*>

    which puts the intersection between the orbit and the line-of-sight
    vector on the positive <with|mode|math|x>-axis.

    <item>Rotate the points about the <with|mode|math|y>-axis by the angle
    <with|mode|math|\<phi\>>

    <\equation*>
      <matrix|<tformat|<table|<row|<cell|x<rprime|''>>>|<row|<cell|y<rprime|''>>>|<row|<cell|z<rprime|''>>>>>>=<matrix|<tformat|<table|<row|<cell|cos\<phi\>>|<cell|0>|<cell|-sin\<phi\>>>|<row|<cell|0>|<cell|1>|<cell|0>>|<row|<cell|sin\<phi\>>|<cell|0>|<cell|cos\<phi\>>>>>>*<matrix|<tformat|<table|<row|<cell|x<rprime|'>>>|<row|<cell|y<rprime|'>>>|<row|<cell|z<rprime|'>>>>>>
    </equation*>

    <item>Rotate about the angle <with|mode|math|\<theta\><rsub|<with|mode|text|LOS>>>,
    returning the transit event to the line-of-sight vector

    <\equation*>
      <matrix|<tformat|<table|<row|<cell|x<rprime|'''>>>|<row|<cell|y<rprime|'''>>>|<row|<cell|z<rprime|'''>>>>>>=<matrix|<tformat|<table|<row|<cell|cos\<theta\><rsub|<with|mode|text|LOS>>>|<cell|-sin\<theta\><rsub|<with|mode|text|LOS>>>|<cell|0>>|<row|<cell|sin\<theta\><rsub|<with|mode|text|LOS>>>|<cell|cos\<theta\><rsub|<with|mode|text|LOS>>>|<cell|0>>|<row|<cell|0>|<cell|0>|<cell|1>>>>>*<matrix|<tformat|<table|<row|<cell|x<rprime|''>>>|<row|<cell|y<rprime|''>>>|<row|<cell|z<rprime|''>>>>>>.
    </equation*>
  </enumerate-numeric>

  In other words the required rotation is
  <with|mode|math|><with|mode|math|<wide|x|\<vect\>>\<rightarrow\>R<rsub|z>(\<theta\><rsub|<with|mode|text|LOS>>)R<rsub|y>(\<phi\>)R<rsub|z>(\<theta\><rsub|<with|mode|text|LOS>>)<rsup|T><wide|x|\<vect\>>>
  where

  <\eqnarray*>
    <tformat|<table|<row|<cell|R<rsub|z>(\<theta\>)>|<cell|=>|<cell|<matrix|<tformat|<table|<row|<cell|cos\<theta\>>|<cell|-sin\<theta\>>|<cell|0>>|<row|<cell|sin\<theta\>>|<cell|cos\<theta\>>|<cell|0>>|<row|<cell|0>|<cell|0>|<cell|1>>>>>>>|<row|<cell|R<rsub|y>(\<phi\>)>|<cell|=>|<cell|<matrix|<tformat|<table|<row|<cell|cos\<phi\>>|<cell|0>|<cell|-sin\<phi\>>>|<row|<cell|0>|<cell|1>|<cell|0>>|<row|<cell|sin\<phi\>>|<cell|0>|<cell|cos\<phi\>>>>>>.>>>>
  </eqnarray*>

  <subsection|Integrating the Final Light Curve>

  \ The integrated exposure light curve is calculated for each exposure using
  the trapezoidal rule. \ If <math|t<rsub|exposure start>> and
  <math|t<rsub|exposure end>> are the times of the start and end of an
  exposure, <math|t<rsub|exposure>> is the mid-point of an exposure,
  <math|\<Delta\>t<rsub|exposure>=t<rsub|exposure start>-t<rsub|exposure
  end>> the time interval of an exposure, <math|L(t)> the light curve value
  at time t, then the integrated exposure light curve at
  <math|t<rsub|exposure>> is defined as

  <\equation*>
    L<rsub|exposure>(t<rsub|exposure>)=<big|int><rsub|t<rsub|exposure
    start>><rsup|t<rsub|exposure end>>L(t)*dt\<approx\><frac|1|2>*\<Delta\>t<rsub|exposure>*<left|[>L<left|(>t<rsub|exposure
    start><right|)>+L<left|(>t<rsub|exposure end><right|)><right|]>.
  </equation*>

  These exposure light curve values are then added to create the final long
  or short cadence light curves.

  <section|Binary Orbits>

  In center of mass coordinates the binary orbit is given by\ 

  <\equation*>
    R=R<rsub|0>*<frac|1+e<rsub|C>|1+e<rsub|C>*cos\<theta\><rsub|C>>
  </equation*>

  where <with|mode|math|R=r<rsub|1>-r<rsub|2>>. \ We also deine
  <with|mode|math|r=<frac|m<rsub|1>*r<rsub|1>+m<rsub|2>*r<rsub|2>|m<rsub|1>+m<rsub|2>>>,
  the center of mass of the system, and the reduced mass
  <with|mode|math|\<mu\>=<frac|m<rsub|1>*m<rsub|2>|m<rsub|1>+m<rsub|2>>>.
  \ The physical orbits are given by by transformation

  <\equation*>
    r<rsub|1>=r+<frac|\<mu\>|m<rsub|1>>*R,
    \ r<rsub|2>=r-<frac|\<mu\>|m<rsub|2>>*R.
  </equation*>

  The physical orbits in center-of-mass coordinates, where
  <with|mode|math|r=0>, are

  <\eqnarray*>
    <tformat|<table|<row|<cell|r<rsub|1>>|<cell|=>|<cell|<frac|\<mu\>|m<rsub|1>>*R>>|<row|<cell|>|<cell|=>|<cell|<frac|\<mu\>|m<rsub|1>>*R<rsub|0>*<frac|1+e<rsub|C>|1+e<rsub|C>*cos\<theta\><rsub|C>>>>>>
  </eqnarray*>

  which is an ellipse with eccentricity <with|mode|math|e<rsub|C>> and
  pericenter distance <with|mode|math|<frac|\<mu\>|m<rsub|1>>*R<rsub|0>>.
  \ Similarly\ 

  <\eqnarray*>
    <tformat|<table|<row|<cell|r<rsub|2>>|<cell|=>|<cell|-<frac|\<mu\>|m<rsub|2>>*R>>|<row|<cell|>|<cell|=>|<cell|-<frac|\<mu\>|m<rsub|2>>*R<rsub|0>*<frac|1+e<rsub|C>|1+e<rsub|C>*cos\<theta\><rsub|C>>.>>>>
  </eqnarray*>

  If we transform coordinates to fix <with|mode|math|r<rsub|1>> at the
  origin, then\ 

  <\eqnarray*>
    <tformat|<table|<row|<cell|r<rsub|2>>|<cell|=>|<cell|r-<frac|\<mu\>|m<rsub|2>>*R-r<rsub|1>>>|<row|<cell|>|<cell|=>|<cell|r-<frac|\<mu\>|m<rsub|2>>*R-r-<frac|\<mu\>|m<rsub|1>>*R>>|<row|<cell|>|<cell|=>|<cell|-<left|(><frac|1|m<rsub|1>>+<frac|1|m<rsub|2>><right|)>*\<mu\>*R>>|<row|<cell|>|<cell|=>|<cell|-<frac|m<rsub|2>+m<rsub|1>|m<rsub|1>*m<rsub|2>>*\<mu\>*R>>|<row|<cell|>|<cell|=>|<cell|-R.>>>>
  </eqnarray*>

  Similarly if we fix coordinates at <with|mode|math|r<rsub|2>> we have

  <\eqnarray*>
    <tformat|<table|<row|<cell|r<rsub|1>>|<cell|=>|<cell|r+<frac|\<mu\>|m<rsub|1>>*R-r<rsub|2>>>|<row|<cell|>|<cell|=>|<cell|r+<frac|\<mu\>|m<rsub|1>>*R-r+<frac|\<mu\>|m<rsub|2>>*R>>|<row|<cell|>|<cell|=>|<cell|R.>>>>
  </eqnarray*>
</body>

<\references>
  <\collection>
    <associate|angmom|<tuple|2|?>>
    <associate|auto-1|<tuple|1|?>>
    <associate|auto-2|<tuple|1.1|?>>
    <associate|auto-3|<tuple|1.2|?>>
    <associate|auto-4|<tuple|1.3|?>>
    <associate|auto-5|<tuple|1.4|?>>
    <associate|auto-6|<tuple|2|?>>
    <associate|ellipse|<tuple|1|?>>
  </collection>
</references>

<\auxiliary>
  <\collection>
    <\associate|toc>
      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Creation
      of a Transiting Planetary Orbit> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-1><vspace|0.5fn>

      <with|par-left|<quote|1.5fn>|Characterizing the Orbital Parameters
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-2>>

      <with|par-left|<quote|1.5fn>|Computing the Orbit Near Transit Events
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-3>>

      <with|par-left|<quote|1.5fn>|Creating a Transiting Orbit
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-4>>

      <with|par-left|<quote|1.5fn>|Integrating the Final Light Curve
      <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-5>>

      <vspace*|1fn><with|font-series|<quote|bold>|math-font-series|<quote|bold>|Binary
      Orbits> <datoms|<macro|x|<repeat|<arg|x>|<with|font-series|medium|<with|font-size|1|<space|0.2fn>.<space|0.2fn>>>>>|<htab|5mm>>
      <no-break><pageref|auto-6><vspace|0.5fn>
    </associate>
  </collection>
</auxiliary>

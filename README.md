2016 Upstate County General Election Data
=========================================

This script scrapes scvotes.org to gather voter turnout data from the 2016 general election for the Upstate area encompassing where I live in Clemson, South Carolina. These counties are Anderson, Oconee, and Pickens in my immediate reach as well as other counties south and east (prominently Greenville and Spartanburg). As far as electoral politics go, these aren't the most exciting areas in the country. In fact, they comprise the reddest part of a sunburn-red state (South Carolina). These data are largely for illustrative value in the classroom and in my local community.

- **county**: an identifier for county (e.g. Anderson, Oconee, Pickens)
- **precinct**: name of the precinct
- **bc**: total number of ballots cast
- **rv**: total number of registered voters
- **vtp**: voter turnout as a percentage (i.e. bc/rv * 100)
- **dem**: total number of straight-party-ticket votes cast for the Democratic party.
- **wf**: total number of straight-party-ticket votes cast for the Working Families party.
- **constitution**: total number of straight-party-ticket votes cast for the Constition party.
- **independence**: total number of straight-party-ticket votes cast for the Independence party.
- **green**: total number of straight-party-ticket votes cast for the Green party.
- **gop**: total number of straight-party-ticket votes cast for the Republican party.
- **libertarian**: total number of straight-party-ticket votes cast for the Libertarian party.
- **sttotal**: total number of straight-party-ticket votes cast in the precinct.
- **clinton**: total number of votes cast for Clinton for president.
- **castle**: total number of votes cast for Castle for president.
- **mcmullin**: total number of votes cast for McMullin for president.
- **stein**: total number of votes cast for Stein for president.
- **trump**: total number of votes cast for Trump for president.
- **skewes**: total number of votes cast for Skewes for president.
- **johnson**: total number of votes cast for Johnson for president.
- **potustotal**: total number of votes cast for president in the precinct.
- **dixon**: total number of votes cast for Dixon for Senate. scvotes.org originally triple-counted Dixon. This measure corrects for that.
- **bledsoe**: total number of votes cast for Bledsoe for Senate. scvotes.org originally double-counted Bledsoe. This measure corrects for that.
- **scott**: total number of votes cast for Scott for Senate.
- **scarborough**: total number of votes cast for Scarborough for Senate.
- **senwritein**: total number of write-in votes cast for Senate.
- **sentotal**: total number of votes cast in the Senate race.
- **cleveland**: total number of votes cast for Cleveland for House.
- **duncan**: total number of votes cast for Duncan for House.
- **housewritein**: total number of write-in votes cast for House.
- **housetotal**: total number of votes cast in House race at the precinct-level.

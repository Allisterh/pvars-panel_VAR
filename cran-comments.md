## Resubmission 2 (2025-09-12)
- DOCUMENTATION: A vignette has been added to the package and referenced in the DESCRIPTION. 
    The re-submitted version is built under "--compact-vignettes=both" 
    to avoid warning on significant size reductions by "gs+qpdf", 
    although either way both builds are smaller than 5MB.
- FIXED: References describing particularly noteworthy methods have been added to the description field of the DESCRIPTION.
- FIXED: All acronyms are now explained in the description text.
- FIXED: Documentation avoids the call of unexported objects foo:::f. Exported function rboot.normality now summarizes these calls.
- FIXED: \\dontrun\{\} has been replaced by \\donttest\{\}, related examples are not executable in < 5 sec.
    Minimal examples have been specified, but as-cran-checks still take 3 to 4 times longer than checks without donttest examples.

## Resubmission 1 (2025-07-07)
- FIXED: Unknown, possibly misspelled, fields in DESCRIPTION: 'Authors' 

## Package Information
This package implements (1) panel cointegration rank tests, (2) estimators for panel vector autoregressive (VAR) models, and (3) identification methods for panel structural vector autoregressive (SVAR) models as described in the accompanying vignette.

## R CMD Check Results
0 errors   0 warnings | 2 notes
- This is a new submission.
- The package is already built with "--compact-vignettes". The size and its reduction noted by qpdf is small (from 621KB to 438KB).

## Platform-Specific Checks
- win-builder: 0 errors | 0 warnings | 2 notes
- mac.r-project.org: 0 errors | 0 warnings | 2 notes

## Reverse Dependencies
This is a new submission, so there are no reverse dependencies.



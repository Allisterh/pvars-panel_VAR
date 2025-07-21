## Resubmission 2 (2025-07-XX)
- DOCUMENTATION: A vignette has been added to the package and referenced in the DESCRIPTION.
    The resubmission is built under "--compact-vignettes=both" 
    to avoid warning on significant size reductions by "gs+qpdf", 
    although either way both builds are smaller than 5MB.
- FIXED: References describing particularly noteworthy methods have been added to the description field of the DESCRIPTION.
- FIXED: All acronyms are now explained in the description text.
- TODO: Using foo:::f instead of foo::f allows access to unexported objects. Used ::: in documentation:
- TODO: \\dontrun\{\} has been replaced by \\donttest\{\}. Related examples not are executable in < 5 sec.

## Resubmission 1 (2025-07-07)
- FIXED: Unknown, possibly misspelled, fields in DESCRIPTION: 'Authors' 

## Package Information
This package implements (1) panel cointegration rank tests, (2) estimators for panel vector autoregressive (VAR) models, and (3) identification methods for panel structural vector autoregressive (SVAR) models as described in the accompanying vignette.

## R CMD Check Results
0 errors   0 warnings | 1 note
- This is a new submission.

## Platform-Specific Checks
- win-builder: 0 errors | 0 warnings | 1 note
- mac.r-project.org: 0 errors | 0 warnings | 1 note

## Reverse Dependencies
This is a new submission, so there are no reverse dependencies.



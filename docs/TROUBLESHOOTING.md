# Troubleshooting Guide

This guide provides solutions to common issues encountered while working with the 2_velocity project. Refer to this document whenever you face errors during the workflow.

---

## Issue: Missing Subdirectories in `jobs/`

### Error Message:
```
Error using fprintf
Invalid file identifier. Use fopen to generate a valid file identifier.
```

### Cause:
The required subdirectories `jobs/Landsat` and `jobs/sentinel2` are missing. These directories are necessary for storing MATLAB-generated SLURM job scripts.

### Solution:
Create the missing directories manually:
```
mkdir -p jobs/Landsat jobs/sentinel2
```
Ensure these directories exist before running any MATLAB scripts.

---

## Notes:
- Update this guide with new issues as they arise.
- Include the exact error message, cause, and solution for each issue.
- Keep the guide concise and easy to reference.

---

Let me know if further refinements are needed!
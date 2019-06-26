# PSRunspaceManager

This module is my implementation on using runspaces inside of PowerShell, rather than using `Start-Job`. `Start-Job` creates multiple processes of PowerShell, so depending on the scale of tasks to perform asynchronously it can seriously hamper performance. In my use case, there are thousands of AD objects I have to parse and utilizing PSJobs causes the system it's running on to slow to a halt. I previously would throttle the amount of PSJobs running at once.

## Notes

**This module is still under development. The code works, but is not optimized for production uses unless you understand the risks.**

There are other implementations out there

## To-Do

- [x] Initial development.
    - [x] Push to Github.
- [ ] Add help content.
- [ ] Comment code.
- [ ] Error handle .NET Framework objects.
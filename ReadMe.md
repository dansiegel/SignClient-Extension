# Sign Client Extension for VSTS

Code and Package signing help establish a chain of trust by ensuring that your package and binaries have not been manipulated between the Package Author and the Package Consumer. This extension builds on the [Sign Service](https://github.com/onovotny/SignService) from Oren Novotny, by providing an easy to use Build Task for VSTS that can be called without cluttering your source repository with yet another build script or exposing your configuration file for the Sign Client.

Note that this will work with absolutely any instance of the Sign Service. For more information on setting up your own Sign Service see the [deployment docs](https://github.com/onovotny/SignService/blob/master/docs/Deployment.md).
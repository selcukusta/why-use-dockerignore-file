# Why Use `.dockerignore`

## Create huge build context for .NET Core Web API application

```
dotnet build -c Release src
dotnet publish -c Release -r linux-musl-x64 src
```

## Build the image with specific `.dockerignore` file

`docker build -t with-ignore . --no-cache`

_Build output will be as follows;_
```
[+] Building 11.2s (12/12) FINISHED
 => [internal] load build definition from Dockerfile                                                 0.0s
 => => transferring dockerfile: 37B                                                                  0.0s
 => [internal] load .dockerignore                                                                    0.0s
 => => transferring context: 244B                                                                    0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/core/runtime-deps:3.0-alpine               0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/core/sdk:3.0-alpine                        0.0s
 => CACHED [runtime 1/2] FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0-alpine                  0.0s
 => [internal] load build context                                                                    0.1s
 => => transferring context: 369B                                                                    0.1s
 => CACHED [build-env 1/4] FROM mcr.microsoft.com/dotnet/core/sdk:3.0-alpine                         0.0s
 => [build-env 2/4] COPY /src /build                                                                 0.1s
 => [build-env 3/4] WORKDIR /build                                                                   0.1s
 => [build-env 4/4] RUN dotnet publish -c Release -r linux-musl-x64 -o publish-folder                9.5s
 => [runtime 2/2] COPY --from=build-env /build/publish-folder /usr/local/app                         0.5s
 => exporting to image                                                                               0.4s
 => => exporting layers                                                                              0.4s
 => => writing image sha256:361e8cdc98951b4a8c3006d749b99e734533b1a498c22c941331785d59dd717b         0.0s
 => => naming to docker.io/library/with-ignore                                                       0.0s
```

## Build the image without `.dockerignore` file

Comment-out all ignore lines and...

`sed -i '' 's/^\([^#]\)/#\1/g' .dockerignore`

...build the image again.

`docker build -t without-ignore . --no-cache`

_Build output will be as follows;_
```
 [+] Building 17.6s (12/12) FINISHED
 => [internal] load build definition from Dockerfile                                                 0.0s
 => => transferring dockerfile: 37B                                                                  0.0s
 => [internal] load .dockerignore                                                                    0.0s
 => => transferring context: 256B                                                                    0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/core/sdk:3.0-alpine                        0.0s
 => [internal] load metadata for mcr.microsoft.com/dotnet/core/runtime-deps:3.0-alpine               0.0s
 => [internal] load build context                                                                    5.7s
 => => transferring context: 196.01MB                                                                5.6s
 => CACHED [build-env 1/4] FROM mcr.microsoft.com/dotnet/core/sdk:3.0-alpine                         0.0s
 => CACHED [runtime 1/2] FROM mcr.microsoft.com/dotnet/core/runtime-deps:3.0-alpine                  0.0s
 => [build-env 2/4] COPY /src /build                                                                 0.5s
 => [build-env 3/4] WORKDIR /build                                                                   0.1s
 => [build-env 4/4] RUN dotnet publish -c Release -r linux-musl-x64 -o publish-folder               10.2s
 => [runtime 2/2] COPY --from=build-env /build/publish-folder /usr/local/app                         0.2s
 => exporting to image                                                                               0.4s
 => => exporting layers                                                                              0.4s
 => => writing image sha256:e1d7f2c0f297a24897b454e6f6b0b05ec0588620795a8505230556ea2be87286         0.0s
 => => naming to docker.io/library/without-ignore                                                    0.0s
 ```

 ## Result (`369B` vs `196.01MB`)

 If you would not use `.dockerignore` file, your all unnecessary files will be transferred to your build context such as `bin`, `obj`, etc. You can inspect the sizes of the intermediate images from `=> => transferring context: [DISK_USAGE_INFO]` lines.

If you're using a multi-stage building, your final image size might not be changed. Because you'll create executable files and other required objects in your build context and copy to the final stage. But the build timing is important as much as the size of the final image.

:sparkles: If you want to export and inspect your final image with whole folder structure you can append this parameter to the build command: `-o .image-output`